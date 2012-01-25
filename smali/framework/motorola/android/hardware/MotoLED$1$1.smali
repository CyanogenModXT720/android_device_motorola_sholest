.class Lmotorola/android/hardware/MotoLED$1$1;
.super Ljava/lang/Object;
.source "MotoLED.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lmotorola/android/hardware/MotoLED$1;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lmotorola/android/hardware/MotoLED$1;


# direct methods
.method constructor <init>(Lmotorola/android/hardware/MotoLED$1;)V
    .registers 2
    .parameter

    .prologue
    .line 73
    iput-object p1, p0, Lmotorola/android/hardware/MotoLED$1$1;->this$1:Lmotorola/android/hardware/MotoLED$1;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 1

    .prologue
    .line 74
    invoke-static {}, Lmotorola/android/hardware/MotoLED;->button_leds_disable()I

    .line 75
    return-void
.end method
