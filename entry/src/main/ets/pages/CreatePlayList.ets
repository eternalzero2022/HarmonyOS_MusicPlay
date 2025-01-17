import { router } from '@kit.ArkUI';
import { createPlayList, EmptyPlayList, NewPlayList, playList } from '../api/playlist';
import { fetchMediaData } from '../manager/MediaDataHandler';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AxiosResponse } from '@ohos/axios';
import { uploadImage } from '../api/tools';

@Entry
@Component
struct CreatePlayList {
  @State message: string = 'Hello World'
  @State listName: string = '新建歌单'
  @State imageUrl: string = ''


  onPageShow(): void {
    const params = this.getUIContext().getRouter().getParams() as Record<string,string>;
    if(params){
      //更新当前的图片的uri
      if(params.picUri){
        //获取图片数据，类型为ArrayBuffer
        fetchMediaData(params.picUri, async (data: ArrayBuffer)=>{
          await uploadImage(data).then((res:AxiosResponse)=>{
            if(res.data.code === '200'){
              this.imageUrl = res.data.result
              hilog.error(0x00002,'PLAYLIST',this.imageUrl)
            }
            else{
              hilog.error(0x00002,'PLAYLIST','上传失败')
            }
          })
        })
      }
    }
  }

  async create(){
    let newplaylist: playList = NewPlayList
    newplaylist.listName = this.listName
    newplaylist.imageUrl = this.imageUrl
    await createPlayList(newplaylist).then((res:AxiosResponse)=>{
      if(res.data.code === '200'){
        router.pushUrl({url:'pages/Index',params:{index:1}})
      }
      else{
        hilog.error(0x00002,'PLAYLIST','创建失败')
      }
    })
  }

  build() {
    Column(){
      Blank().height(5)
      Row() {
        Text('创建歌单')
          .fontSize(25)
      }
      .width('100%')
      .height('20%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Top)

      Row(){
        Column() {
          Text('请输入歌单名称')
          Blank().height(20)
          TextInput({text:this.listName})
            .maxLength(20)
            .onChange((value:string)=>{
              this.listName = value
            })
        }
      }
      .width('80%')
      .height('20%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Column() {

          if(this.imageUrl){
            Text('当前封面')
            Blank().height(20)
            Row() {
              Image(this.imageUrl)
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Contain)

              Blank().height(10)
            }
            .justifyContent(FlexAlign.Center)
            .width('100%')
          }
          else{
            Text('请选择一张图片作为歌单封面')
            Blank().height(20)
          }

          Button("选择图片")
            .alignSelf(ItemAlign.Center)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/PhotoPicker'
              })
            })
        }
      }
      .height('40%')
      .alignItems(VerticalAlign.Top)

      Row(){
        Button('取消')
          .fontSize(20)
          .fontColor(Color.Red)
          .backgroundColor(0xF1F3F5)
          .onClick(() => {
            router.back()
          })

        Button('创建')
          .fontSize(20)
          .onClick(()=>{
            this.create()
          })

      }
      .width('60%')
      .height('20%')
      .justifyContent(FlexAlign.SpaceBetween)

    }.width('100%').alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)
  }
}