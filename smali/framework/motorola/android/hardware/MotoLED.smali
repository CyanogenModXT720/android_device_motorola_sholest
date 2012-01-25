.class public Lmotorola/android/hardware/MotoLED;
.super Ljava/lang/Object;
.source "MotoLED.java"


# static fields
.field private static final TAG:Ljava/lang/String; = "MotoLED"


# instance fields
.field mHandler:Landroid/os/Handler;

.field mtimer:Ljava/util/Timer;


# direct methods
.method static constructor <clinit>()V
    .registers 4

    .prologue
    const-string v3, "MotoLED"

    .line 37
    :try_start_2
    const-string v1, "/system/lib/libmot_led.so"

    invoke-static {v1}, Ljava/lang/System;->load(Ljava/lang/String;)V

    .line 38
    const-string v1, "MotoLED"

    const-string v2, "libmot_led loaded success"

    invoke-static {v1, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_e
    .catch Ljava/lang/UnsatisfiedLinkError; {:try_start_2 .. :try_end_e} :catch_f

    .line 44
    :goto_e
    return-void

    .line 40
    :catch_f
    move-exception v1

    move-object v0, v1

    .line 41
    .local v0, ule:Ljava/lang/UnsatisfiedLinkError;
    const-string v1, "MotoLED"

    const-string v1, "libmot_led loaded failed"

    invoke-static {v3, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_e
.end method

.method public constructor <init>()V
    .registers 1

    .prologue
    .line 29
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static native button_leds_disable()I
.end method

.method public static native button_leds_enable()I
.end method

.method public static native led_set(II)I
.end method

.method public static native leds_disable_all()I
.end method

.method public static native leds_enable(I)I
.end method

.method public static native leds_enable_all()I
.end method

.method public static native set_key_backlight(I)I
.end method


# virtual methods
.method public led_timer_disable()V
    .registers 2

    .prologue
    .line 87
    iget-object v0, p0, Lmotorola/android/hardware/MotoLED;->mtimer:Ljava/util/Timer;

    if-eqz v0, :cond_9

    .line 88
    iget-object v0, p0, Lmotorola/android/hardware/MotoLED;->mtimer:Ljava/util/Timer;

    invoke-virtual {v0}, Ljava/util/Timer;->cancel()V

    .line 90
    :cond_9
    return-void
.end method

.method public led_timer_enable(I)V
    .registers 8
    .parameter "time"

    .prologue
    .line 69
    new-instance v1, Lmotorola/android/hardware/MotoLED$1;

    invoke-direct {v1, p0}, Lmotorola/android/hardware/MotoLED$1;-><init>(Lmotorola/android/hardware/MotoLED;)V

    .line 80
    .local v1, mLedTimerTask:Ljava/util/TimerTask;
    new-instance v0, Ljava/util/Timer;

    invoke-direct {v0}, Ljava/util/Timer;-><init>()V

    iput-object v0, p0, Lmotorola/android/hardware/MotoLED;->mtimer:Ljava/util/Timer;

    .line 81
    new-instance v0, Landroid/os/Handler;

    invoke-direct {v0}, Landroid/os/Handler;-><init>()V

    iput-object v0, p0, Lmotorola/android/hardware/MotoLED;->mHandler:Landroid/os/Handler;

    .line 82
    iget-object v0, p0, Lmotorola/android/hardware/MotoLED;->mtimer:Ljava/util/Timer;

    const-wide/16 v2, 0x64

    int-to-long v4, p1

    invoke-virtual/range {v0 .. v5}, Ljava/util/Timer;->schedule(Ljava/util/TimerTask;JJ)V

    .line 83
    return-void
.end method
