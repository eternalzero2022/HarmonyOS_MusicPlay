import { router } from '@kit.ArkUI';
import { fetchMediaData } from '../manager/MediaDataHandler';

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
        
        //获取图片数据，类型为ArrayBuffer
        fetchMediaData(params.picUri, (data: ArrayBuffer)=>{console.info("获取成功")})
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