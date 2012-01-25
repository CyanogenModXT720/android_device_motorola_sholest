.class Lmotorola/android/hardware/MotoLED$1;
.super Ljava/util/TimerTask;
.source "MotoLED.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lmotorola/android/hardware/MotoLED;->led_timer_enable(I)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lmotorola/android/hardware/MotoLED;


# direct methods
.method constructor <init>(Lmotorola/android/hardware/MotoLED;)V
    .registers 2
    .parameter

    .prologue
    .line 70
    iput-object p1, p0, Lmotorola/android/hardware/MotoLED$1;->this$0:Lmotorola/android/hardware/MotoLED;

    invoke-direct {p0}, Ljava/util/TimerTask;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 5

    .prologue
    .line 71
    invoke-static {}, Lmotorola/android/hardware/MotoLED;->button_leds_enable()I

    .line 72
    iget-object v0, p0, Lmotorola/android/hardware/MotoLED$1;->this$0:Lmotorola/android/hardware/MotoLED;

    iget-object v0, v0, Lmotorola/android/hardware/MotoLED;->mHandler:Landroid/os/Handler;

    new-instance v1, Lmotorola/android/hardware/MotoLED$1$1;

    invoke-direct {v1, p0}, Lmotorola/android/hardware/MotoLED$1$1;-><init>(Lmotorola/android/hardware/MotoLED$1;)V

    const-wide/16 v2, 0xc8

    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    .line 77
    return-void
.end method
