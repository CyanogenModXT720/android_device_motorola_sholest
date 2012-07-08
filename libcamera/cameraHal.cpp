/*
 * Copyright (C) 2012, rondoval
 * Copyright (C) 2012, Won-Kyu Park
 * Copyright (C) 2012, Raviprasad V Mummidi
 * Copyright (C) 2011, Ivan Zupan
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * ChangeLog
 *
 * 2012/01/19 - based on Raviprasad V Mummidi's code and some code by Ivan Zupan
 * 2012/01/21 - cleaned up by wkpark.
 * 2012/02/09 - first working version for P990/SU660 with software rendering
 *            - need to revert "MemoryHeapBase: Save and binderize the offset"
 *              commit f24c4cd0f204068a17f61f1c195ccf140c6c1d67.
 *            - some wrapper functions are needed (please see the libui.patch)
 * 2012/02/19 - Generic cleanup and overlay support (for Milestone 2)
 */

#define LOG_TAG "CameraHAL"
//#define LOG_NDEBUG 0

#include "CameraHardwareInterface.h"
#include <fcntl.h>
#include <hardware/camera.h>
#include <binder/IMemory.h>
#include <hardware/gralloc.h>
#include <utils/Errors.h>
#include <vector>

using namespace std;

/* Prototypes and extern functions. */
#ifdef BOARD_USE_FROYO_LIBCAMERA
extern "C" android::sp<android::CameraHardwareInterface> openCameraHardware(int cameraId);
#else
extern "C" android::sp<android::CameraHardwareInterface> HAL_openCameraHardware(int cameraId);
extern "C" int HAL_getNumberOfCameras();
extern "C" void HAL_getCameraInfo(int cameraId, struct CameraInfo* cameraInfo);
#endif

namespace android {

static long long mLastPreviewTime = 0;
static bool mThrottlePreview = false;
static bool mPreviousVideoFrameDropped = false;
static int mNumVideoFramesDropped = 0;

/* When the media encoder is not working fast enough,
   the number of allocated but yet unreleased frames
   in memory could start to grow without limit.

   Three thresholds are used to deal with such condition.
   First, if the number of frames gets over the PREVIEW_THROTTLE_THRESHOLD,
   just limit the preview framerate to relieve the CPU to help the encoder
   to catch up.
   If it is not enough and the number gets also over the SOFT_DROP_THRESHOLD,
   start dropping new frames coming from camera, but only one at a time,
   never two consecutive ones.
   If the number gets even over the HARD_DROP_THRESHOLD, drop the frames
   without further conditions. */

const unsigned int PREVIEW_THROTTLE_THRESHOLD = 6;
const unsigned int SOFT_DROP_THRESHOLD = 12;
const unsigned int HARD_DROP_THRESHOLD = 15;

/* The following values (in nsecs) are used to limit the preview framerate
   to reduce the CPU usage. */

const int MIN_PREVIEW_FRAME_INTERVAL = 80000000;
const int MIN_PREVIEW_FRAME_INTERVAL_THROTTLED = 200000000;

struct legacy_camera_device {
    camera_device_t device;
    int id;

    // New world
    camera_notify_callback             notify_callback;
    camera_data_callback               data_callback;
    camera_data_timestamp_callback     data_timestamp_callback;
    camera_request_memory              request_memory;
    void                              *user;
    preview_stream_ops                *window;

    // Old world
    sp<CameraHardwareInterface>        hwif;
    gralloc_module_t const            *gralloc;
    camera_memory_t*                   clientData;
    vector<camera_memory_t*>           sentFrames;
    sp<Overlay>                        overlay;

    int32_t                            previewWidth;
    int32_t                            previewHeight;
    Overlay::Format                    previewFormat;
};

/** camera_hw_device implementation **/
static inline struct legacy_camera_device * to_lcdev(struct camera_device *dev) {
    return reinterpret_cast<struct legacy_camera_device *>(dev);
}

static inline void log_camera_params(const char* name, const CameraParameters params) {
    LOGV("%s: dumping camera params", name);
    params.dump();
}

//
// http://code.google.com/p/android/issues/detail?id=823#c4
//
static void Yuv420spToRgb565(char* rgb, char* yuv420sp, int width, int height, int stride) {
    int frameSize = width * height;
    int padding = (stride - width) * 2; //two bytes per pixel for rgb565
    int colr = 0;
    for (int j = 0, yp = 0, k = 0; j < height; j++) {
        int uvp = frameSize + (j >> 1) * width, u = 0, v = 0;
        for (int i = 0; i < width; i++, yp++) {
            int y = (0xff & ((int) yuv420sp[yp])) - 16;
            if (y < 0) y = 0;
            if ((i & 1) == 0) {
                v = (0xff & yuv420sp[uvp++]) - 128;
                u = (0xff & yuv420sp[uvp++]) - 128;
            }

            int y1192 = 1192 * y;
            int r = (y1192 + 1634 * v);
            int g = (y1192 - 833 * v - 400 * u);
            int b = (y1192 + 2066 * u);

            r = std::max(0, std::min(r, 262143));
            g = std::max(0, std::min(g, 262143));
            b = std::max(0, std::min(b, 262143));

            rgb[k++] = ((g >> 7) & 0xe0) | ((b >> 13) & 0x1f);
            rgb[k++] = ((r >> 10) & 0xf8) | ((g >> 15) & 0x07);
        }
        k += padding;
    }
}

static void Yuv422iToRgb565 (char* rgb, char* yuv422i, int width, int height, int stride) {
    int yuvIndex = 0;
    int rgbIndex = 0;
    int padding = (stride - width) * 2; //two bytes per pixel for rgb565

    for (int j = 0; j < height; j++) {
        for (int i = 0; i < width / 2; i++) {

            int y1 = (0xff & ((int) yuv422i[yuvIndex++])) - 16;
            if (y1 < 0) y1 = 0;

            int u = (0xff & yuv422i[yuvIndex++]) - 128;

            int y2 = (0xff & ((int) yuv422i[yuvIndex++])) - 16;
            if (y2 < 0) y2 = 0;

            int v = (0xff & yuv422i[yuvIndex++]) - 128;

            int yy1 = 1192 * y1;
            int yy2 = 1192 * y2;
            int uv = 833 * v + 400 * u;
            int uu = 2066 * u;
            int vv = 1634 * v;

            int r = yy1 + vv;
            int g = yy1 - uv;
            int b = yy1 + uu;

            r = std::max(0, std::min(r, 262143));
            g = std::max(0, std::min(g, 262143));
            b = std::max(0, std::min(b, 262143));

            rgb[rgbIndex++] = ((g >> 7) & 0xe0) | ((b >> 13) & 0x1f);
            rgb[rgbIndex++] = ((r >> 10) & 0xf8) | ((g >> 15) & 0x07);

            r = yy2 + vv;
            g = yy2 - uv;
            b = yy2 + uu;

            r = std::max(0, std::min(r, 262143));
            g = std::max(0, std::min(g, 262143));
            b = std::max(0, std::min(b, 262143));

            rgb[rgbIndex++] = ((g >> 7) & 0xe0) | ((b >> 13) & 0x1f);
            rgb[rgbIndex++] = ((r >> 10) & 0xf8) | ((g >> 15) & 0x07);
        }
        rgbIndex += padding;
    }
}

/* from v4l lib */
static void Yuv422iToYV12 (unsigned char* dest, unsigned char* src, int width, int height, int stride) 
{
    int i, j;
    unsigned char *src1;
    unsigned char *udest, *vdest;

    /* copy the Y values */
    src1 = src;
    for (i = 0; i < height; i++) {
        for (j = 0; j < width; j += 2) {
            *dest++ = src1[0];
            *dest++ = src1[2];
            src1 += 4;
        }
    }

    /* copy the U and V values */
    src1 = src + width * 2;		/* next line */

    vdest = dest;
    udest = dest + width * height / 4;

    for (i = 0; i < height; i += 2) {
        for (j = 0; j < width; j += 2) {
            *udest++ = ((int) src[1] + src1[1]) / 2;	/* U */
            *vdest++ = ((int) src[3] + src1[3]) / 2;	/* V */
            src += 4;
            src1 += 4;
        }
        src = src1;
        src1 += width * 2;
    }
}

static void processPreviewData(char *frame, size_t size, legacy_camera_device *lcdev, Overlay::Format format) {
#ifdef LOG_EACH_FRAME
    LOGV("%s: frame=%p, size=%d, camera=%p", __FUNCTION__, frame, size, lcdev);
    LOGV("%s: width=%d, height=%d, stride=%d, format=%x", __FUNCTION__, lcdev->previewWidth, lcdev->previewHeight, stride, format);
#endif
    if (lcdev->window == NULL) {
        return;
    }

    int32_t stride;
    buffer_handle_t *bufHandle = NULL;
    int ret = lcdev->window->dequeue_buffer(lcdev->window, &bufHandle, &stride);
    if (ret != NO_ERROR) {
        LOGE("%s: ERROR dequeueing the buffer", __FUNCTION__);
        return;
    }

    ret = lcdev->window->lock_buffer(lcdev->window, bufHandle);
    if (ret != NO_ERROR) {
        LOGE("%s: ERROR locking the buffer", __FUNCTION__);
        lcdev->window->cancel_buffer(lcdev->window, bufHandle);
        return;
    }

    int tries = 5;
    void *vaddr;
    do {
        ret = lcdev->gralloc->lock(lcdev->gralloc, *bufHandle,
                GRALLOC_USAGE_SW_WRITE_OFTEN | GRALLOC_USAGE_HW_TEXTURE | GRALLOC_USAGE_HW_RENDER,
                0, 0, lcdev->previewWidth, lcdev->previewHeight, &vaddr);
        tries--;
        if (ret) {
            LOGW("%s: gralloc lock retry", __FUNCTION__);
            usleep(1000);
        }
    } while (ret && tries > 0);

    if (ret) {
        LOGE("%s: could not lock gralloc buffer", __FUNCTION__);
    } else {
        // The data we get is in YUV... but Window is RGB565. It needs to be converted
        switch (format) {
            case Overlay::FORMAT_YUV422I:
                Yuv422iToYV12((unsigned char*)vaddr, (unsigned char*)frame, lcdev->previewWidth, lcdev->previewHeight, stride);
                break;
            case Overlay::FORMAT_YUV420SP:
                memcpy(vaddr, frame, lcdev->previewWidth * lcdev->previewHeight * 1.5);
                break;
            default:
                LOGE("%s: Unknown video format, cannot convert!", __FUNCTION__);
        }
        lcdev->gralloc->unlock(lcdev->gralloc, *bufHandle);
    }

    if (lcdev->window->enqueue_buffer(lcdev->window, bufHandle) != 0) {
        LOGE("%s: could not enqueue gralloc buffer", __FUNCTION__);
    }
}

static void overlayQueueBuffer(void *data, void *buffer, size_t size) {
    long long now = systemTime();
    if ((now - mLastPreviewTime) > (mThrottlePreview ?
            MIN_PREVIEW_FRAME_INTERVAL_THROTTLED : MIN_PREVIEW_FRAME_INTERVAL)) {
        mLastPreviewTime = now;
        if (data != NULL && buffer != NULL) {
            legacy_camera_device *lcdev = (legacy_camera_device *) data;
            Overlay::Format format = (Overlay::Format) lcdev->overlay->getFormat();
            processPreviewData((char*)buffer, size, lcdev, format);
        }
    }
}

static void flashRedLed(bool enable) {
    int fd = ::open("/sys/class/leds/red/brightness", O_WRONLY);
    if (fd >= 0) {
        const char *value = enable ? "255" : "0";
        write(fd, value, strlen(value));
        close(fd);
    }
}

static camera_memory_t* genClientData(legacy_camera_device *lcdev, const sp<IMemory> &dataPtr) {
    ssize_t          offset;
    size_t           size;
    camera_memory_t *clientData = NULL;
    sp<IMemoryHeap> mHeap = dataPtr->getMemory(&offset, &size);

    LOGV("%s: offset:%#x size:%#x base:%p", __FUNCTION__,
            (unsigned)offset, size, mHeap != NULL ? mHeap->base() : 0);

    clientData = lcdev->request_memory(-1, size, 1, lcdev->user);
    if (clientData != NULL) {
        LOGV("%s: clientData=%p clientData->data=%p", __FUNCTION__, clientData, clientData->data);
        memcpy(clientData->data, (char *)(mHeap->base()) + offset, size);
    } else {
        LOGV("%s: ERROR allocating memory from client", __FUNCTION__);
    }
    return clientData;
}

static void dataCallback(int32_t msgType, const sp<IMemory>& dataPtr, void *user) {
    struct legacy_camera_device *lcdev = (struct legacy_camera_device *) user;

    LOGV("%s: msgType:%d user:%p", __FUNCTION__, msgType, user);

    if (lcdev->data_callback != NULL && lcdev->request_memory != NULL) {
        if (lcdev->clientData != NULL) {
            lcdev->clientData->release(lcdev->clientData);
        }
        lcdev->clientData = genClientData(lcdev, dataPtr);
        if (lcdev->clientData != NULL) {
            LOGV("%s: Posting data to client", __FUNCTION__);
            lcdev->data_callback(msgType, lcdev->clientData, 0, NULL, lcdev->user);
        }
    }

    if (msgType == CAMERA_MSG_PREVIEW_FRAME && lcdev->overlay == NULL) {
        ssize_t offset;
        size_t  size;
        sp<IMemoryHeap> mHeap = dataPtr->getMemory(&offset, &size);
        char* buffer = (char*) mHeap->getBase() + offset;

        LOGV("%s: preview size = %dx%d", __FUNCTION__, lcdev->previewWidth, lcdev->previewHeight);
        processPreviewData(buffer, size, lcdev, lcdev->previewFormat);
    }
}

static void dataTimestampCallback(nsecs_t timestamp, int32_t msgType, const sp<IMemory>& dataPtr, void *user) {
    struct legacy_camera_device *lcdev = (struct legacy_camera_device *) user;

    LOGV("%s: timestamp:%lld msg_type:%d user:%p",
            __FUNCTION__, timestamp /1000, msgType, user);
    int framesSent = lcdev->sentFrames.size();
    if (framesSent > PREVIEW_THROTTLE_THRESHOLD) {
        mThrottlePreview = true;
        LOGV("%s: preview throttled (fr. queued/throttle thres.: %d/%d)",
                    __FUNCTION__, framesSent, PREVIEW_THROTTLE_THRESHOLD);
        if ((!mPreviousVideoFrameDropped && framesSent > SOFT_DROP_THRESHOLD)
                || framesSent > HARD_DROP_THRESHOLD) {
            flashRedLed(true);
            LOGV("Frame has to be dropped! (fr. queued/soft thres./hard thres.: %d/%d/%d)",
                    framesSent, SOFT_DROP_THRESHOLD, HARD_DROP_THRESHOLD);
            mPreviousVideoFrameDropped = true;
            mNumVideoFramesDropped++;
            lcdev->hwif->releaseRecordingFrame(dataPtr);
            return;
        }
    } else {
        mThrottlePreview = false;
    }

    if (lcdev->data_timestamp_callback != NULL && lcdev->request_memory != NULL) {
        camera_memory_t *mem = genClientData(lcdev, dataPtr);
        if (mem != NULL) {
            LOGV("%s: Posting data to client timestamp:%lld", __FUNCTION__, systemTime());
            lcdev->sentFrames.push_back(mem);
            lcdev->data_timestamp_callback(timestamp, msgType, mem, /*index*/0, lcdev->user);
            lcdev->hwif->releaseRecordingFrame(dataPtr);
            if (mPreviousVideoFrameDropped) {
                flashRedLed(false);
                mPreviousVideoFrameDropped = false;
            }
        } else {
            LOGV("%s: ERROR allocating memory from client", __FUNCTION__);
        }
    }
}

static void notifyCallback(int32_t msgType, int32_t ext1, int32_t ext2, void *user) {
    struct legacy_camera_device *lcdev = (struct legacy_camera_device *) user;

    if (NULL == lcdev) {
        return;
    }

    LOGV("%s: msg_type:%d ext1:%d ext2:%d user:%p", __FUNCTION__, msgType, ext1, ext2, user);
    if (lcdev->notify_callback != NULL) {
        lcdev->notify_callback(msgType, ext1, ext2, lcdev->user);
    }
}

static void CameraHAL_FixupParams(CameraParameters &settings)
{
#ifdef MOTOROLA_CAMERA
    // Milestone2 camera doesn't support YUV420sp video... it advertises so, but then sends YUV422I-yuyv data
    settings.set(CameraParameters::KEY_VIDEO_FRAME_FORMAT, CameraParameters::PIXEL_FORMAT_YUV422I);
    settings.set(CameraParameters::KEY_PREFERRED_PREVIEW_SIZE_FOR_VIDEO, "848x480");

/*  empty KEY_SUPPORTED_VIDEO_SIZES indicates that the video resolution
    should be set via the preview resolution.
    Milestone's camera:
    video-size-values: 176x144,320x240,352x288,640x480,720x480,720x576,1280x720
    preview-size-values: 176x144,320x240,352x288,640x480,720x480,720x576,848x480
    So let's return an empty list to allow the 848x480 video recording. */
    settings.set(CameraParameters::KEY_SUPPORTED_VIDEO_SIZES, "");
    LOGD("Parameters fixed up");
#endif
}

inline void destroyOverlay(legacy_camera_device *lcdev) {
    if (lcdev->overlay != NULL) {
        lcdev->hwif->setOverlay(NULL);
        lcdev->overlay = NULL;
    }
}

static void releaseCameraFrames(legacy_camera_device *lcdev)
{
    vector<camera_memory_t*>::iterator it;
    for (it = lcdev->sentFrames.begin(); it < lcdev->sentFrames.end(); ++it) {
        camera_memory_t *mem = *it;
        LOGV("%s: releasing mem->data:%p", __FUNCTION__, mem->data);
        mem->release(mem);
    }
    lcdev->sentFrames.clear();
}

/* Hardware Camera interface handlers. */
static int camera_set_preview_window(struct camera_device * device, struct preview_stream_ops *window) {
    int rv = -EINVAL;
    struct legacy_camera_device *lcdev = to_lcdev(device);

    LOGV("%s: Window:%p", __FUNCTION__, window);
    if (device == NULL) {
        LOGE("%s: Invalid device.", __FUNCTION__);
        return -EINVAL;
    }

    if (lcdev->window == window) {
        // reconfigure the old window, preview size might have changed
        LOGV("%s: reconfiguring window", __FUNCTION__);
        destroyOverlay(lcdev);
    }

    lcdev->window = window;
    if (window == NULL) {
        // It means we need to release old window
        LOGV("%s: releasing previous window", __FUNCTION__);
        destroyOverlay(lcdev);
        return NO_ERROR;
    }
    LOGV("%s : OK window is %p", __FUNCTION__, window);

    if (!lcdev->gralloc) {
        hw_module_t const* module;
        int err = 0;
        if (hw_get_module(GRALLOC_HARDWARE_MODULE_ID, &module) == 0) {
            lcdev->gralloc = (const gralloc_module_t *)module;
            LOGD("%s: loaded gralloc, module name=%s; author=%s", __FUNCTION__, module->name, module->author);
        } else {
            LOGE("%s: Fail on loading gralloc HAL", __FUNCTION__);
        }
    }
    LOGV("%s: OK on loading gralloc HAL", __FUNCTION__);

    int min_bufs = -1;
    if (window->get_min_undequeued_buffer_count(window, &min_bufs)) {
        LOGE("%s: could not retrieve min undequeued buffer count", __FUNCTION__);
        return -1;
    }

    LOGV("%s: min bufs:%i", __FUNCTION__, min_bufs);

    int kBufferCount = min_bufs + 2;
    LOGV("%s: setting buffer count to %i", __FUNCTION__, kBufferCount);
    if (window->set_buffer_count(window, kBufferCount)) {
        LOGE("%s: could not set buffer count", __FUNCTION__);
        return -1;
    }

    CameraParameters params(lcdev->hwif->getParameters());
    params.getPreviewSize(&lcdev->previewWidth, &lcdev->previewHeight);

    const char *previewFormat = params.getPreviewFormat();
    LOGD("%s: preview format %s", __FUNCTION__, previewFormat);
    lcdev->previewFormat = Overlay::getFormatFromString(previewFormat);

    if (window->set_usage(window, GRALLOC_USAGE_SW_WRITE_OFTEN | GRALLOC_USAGE_SW_READ_OFTEN)) {
        LOGE("%s: could not set usage on gralloc buffer", __FUNCTION__);
        return -1;
    }

    if (window->set_buffers_geometry(window, lcdev->previewWidth, lcdev->previewHeight, HAL_PIXEL_FORMAT_YV12)) {
        LOGE("%s: could not set buffers geometry", __FUNCTION__);
        return -1;
    }

    if (lcdev->hwif->useOverlay()) {
        LOGI("%s: Using overlay for device %p", __FUNCTION__, lcdev);
        lcdev->overlay = new Overlay(lcdev->previewWidth, lcdev->previewHeight,
                Overlay::FORMAT_YUV422I, overlayQueueBuffer, (void*) lcdev);
        lcdev->hwif->setOverlay(lcdev->overlay);
    }

    return NO_ERROR;
}

static void camera_set_callbacks(struct camera_device * device,
                      camera_notify_callback notify_cb,
                      camera_data_callback data_cb,
                      camera_data_timestamp_callback data_cb_timestamp,
                      camera_request_memory get_memory, void *user)
{
    struct legacy_camera_device *lcdev = to_lcdev(device);
    LOGV("%s: notify_cb: %p, data_cb: %p data_cb_timestamp: %p, get_memory: %p, user :%p",
            __FUNCTION__, notify_cb, data_cb, data_cb_timestamp, get_memory, user);

    lcdev->notify_callback = notify_cb;
    lcdev->data_callback = data_cb;
    lcdev->data_timestamp_callback = data_cb_timestamp;
    lcdev->request_memory = get_memory;
    lcdev->user = user;

    lcdev->hwif->setCallbacks(notifyCallback, dataCallback, dataTimestampCallback, lcdev);
}

static void camera_enable_msg_type(struct camera_device * device, int32_t msg_type) {
    struct legacy_camera_device *lcdev = to_lcdev(device);
    LOGV("%s: msg_type:%d\n", __FUNCTION__, msg_type);
    lcdev->hwif->enableMsgType(msg_type);
}

static void camera_disable_msg_type(struct camera_device * device, int32_t msg_type) {
    struct legacy_camera_device *lcdev = to_lcdev(device);
    LOGV("%s: msgType:%d\n", __FUNCTION__, msg_type);
    if (msg_type == CAMERA_MSG_VIDEO_FRAME) {
        LOGV("%s: releasing stale video frames", __FUNCTION__);
        releaseCameraFrames(lcdev);
    }
    lcdev->hwif->disableMsgType(msg_type);
}

static int camera_msg_type_enabled(struct camera_device * device, int32_t msg_type) {
    struct legacy_camera_device *lcdev = to_lcdev(device);
    LOGV("%s: msgType:%d\n", __FUNCTION__, msg_type);
    return lcdev->hwif->msgTypeEnabled(msg_type);
}

static int camera_start_preview(struct camera_device * device) {
    struct legacy_camera_device *lcdev = to_lcdev(device);
    LOGV("%s:\n", __FUNCTION__);
    return lcdev->hwif->startPreview();
}

static void camera_stop_preview(struct camera_device * device) {
    struct legacy_camera_device *lcdev = to_lcdev(device);
    LOGV("%s:\n", __FUNCTION__);
    lcdev->hwif->stopPreview();
    return;
}

static int camera_preview_enabled(struct camera_device * device) {
    struct legacy_camera_device *lcdev = to_lcdev(device);
    int ret = lcdev->hwif->previewEnabled();
    LOGV("%s: %d\n", __FUNCTION__, ret);
    return ret;
}

static int camera_store_meta_data_in_buffers(struct camera_device * device, int enable) {
    LOGV("%s:\n", __FUNCTION__);
    return INVALID_OPERATION;
}

static int camera_start_recording(struct camera_device * device) {
    struct legacy_camera_device *lcdev = to_lcdev(device);
    mNumVideoFramesDropped = 0;
    mPreviousVideoFrameDropped = false;
    mThrottlePreview = false;
    LOGV("%s:", __FUNCTION__);
    lcdev->hwif->startRecording();
    return NO_ERROR;
}

static void camera_stop_recording(struct camera_device * device) {
    struct legacy_camera_device *lcdev = to_lcdev(device);
    LOGI("%s: Number of frames dropped by CameraHAL: %d", __FUNCTION__, mNumVideoFramesDropped);
    mThrottlePreview = false;
    flashRedLed(false);
    lcdev->hwif->stopRecording();
}

static int camera_recording_enabled(struct camera_device * device) {
    struct legacy_camera_device *lcdev = to_lcdev(device);
    LOGV("%s:\n", __FUNCTION__);
    return lcdev->hwif->recordingEnabled() ? 1 : 0;
}

static void camera_release_recording_frame(struct camera_device * device, const void *opaque) {
    struct legacy_camera_device *lcdev = to_lcdev(device);
    LOGV("%s: opaque: %p", __FUNCTION__, opaque);
    if (opaque != NULL) {
        vector<camera_memory_t*>::iterator it;
        for (it = lcdev->sentFrames.begin(); it != lcdev->sentFrames.end(); ++it) {
            camera_memory_t *mem = *it;
            if (mem->data == opaque) {
                LOGV("%s: found, removing", __FUNCTION__);
                mem->release(mem);
                lcdev->sentFrames.erase(it);
                break;
            }
        }
    }
}

static int camera_auto_focus(struct camera_device * device) {
    struct legacy_camera_device *lcdev = to_lcdev(device);
    LOGV("%s:\n", __FUNCTION__);
    lcdev->hwif->autoFocus();
    return NO_ERROR;
}

static int camera_cancel_auto_focus(struct camera_device * device) {
    struct legacy_camera_device *lcdev = to_lcdev(device);
    LOGV("%s:\n", __FUNCTION__);
    lcdev->hwif->cancelAutoFocus();
    return NO_ERROR;
}

static int camera_take_picture(struct camera_device * device) {
    struct legacy_camera_device *lcdev = to_lcdev(device);
    LOGV("%s:\n", __FUNCTION__);
    lcdev->hwif->takePicture();
    return NO_ERROR;
}

static int camera_cancel_picture(struct camera_device * device) {
    struct legacy_camera_device *lcdev = to_lcdev(device);
    LOGV("%s:\n", __FUNCTION__);
    lcdev->hwif->cancelPicture();
    return NO_ERROR;
}

static int camera_set_parameters(struct camera_device * device, const char *params) {
    struct legacy_camera_device *lcdev = to_lcdev(device);
    String8 s(params);
    CameraParameters p(s);
    log_camera_params(__FUNCTION__, s);
    lcdev->hwif->setParameters(p);
    return NO_ERROR;
}

static char* camera_get_parameters(struct camera_device * device) {
    struct legacy_camera_device *lcdev = to_lcdev(device);
    char *rc = NULL;
    CameraParameters params(lcdev->hwif->getParameters());
    CameraHAL_FixupParams(params);
    log_camera_params(__FUNCTION__, params);
    rc = strdup((char *)params.flatten().string());
    return rc;
}

static void camera_put_parameters(struct camera_device *device, char *params) {
    if (params != NULL) {
        free(params);
    }
}

static int camera_send_command(struct camera_device * device, int32_t cmd, int32_t arg0, int32_t arg1) {
    struct legacy_camera_device *lcdev = to_lcdev(device);
    LOGV("%s: cmd:%d arg0:%d arg1:%d\n", __FUNCTION__, cmd, arg0, arg1);
    return lcdev->hwif->sendCommand(cmd, arg0, arg1);
}

static void camera_release(struct camera_device * device) {
    struct legacy_camera_device *lcdev = to_lcdev(device);
    LOGV("%s:\n", __FUNCTION__);
    destroyOverlay(lcdev);
    releaseCameraFrames(lcdev);
    if (lcdev->clientData != NULL) {
        lcdev->clientData->release(lcdev->clientData);
        lcdev->clientData = NULL;
    }
    lcdev->hwif->release();
}

static int camera_dump(struct camera_device * device, int fd) {
    struct legacy_camera_device *lcdev = to_lcdev(device);
    LOGV("%s:\n", __FUNCTION__);
    Vector<String16> args;
    return lcdev->hwif->dump(fd, args);
}

static int camera_device_close(hw_device_t* device) {
    struct camera_device * hwdev = reinterpret_cast<struct camera_device *>(device);
    struct legacy_camera_device *lcdev = to_lcdev(hwdev);
    int rc = -EINVAL;
    LOGD("%s:\n", __FUNCTION__);
    if (lcdev != NULL) {
        camera_device_ops_t *camera_ops = lcdev->device.ops;
        if (camera_ops) {
            if (lcdev->hwif != NULL) {
                lcdev->hwif.clear();
            }
            free(camera_ops);
        }
        free(lcdev);
        rc = NO_ERROR;
    }
    return rc;
}

static int camera_device_open(const hw_module_t* module, const char* name, hw_device_t** device) {
    int ret;
    struct legacy_camera_device *lcdev;
    camera_device_t* camera_device;
    camera_device_ops_t* camera_ops;

    if (name == NULL) {
        return 0;
    }

    int cameraId = atoi(name);

    LOGD("%s: name:%s device:%p cameraId:%d\n", __FUNCTION__, name, device, cameraId);

    lcdev = (struct legacy_camera_device *) calloc(1, sizeof(*lcdev));
    if (lcdev == NULL) {
        return -ENOMEM;
    }

    camera_ops = (camera_device_ops_t *) calloc(1, sizeof(*camera_ops));
    if (camera_ops == NULL) {
        free(lcdev);
        return -ENOMEM;
    }

    lcdev->device.common.tag               = HARDWARE_DEVICE_TAG;
    lcdev->device.common.version           = 0;
    lcdev->device.common.module            = (hw_module_t *) module;
    lcdev->device.common.close             = camera_device_close;
    lcdev->device.ops                      = camera_ops;

    camera_ops->set_preview_window         = camera_set_preview_window;
    camera_ops->set_callbacks              = camera_set_callbacks;
    camera_ops->enable_msg_type            = camera_enable_msg_type;
    camera_ops->disable_msg_type           = camera_disable_msg_type;
    camera_ops->msg_type_enabled           = camera_msg_type_enabled;
    camera_ops->start_preview              = camera_start_preview;
    camera_ops->stop_preview               = camera_stop_preview;
    camera_ops->preview_enabled            = camera_preview_enabled;
    camera_ops->store_meta_data_in_buffers = camera_store_meta_data_in_buffers;
    camera_ops->start_recording            = camera_start_recording;
    camera_ops->stop_recording             = camera_stop_recording;
    camera_ops->recording_enabled          = camera_recording_enabled;
    camera_ops->release_recording_frame    = camera_release_recording_frame;
    camera_ops->auto_focus                 = camera_auto_focus;
    camera_ops->cancel_auto_focus          = camera_cancel_auto_focus;
    camera_ops->take_picture               = camera_take_picture;
    camera_ops->cancel_picture             = camera_cancel_picture;

    camera_ops->set_parameters             = camera_set_parameters;
    camera_ops->get_parameters             = camera_get_parameters;
    camera_ops->put_parameters             = camera_put_parameters;
    camera_ops->send_command               = camera_send_command;
    camera_ops->release                    = camera_release;
    camera_ops->dump                       = camera_dump;

    lcdev->id = cameraId;
#ifdef BOARD_USE_FROYO_LIBCAMERA
    lcdev->hwif = openCameraHardware(cameraId);
#else
    lcdev->hwif = HAL_openCameraHardware(cameraId);
#endif
    if (lcdev->hwif == NULL) {
        free(camera_ops);
        free(lcdev);
        return -EIO;
    }

    *device = &lcdev->device.common;
    return NO_ERROR;
}

#ifdef BOARD_USE_FROYO_LIBCAMERA
static int get_number_of_cameras(void) {
    LOGV("%s", __FUNCTION__);
    return 1;
}
#endif

static int get_camera_info(int camera_id, struct camera_info *info) {
    LOGV("%s", __FUNCTION__);
    int rv = 0;

#ifdef BOARD_USE_FROYO_LIBCAMERA
    info->facing = CAMERA_FACING_BACK;
    info->orientation = 90;
#else
    CameraInfo cam_info;
    HAL_getCameraInfo(camera_id, &cam_info);

    info->facing = cam_info.facing;
#ifdef MOTOROLA_CAMERA
    info->orientation = 90; // Milestone2 camera returns 0, but then picture is rotated
#else
    info->orientation = cam_info.orientation;
#endif
#endif //BOARD_USE_FROYO_LIBCAMERA

    LOGD("%s: id:%i faceing:%i orientation: %i", __FUNCTION__, camera_id, info->facing, info->orientation);

    return rv;
}

} /* namespace android */

static hw_module_methods_t camera_module_methods = {
    open: android::camera_device_open
};

camera_module_t HAL_MODULE_INFO_SYM = {
    common: {
        tag: HARDWARE_MODULE_TAG,
        version_major: 1,
        version_minor: 1,
        id: CAMERA_HARDWARE_MODULE_ID,
        name: "Camera HAL for ICS/CM9",
        author: "Won-Kyu Park, Raviprasad V Mummidi, Ivan Zupan, rondoval",
        methods: &camera_module_methods,
        dso: NULL,
        reserved: {0},
    },
#ifdef BOARD_USE_FROYO_LIBCAMERA
    get_number_of_cameras: android::get_number_of_cameras,
#else
    get_number_of_cameras: android::HAL_getNumberOfCameras,
#endif
    get_camera_info: android::get_camera_info,
};

