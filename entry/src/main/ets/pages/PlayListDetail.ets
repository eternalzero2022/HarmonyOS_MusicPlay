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

  @StorageLink('user') user: User = EmptyUser  // 从本地存储获取用户信息
  @State listid: number = (router.getParams() as Record<string, number>)['listId']  // 获取歌单ID
  @State from: boolean = (router.getParams() as Record<string, boolean>)['from']  // 判断页面来源
  @State isFavorite: boolean | null = false  // 是否已收藏歌单
  @State isCreator: boolean = false  // 是否为歌单创建者
  @State typemessage: string = ''  // 类型信息，如：删除或收藏歌单
  @State playlist: playList = EmptyPlayList  // 歌单数据
  @State musicList: Music[] = []  // 歌单中的音乐列表


  // 播放歌曲
  async playSong(music: Music) {
    let avPlayer = await AVPlayerManager.getInstance()
    await avPlayer.playSong(music)
  }

  // 页面即将显示时触发，获取歌单信息
  async aboutToAppear() {
    await getPlayListById(this.listid).then(async (res: AxiosResponse) => {
      if (res.data.code === '200') {
        this.playlist = res.data.result
        // 判断是否为当前用户的歌单，设置收藏和删除状态
        if (this.playlist.creatorId !== this.user.id) {
          this.isFavorite = this.playlist.isFavorite
          if (this.isFavorite) {
            this.typemessage = '取消收藏此歌单'
          }
        } else {
          this.isCreator = true
          this.typemessage = '删除此歌单'
        }
        const musicIds = this.playlist.musicIds
        // 获取歌单内所有音乐信息
        if (musicIds && musicIds.length > 0) {
          for (const id of musicIds) {
            try {
              await getMusicById(id).then((res: AxiosResponse) => {
                if (res.data.code === '200') {
                  this.musicList.push(res.data.result)  // 添加音乐到音乐列表
                } else {
                  hilog.error(0x00002, 'MUSIC', `获取音乐ID ${id} 失败`)
                }
              })
            } catch (error) {
              hilog.error(0x00002, 'MUSIC', `请求音乐ID ${id} 发生错误`, error)
            }
          }
        }
      } else {
        hilog.error(0x00002, 'PLAYLIST', '获取歌单失败')
      }
    })
  }

  // 弹出确认框，控制删除或取消收藏操作
  dialogController: CustomDialogController = new CustomDialogController({
    builder: DeletePlayList({
      type: this.typemessage,
      delete: () => {
        this.isFavorite ? this.unFavoritePlayList() : this.deletePlayList()
      }
    }),
  })

  // 删除歌单
  async deletePlayList() {
    await deleteList(this.listid).then((res: AxiosResponse) => {
      if (res.data.code !== '200') {
        hilog.error(0x00002, 'PLAYLIST', '删除歌单失败')
        this.dialogController.close()
      } else {
        if (this.from) {
          router.pushUrl({ url: 'pages/Index', params: { index: 1 } })
        } else {
          router.back()
        }
      }
    })
  }

  // 取消收藏歌单
  async unFavoritePlayList() {
    await unFavorite(this.listid).then((res: AxiosResponse) => {
      if (res.data.code !== '200') {
        hilog.error(0x00002, 'PLAYLIST', '取消收藏歌单失败')
        this.dialogController.close()
      } else {
        this.isFavorite = false
      }
    })
  }

  // 收藏歌单
  async favoritePlayList() {
    await favorite(this.listid).then((res: AxiosResponse) => {
      if (res.data.code !== '200') {
        hilog.error(0x00002, 'PLAYLIST', '收藏歌单失败')
      } else {
        this.isFavorite = true
        this.typemessage = '取消收藏此歌单'
      }
    })
  }

  // 删除歌曲
  async deleteMusic(deleid: number) {
    await removeMusic({ id: 0, music_id: deleid, list_id: this.listid }).then((res: AxiosResponse) => {
      if (res.data.code !== '200') {
        hilog.error(0x00002, 'PLAYLIST', '删除歌曲失败')
      } else {
        this.musicList = this.musicList.filter(music => music.id !== deleid)
        this.playlist.musicIds = this.playlist.musicIds.filter(id => id !== deleid)
      }
    })
  }

  // 设置播放列表
  async setMusicList() {
    let avPlayer = await AVPlayerManager.getInstance()
    await avPlayer.setMusicList(this.musicList)
  }

  // 列表头部组件，包含 "全部播放" 按钮
  @Builder itemHead() {
    Row() {
      Image($r('app.media.startplaylist'))
        .height(30)
        .width(40)
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

        // 删除按钮，仅在歌单创建者时可见
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
                .borderRadius(20)

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

        // 如果没有音乐，显示暂无歌曲
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
          .fontSize(15)
          .height(15)
          .maxFontSize(15)
          .minFontSize(5)
          .fontColor(Color.Gray)
      }
      .alignItems(HorizontalAlign.Start)
      .width('65%')

      //歌曲编辑操作仅对创建者可见
      Column() {
        if(this.isCreator) {
          Image($r('app.media.remove'))
            .width(20)
            .height(20)
            .onClick(() => {
              this.dialogController.open()
            })
        }
      }.width('20%')

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