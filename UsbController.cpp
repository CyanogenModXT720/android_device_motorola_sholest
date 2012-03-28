/*
 * Copyright (C) 2008 The Android Open Source Project
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

#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>


#include <netinet/in.h>
#include <arpa/inet.h>

#define LOG_TAG "UsbController"
#include <cutils/log.h>

#include "UsbController.h"

#define USE_xt720 "yup" // use specific xt720 usb mode switching

UsbController::UsbController() {
}

UsbController::~UsbController() {
}

int UsbController::startRNDIS() {
    LOGD("Usb RNDIS start");
    return enableRNDIS(true);
}

int UsbController::stopRNDIS() {
    LOGD("Usb RNDIS stop");
    return enableRNDIS(false);
}

int UsbController::enableRNDIS(bool enable) {

#ifndef USE_xt720

    char value[20];
#ifdef USE_HTC_USB_FUNCTION_SWITCH
    int fd = open("/sys/devices/platform/msm_hsusb/usb_function_switch", O_RDWR);
    int count = snprintf(value, sizeof(value), "%d\n", (enable ? 4 : 3));
#else

    int fd = open("/sys/class/usb_composite/rndis/enable", O_RDWR);
    int count = snprintf(value, sizeof(value), "%d\n", (enable ? 1 : 0));
#endif
    write(fd, value, count);
    close(fd);
    return 0;

#else //USE_xt720
// ok here may be will have to place pkill usbd && echo eth_adb > /dev/usb_device_mode
// but for now just return 0
// use defy way

    char buffer[128];

    snprintf(buffer, sizeof(buffer),
             "/system/bin/am broadcast -a com.motorola.intent.action.USB_TETHERING_TOGGLED --ei state %d",
             enable ? 1 : 0);
    system(buffer);
    return 0;

#endif //USE_xt720
}

bool UsbController::isRNDISStarted() {

#ifndef USE_xt720

    char value=0;
#ifdef USE_HTC_USB_FUNCTION_SWITCH
    int fd = open("/sys/devices/platform/msm_hsusb/usb_function_switch", O_RDWR);
#else
    int fd = open("/sys/class/usb_composite/rndis/enable", O_RDWR);
#endif
    read(fd, &value, 1);
    close(fd);
#ifdef USE_HTC_USB_FUNCTION_SWITCH
    return (value == '4' ? true : false);
#else
    return (value == '1' ? true : false);
#endif

#else // USE_xt720

//may be here will take place reading current mode
//but for now just return true
// use defy way

    bool rndisActive = false;
    FILE *stateFile = fopen("/tmp/usbd-state", "r");

    if (stateFile != NULL) {
        char buffer[128];

        memset(buffer, 0, sizeof(buffer));
        if (fread(buffer, 1, sizeof(buffer), stateFile) > 0) {
            LOGD("Got USBD state %s", buffer);
            rndisActive = strstr(buffer, "ngp") != NULL; //todo check phone values
        } else {
            LOGD("Could not read USBD state file (errno %d)", errno);
        }

        fclose(stateFile);
    }

    return rndisActive;


#endif


}
