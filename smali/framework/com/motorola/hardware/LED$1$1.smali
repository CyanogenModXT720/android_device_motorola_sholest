.class Lcom/motorola/hardware/LED$1$1;
.super Ljava/lang/Object;
.source "LED.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/motorola/hardware/LED$1;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/motorola/hardware/LED$1;


# direct methods
.method constructor <init>(Lcom/motorola/hardware/LED$1;)V
    .registers 2
    .parameter

    .prologue
    .line 75
    iput-object p1, p0, Lcom/motorola/hardware/LED$1$1;->this$1:Lcom/motorola/hardware/LED$1;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 1

    .prologue
    .line 76
    invoke-static {}, Lcom/motorola/hardware/LED;->button_leds_disable()I

    .line 77
    return-void
.end method
