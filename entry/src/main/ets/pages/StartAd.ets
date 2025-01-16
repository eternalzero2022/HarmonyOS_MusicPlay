import window from '@ohos.window';
import router from '@ohos.router';
@Entry
@Component
struct StartAd {
  @State timer: number = -1;
  @State countdown: number = 5; // 响应式
  aboutToAppear() {

  }
  onPageShow(): void {
    this.getStartAd(); // 否则启动倒计时

  }
  aboutToDisappear(): void {
    clearInterval(this.timer);
  }

  getStartAd() {
    this.timer = setInterval(() => {
      if (this.countdown > 0) {
        this.countdown -= 1; // 每秒递减1
      } else {
        clearInterval(this.timer); // 停止定时器
        router.replaceUrl({url:'pages/Index'});
      }
    }, 1000);
  }

  build() {
    Stack() {
      Image($r('app.media.advertisement'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover) // 使图片覆盖整个屏幕
        .onClick(() => {
          router.replaceUrl({url: 'pages/WebView'});
        })

      Text(`${this.countdown}秒 | 跳过广告`) // 绑定countdown属性的值
        .padding({ left: 10, right: 10 })
        .position({x:250,y:1})
        .margin({ right: 20, top: 20 }) // 调整margin使文本在右上角显示
        .height(30)
        .fontSize(14)
        .borderRadius(15)
        .backgroundColor('#66F4F4F4')
        .textAlign(TextAlign.Center)
        .onClick(() => {
          clearInterval(this.timer); // 停止定时器
          router.replaceUrl({url: 'pages/Index'});
        })
        .zIndex(1) // 确保Text组件在最上层
    }
    .height('100%')
    .width('100%')
  }
}