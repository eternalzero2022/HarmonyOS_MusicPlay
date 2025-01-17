import { router } from '@kit.ArkUI';

@Entry
@Component
struct CreatePlayList {
  @State message: string = 'Hello World';


  onPageShow(): void {
    const params = this.getUIContext().getRouter().getParams() as Record<string,string>;
    if(params){
      //更新当前的图片的uri
      if(params.picUri){
        this.message = params.picUri;
      }
    }
  }

  build() {
    Column(){
      Text(this.message)
        .id('HelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Center)
      Button("选择一张图片")
        .alignSelf(ItemAlign.Center)
        .onClick(()=>{
          router.pushUrl({
            url: 'pages/PhotoPicker'
          })
        })
    }.width('100%').alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)
  }
}