.class Lcom/motorola/hardware/LED$1;
.super Ljava/util/TimerTask;
.source "LED.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/motorola/hardware/LED;->led_timer_enable(I)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/motorola/hardware/LED;


# direct methods
.method constructor <init>(Lcom/motorola/hardware/LED;)V
    .registers 2
    .parameter

    .prologue
    .line 72
    iput-object p1, p0, Lcom/motorola/hardware/LED$1;->this$0:Lcom/motorola/hardware/LED;

    invoke-direct {p0}, Ljava/util/TimerTask;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 5

    .prologue
    .line 73
    invoke-static {}, Lcom/motorola/hardware/LED;->button_leds_enable()I

    .line 74
    iget-object v0, p0, Lcom/motorola/hardware/LED$1;->this$0:Lcom/motorola/hardware/LED;

    iget-object v0, v0, Lcom/motorola/hardware/LED;->mHandler:Landroid/os/Handler;

    new-instance v1, Lcom/motorola/hardware/LED$1$1;

    invoke-direct {v1, p0}, Lcom/motorola/hardware/LED$1$1;-><init>(Lcom/motorola/hardware/LED$1;)V

    const-wide/16 v2, 0xc8

    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    .line 79
    return-void
.end method
