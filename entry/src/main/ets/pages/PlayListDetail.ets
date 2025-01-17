import { AxiosResponse } from '@ohos/axios';
import { deleteList, EmptyPlayList,
  favorite,
  getPlayListById, playList, removeMusic,
  unFavorite } from '../api/playlist';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { router } from '@kit.ArkUI';
import { Constants } from '../constants/Constants';
import { EmptyMusic, Music } from '../viewmodel/MusicViewModel';
import { getMusicById } from '../api/music';
import { AVPlayerManager } from '../manager/AVPlayerManager';
import { PlayBar } from '../view/PlayBar';
import { EmptyUser, User } from '../viewmodel/UserModel';

@Entry
@Component
struct PlayListDetail {

  @StorageLink('user') user: User = EmptyUser
  @State listid: number = (router.getParams() as Record<string,number>)['listId']
  @State from: boolean = (router.getParams() as Record<string,boolean>)['from']
  @State isFavorite: boolean | null = false
  @State isCreator: boolean = false
  @State typemessage: string = ''
  @State playlist:playList = EmptyPlayList
  @State musicList: Music[] = []
  frash: boolean = false


  async playSong(music:Music){
    let avPlayer = await AVPlayerManager.getInstance()
    await avPlayer.playSong(music)
  }

  async aboutToAppear(){
    await getPlayListById(this.listid).then(async (res:AxiosResponse)=>{
      if(res.data.code==='200'){
        this.playlist = res.data.result
        if(this.playlist.creatorId!==this.user.id){
          this.isFavorite = this.playlist.isFavorite
          if(this.isFavorite){
            this.typemessage = '取消收藏此歌单'
          }
        }
        else{
          this.isCreator = true
          this.typemessage = '删除此歌单'
        }
        const musicIds = this.playlist.musicIds
        if (musicIds && musicIds.length > 0) {
          // 按顺序请求所有的音乐信息
          for (const id of musicIds) {
            try {
              await getMusicById(id).then((res:AxiosResponse)=>{
                if (res.data.code === '200') {
                  this.musicList.push(res.data.result) // 添加到音乐列表中
                } else {
                  hilog.error(0x00002, 'MUSIC', `获取音乐ID ${id} 失败`)
                }
              })
            } catch (error) {
              hilog.error(0x00002, 'MUSIC', `请求音乐ID ${id} 发生错误`, error)
            }
          }
        }
      }
      else{
        hilog.error(0x00002,'PLAYLIST','获取歌单失败')
      }

    })
  }

  dialogController: CustomDialogController = new CustomDialogController({
    builder: DeletePlayList({
      type:this.typemessage,
      delete:()=>{
        this.isFavorite?this.unFavoritePlayList():this.deletePlayList()
      }
    }),
  })

  async deletePlayList(){
    await deleteList(this.listid).then((res:AxiosResponse)=>{
      if(res.data.code!=='200'){
        hilog.error(0x00002,'PLAYLIST','删除歌单失败')
        this.dialogController.close()
      }
      else{
        this.frash = true
        if(this.from){
          router.pushUrl({url:'pages/Index',params:{index:1}})
        }
        else{
          router.back()
        }
      }
    })
  }

  async unFavoritePlayList(){
    await unFavorite(this.listid).then((res:AxiosResponse)=>{
      if(res.data.code!=='200'){
        hilog.error(0x00002,'PLAYLIST','取消收藏歌单失败')
        this.dialogController.close()
      }
      else{
        this.isFavorite = false
        this.frash = true
      }
    })
  }

  async favoritePlayList(){
    await favorite(this.listid).then((res:AxiosResponse)=>{
      if(res.data.code!=='200'){
        hilog.error(0x00002,'PLAYLIST','收藏歌单失败')
      }
      else{
        this.isFavorite = true
        this.frash = true
        this.typemessage = '取消收藏此歌单'
      }
    })
  }

  async deleteMusic(deleid:number){
    await removeMusic({ id:0,music_id:deleid,list_id: this.listid}).then((res:AxiosResponse)=>{
      if(res.data.code!=='200'){
        hilog.error(0x00002,'PLAYLIST','删除歌曲失败')
      }
      else{
        this.musicList = this.musicList.filter(music => music.id !== deleid)
        this.playlist.musicIds = this.playlist.musicIds.filter(id => id!==deleid)
      }
    })
  }

  async setMusicList(){
    let avPlayer = await AVPlayerManager.getInstance()
    await avPlayer.setMusicList(this.musicList)
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
    .onClick(()=>{
      this.setMusicList()
    })
  }


  build() {
    Column() {
      Row() {
        Image($r('app.media.back'))
          .width(40)
          .height(40)
          .margin(10)
          .onClick(() => {
            if(this.from){
              router.pushUrl({url:'pages/Index',params:{index:1}})
            }
            else{
              router.back()
            }
          })

        if(this.isCreator) {
          Image($r('app.media.delete'))
            .width(30)
            .height(30)
            .margin(10)
            .onClick(() => {
              this.dialogController.open()
            })
        }
        else{
          if(this.isFavorite){
            Image($r('app.media.favoritefill'))
              .width(30)
              .height(30)
              .margin(10)
              .onClick(() => {
                this.dialogController.open()
              })
          }
          else {
            Image($r('app.media.favorite'))
              .width(30)
              .height(30)
              .margin(10)
              .onClick(() => {
                this.favoritePlayList()
              })
          }
        }
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
                  Text(this.playlist.listName === '' ? 'null' : this.playlist.listName)
                    .fontSize(20)
                }
                .height('50%')
                .alignItems(VerticalAlign.Center)
              }
              .height(130)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
          }
        }

        if(this.musicList.length===0){
          ListItem(){
            Row(){
              Text('暂无歌曲')
                .fontColor(Color.Gray)
                .fontSize(30)
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .height('70%')
        }
        else {
          ListItemGroup({ header: this.itemHead(), space: 20 }) {
            ForEach(this.musicList, (item: Music, index: number) => {
              if(this.isCreator){
                ListItem() {
                  musicItem({ music: item, index: index + 1, listId: this.listid , isCreator: this.isCreator,deleteMusic:()=>{this.deleteMusic(item.id)} , playMusic:()=>{this.playSong(item)}})
                }
              }
              else{
                ListItem() {
                  musicItem({ music: item, index: index + 1, listId: this.listid ,deleteMusic:()=>{this.deleteMusic(item.id)}, playMusic:()=>{this.playSong(item)}})
                }
              }

            })
          }
        }
      }
      .height('85%')
      .sticky(StickyStyle.Header)

      PlayBar()
    }
  }
}

@Component
struct musicItem{
  @Prop listId:number = 0
  @Prop isCreator:boolean = false
  @Prop music:Music = EmptyMusic
  @Prop index: number = 0 // 用来传递次序
  deleteMusic?:()=>void
  playMusic?:()=>void

  dialogController: CustomDialogController = new CustomDialogController({
    builder: DeletePlayList({
      type:'从歌单删除此歌曲',
      delete:()=>{
        if(this.deleteMusic) {
          this.deleteMusic()
        }
      }
    }),
  })


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
          .height(20)
          .maxFontSize(20)
          .minFontSize(10)

        Text(this.music.singer)
          .fontSize(10)
          .height(10)
          .maxFontSize(10)
          .minFontSize(5)
          .fontColor(Color.Gray)
      }
      .alignItems(HorizontalAlign.Start)
      .width('65%')

      Column() {
        if(this.isCreator) {
          Image($r('app.media.remove'))
            .width(20)
            .height(20)
            .onClick(() => {
              this.dialogController.open()
            })
        }
      }
       .width('20%')
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height(40)
    .onClick(()=>{
      if(this.playMusic){
        this.playMusic()
        router.pushUrl({url: 'pages/Detail'})
      }
    })
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
        Text('确认要'+this.type)
          .fontSize(20)

        Blank().height(20)

        Row(){
          Text('确认')
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