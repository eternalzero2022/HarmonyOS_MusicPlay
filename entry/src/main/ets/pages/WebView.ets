import { webview } from '@kit.ArkWeb';
import router  from '@ohos.router';

@Entry
@Component
export struct WebView{
  private webviewController: webview.WebviewController = new webview.WebviewController();
  build() {
    Column() {
      Web({ src: ('m.taobao.com'), controller: this.webviewController })
        .height(735)
        .domStorageAccess(true)
    }
  }
  onBackPress(): boolean | void {
    router.replaceUrl({url:'pages/Index'})
    return true
  }
}
