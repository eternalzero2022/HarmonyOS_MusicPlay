import { AxiosResponse } from "@ohos/axios"
import { EmptyPlayList, getFavoriteListIds, getListIds, getPlayListById, playList } from "../api/playlist"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { Constants } from "../constants/Constants"
import { router } from "@kit.ArkUI"


@Entry
@Component
export struct PlayListPage{
  listIds: number[] = [1,2,3,1,2,3,1,2,3,1,2,3,1,2,3]
  favoriteIds: number[] = [1,2,3,1,2,3,1,2,3,1,2,3,1,2,3]
  @State currentIndex: number = 0

  async aboutToAppear(){
    await getListIds().then((res:AxiosResponse)=>{
      if(res.data.code==='200'){
        this.listIds = res.data.result
      }
      else{
        hilog.error(0x00002,'PLAYLIST','获取列表id失败')
      }
    })
    await getFavoriteListIds().then((res:AxiosResponse)=>{
      if(res.data.code==='200'){
        this.favoriteIds = res.data.result
      }
      else{
        hilog.error(0x00002,'PLAYLIST','获取收藏列表id失败')
      }
    })
  }

  //自定义tabbar渲染器
  @Builder tabBuilder(title: string, targetIndex: number) {
    Column() {
      Text(title)
        .fontSize(20)
        .fontWeight(this.currentIndex === targetIndex ? FontWeight.Bold : FontWeight.Normal)

      Blank().color(Color.Black).height(2).width('50%').visibility(this.currentIndex === targetIndex ?Visibility.Visible:Visibility.Hidden)
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }

  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomDialogExample(),
  })

  build() {
    Stack() {


      Tabs() {
        TabContent() {
          Scroll() {
            Column() {
              Blank().height(10)
              List({ space: 10 }) {
                ForEach(this.listIds,(item:number)=>{
                  playListItem({listid:item})
                })
              }
            }
            .height('100%')
            .justifyContent(FlexAlign.Start)
          }
        }
        .tabBar(this.tabBuilder('自建歌单', 0))
        .backgroundColor(0xF1F3F5)

        TabContent() {
          Scroll() {
            Column() {
              Blank().height(10)
              List({ space: 10 }) {
                ForEach(this.favoriteIds,(item:number)=>{
                  playListItem({listid:item})
                })
              }
            }
            .height('100%')
            .justifyContent(FlexAlign.Start)
          }
        }
        .tabBar(this.tabBuilder('收藏歌单', 1))
        .backgroundColor(0xF1F3F5)

      }
      .onChange((index: number) => {
        this.currentIndex = index
      })


      Button({ type: ButtonType.Circle, stateEffect: false }){
        Image($r('app.media.add'))
          .width(40)
          .height(40)
      }
      .borderStyle(BorderStyle.Solid)
      .borderWidth(2)
      .width(70)
      .height(70)
      .backgroundColor(Color.White)
      .position({x: '75%', y: '85%'})
      .onClick(() => {
        this.dialogController.open()
      })

    }
  }

}

@Component
struct playListItem{
  @Prop listid: number = 0;
  playlist:playList = EmptyPlayList

  async aboutToAppear(){
    await getPlayListById(this.listid).then((res:AxiosResponse)=>{
      if(res.data.code==='200'){
        this.playlist = res.data.result
      }
      else{
        hilog.error(0x00002,'PLAYLIST','获取歌单失败')
      }
    })
  }

  build() {
    Row(){
      Image(this.playlist.imageUrl === ''? Constants.DEFAULT_MUSIC_IMAGE : this.playlist.imageUrl)
        .width(70)
        .height(70)
        .borderRadius(10)
        .margin(20)
      Text(this.playlist.listName===''?'test':this.playlist.listName)
        .fontSize(30)
    }
    .height(100)
    .width('100%')
    .backgroundColor(Color.White)
    .onClick(()=>{
      router.pushUrl({
        url:'pages/PlayListDetail',
        params: { listId : this.listid }
      })
    })
  }
}

@CustomDialog
struct CustomDialogExample {
  controller: CustomDialogController = new CustomDialogController({
    builder: CustomDialogExample({}),
  })

  build() {
    Column() {
      Blank().height('5%')
      Row() {
        Column() {
          Text('取消')
            .onClick(() => {
              this.controller.close()
            })
        }
        .alignItems(HorizontalAlign.Start)
        Column(){
          Text('创建歌单')
            .fontSize(20)
        }
        .alignItems(HorizontalAlign.Center)
        Column(){
          Text('创建')
            .onClick(() => {
              this.controller.close()
            })
        }
        .alignItems(HorizontalAlign.End)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height('15%')

      Row() {
        TextInput({ placeholder: '请输入新建歌单名称' })
          .width('100%')
      }
      .width('80%')
      .height('80%')
    }
    .width('90%')
    .height('20%')
  }
}

