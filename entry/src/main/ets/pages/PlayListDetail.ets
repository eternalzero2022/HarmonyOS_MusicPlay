import { AxiosResponse } from '@ohos/axios';
import { deleteList, EmptyPlayList, getPlayListById, playList, removeMusic, TestPlayList } from '../api/playlist';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { router } from '@kit.ArkUI';
import { Constants } from '../constants/Constants';
import { EmptyMusic, Music } from '../viewmodel/MusicViewModel';
import { getMusicById } from '../api/music';
import { AVPlayerManager } from '../manager/AVPlayerManager';

@Entry
@Component
struct PlayListDetail {

  @State listid: number = (router.getParams() as Record<string,number>)['listId']
  playlist:playList = TestPlayList

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

  dialogController: CustomDialogController = new CustomDialogController({
    builder: DeletePlayList({
      type:'歌单',
      delete:()=>{
        router.back()
        this.deletePlayList()
      }
    }),
  })

  async deletePlayList(){
    await deleteList(this.listid).then((res:AxiosResponse)=>{
      if(res.data.code!=='200'){
        hilog.error(0x00002,'PLAYLIST','删除歌单失败')
        this.dialogController.close()
        router.back()
      }
      else{
        router.back()
      }
      router.back()
    })
  }

  async setMusicList(){
    let avPlayer = await AVPlayerManager.getInstance()

  }

  @Builder itemHead() {
    // 列表分组的头部组件
    Row() {
      Image($r('app.media.startplaylist'))
        .height(40)
        .width(50)
        .borderRadius(10)
        .margin(20)
      
      Text('全部播放')
        .fontSize(20)
    }
    .width('100%')
    .backgroundColor(Color.White)
  }


  build() {
    Column() {
      Row() {
        Image($r('app.media.back'))
          .width(40)
          .height(40)
          .margin(10)
          .onClick(() => {
            router.back()
          })

        Image($r('app.media.delete'))
          .width(30)
          .height(30)
          .margin(10)
          .onClick(()=>{
            this.dialogController.open()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      List() {
        ListItem() {
          Column() {
            Row() {
              Image(this.playlist.imageUrl === '' ? Constants.DEFAULT_MUSIC_IMAGE : this.playlist.imageUrl)
                .width(130)
                .height(130)
                .margin(20)

              Column() {
                Row() {
                  Text(this.playlist.listName === '' ? 'test' : this.playlist.listName)
                    .fontSize(40)
                }
                .height('50%')
                .alignItems(VerticalAlign.Top)

                Text('creatorName')
              }
              .height(130)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
          }
        }

        ListItemGroup({ header: this.itemHead(), space: 20 }) {
          ForEach(this.playlist.musicIds, (item: number,index:number) => {
            ListItem() {
              musicItem({ musicId: item , index: index + 1 , listId:this.listid})
            }
          })
        }
      }
      .height('90%')
      .sticky(StickyStyle.Header)
    }
  }
}

@Component
struct musicItem{
  @Prop listId:number = 0
  @Prop musicId:number = 0
  @Prop index: number = 0 // 用来传递次序
  dialogController: CustomDialogController = new CustomDialogController({
    builder: DeletePlayList({
      type:'歌曲',
      delete:()=>{
        router.back()
        this.deleteMusic()
      }
    }),
  })
  music:Music = EmptyMusic

  async aboutToAppear(){
    await getMusicById(this.musicId).then((res:AxiosResponse)=>{
      if(res.data.code === '200'){
        this.music = res.data.result
      }
      else{
        hilog.error(0x00002,'MUSIC','获取歌曲失败')
      }
    })
  }

  async deleteMusic(){
    await removeMusic({ id:0,music_id:this.musicId,list_id: this.listId}).then((res:AxiosResponse)=>{
      if(res.data.code!=='200'){
        hilog.error(0x00002,'PLAYLIST','删除歌曲失败')
      }
      else{
        router.back()
      }
    })
  }

  build() {
    Row(){
      Column(){
        Text(this.index+'')
          .fontSize(20)
      }
      .width('20%')

      Column(){

        Text(this.music.musicName)
          .fontSize(20)

        Text(this.music.singer)
      }
      .alignItems(HorizontalAlign.Start)
      .width('55%')

      Column() {
        Image($r('app.media.remove'))
          .width(20)
          .height(20)
          .onClick(()=>{
            this.dialogController.open()
          })
      }
       .width('20%')
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height(40)
  }
}

@CustomDialog
struct DeletePlayList {
  type?:string = ''
  delete?: () => void
  controller: CustomDialogController = new CustomDialogController({
    builder: DeletePlayList({}),
  })

  build() {
    Row(){
      Column(){
        Text('确认要删除此'+this.type)
          .fontSize(20)

        Blank().height(20)

        Row(){
          Text('删除')
            .fontColor(Color.Red)
            .fontSize(20)
            .onClick(()=>{
              this.controller.close()
              if (this.delete) {
                this.delete()
              }
            })

          Text('取消')
            .fontSize(20)
            .onClick(()=>{
              this.controller.close()
            })
        }
        .justifyContent(FlexAlign.SpaceAround)
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .height(150)
  }
}