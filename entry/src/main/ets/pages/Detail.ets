import { AVPlayerManager } from '../manager/AVPlayerManager'
import { router } from '@kit.ArkUI'
import { Music, MusicPlayStrategy, PlayState, EmptyMusic } from '../viewmodel/MusicViewModel';
import { Constants } from '../constants/Constants';
import { addMusic, EmptyPlayList, getListIds, getPlayListById, playList } from '../api/playlist';
import { AxiosResponse } from '@ohos/axios';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Detail {
  @StorageProp('currentMusic') currentMusic: Music = EmptyMusic
  @StorageProp('currentState') currentState: PlayState = PlayState.PAUSE
  @StorageProp('currentStrategy') currentStrategy: MusicPlayStrategy = MusicPlayStrategy.SEQUENCE
  @StorageProp('currentTime') currentTime: number = 0
  @StorageProp('totalTime') totalTime: number = 1
  @State listPopup: boolean = false
  @State listIds: number[] = []

  avPlayer: AVPlayerManager | null = null

  addMusicToPlayList(musicid:number,listid:number){
    addMusic({id:0,music_id:musicid,list_id:listid}).then((res:AxiosResponse)=>{
      if(res.data.code==='200'){
        this.listPopup = !this.listPopup
      }
      else{
        hilog.error(0x00002,'MUSIC',`加入歌单失败 ${musicid} ${listid}`)
      }
    })
  }

  @Builder popupBuilder() {
    Column() {
      Blank().height('2%')
      Row() {
        Text('添加到歌单')
          .fontSize(20)
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')

      List() {
        ForEach(this.listIds, (item: number) => {
          ListItem() {
            playListItem({ listid: item , musicid: this.currentMusic.id , add:()=>{this.addMusicToPlayList(this.currentMusic.id,item)}})
          }
        })
      }.width('90%')
      .height('80%')
    }
    .height('40%')
    .justifyContent(FlexAlign.Start)
  }

  async aboutToAppear() {
    this.avPlayer = await AVPlayerManager.getInstance()
    getListIds().then((res:AxiosResponse)=>{
      if(res.data.code==='200'){
        this.listIds = res.data.result as number[]
      }
      else{
        hilog.error(0x00002,'PLAYLIST','获取列表id失败')
      }
    })
  }

  async changeStrategy() {
    let avPlayer = await AVPlayerManager.getInstance()
    if (this.currentStrategy == MusicPlayStrategy.SEQUENCE) {
      avPlayer.setStrategy(MusicPlayStrategy.RANDOM)
    } else if (this.currentStrategy == MusicPlayStrategy.RANDOM) {
      avPlayer.setStrategy(MusicPlayStrategy.LOOP)
    } else if (this.currentStrategy == MusicPlayStrategy.LOOP) {
      avPlayer.setStrategy(MusicPlayStrategy.SEQUENCE)
    }
  }

  async jumpToNextMusic() {
    await this.avPlayer?.jumpToNextMusic()
  }

  async jumpToPrevMusic() {
    await this.avPlayer?.jumpToPrevMusic()
  }

  async pause() {
    await this.avPlayer?.pause()
  }

  async continue() {
    await this.avPlayer?.continue()
  }

  async seek(time: number) {
    await this.avPlayer?.seekByTime(time)
  }

  build() {
    Column(){
      Row(){
        Image($r('app.media.back'))
          .width(30)
          .height(30)
          .margin(10)
          .onClick(() => {
            router.back()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Blank().height('5%')


      Row(){
        Image(this.currentMusic.imageUrl == '' ? Constants.DEFAULT_MUSIC_IMAGE : this.currentMusic.imageUrl)
          .height('100%')
          .width('100%')
          .backgroundColor(Color.White)
      }
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.Black)
      .width('80%')
      .height('40%')

      Blank().height('5%')

      Row(){
        Column() {
          Text(this.currentMusic.musicName)
            .fontSize(30)

          Text(this.currentMusic.singer)
            .fontSize(20)
        }
      }
      .justifyContent(FlexAlign.SpaceAround)
      .width('100%')
      .height('10%')

      Blank().height('10%')


      Row() {
        Slider({ value: this.currentTime, max: this.totalTime, style: SliderStyle.OutSet })
          .width('95%')
          .height(4)
          .blockSize({ width: 6, height: 6 })
          .onChange((value: number) => {
            this.seek(value)
          })
      }
      .width('100%')

      Blank().height('5%')

      Row(){
        Row() {
          if (this.currentStrategy == MusicPlayStrategy.SEQUENCE) {
            Image($r('app.media.sequence'))
              .width(30)
              .height(30)
              .margin(5)
          } else if (this.currentStrategy == MusicPlayStrategy.RANDOM) {
            Image($r('app.media.random'))
              .width(30)
              .height(30)
              .margin(5)
          } else if (this.currentStrategy == MusicPlayStrategy.LOOP) {
            Image($r('app.media.loop'))
              .width(30)
              .height(30)
              .margin(5)
          }
        }
        .onClick(() => {
          this.changeStrategy()
        })

        Image($r('app.media.last'))
          .width(60)
          .height(60)
          .margin(5)
          .onClick(() => {
            this.jumpToPrevMusic()
          })

        if (this.currentState == PlayState.PAUSE) {
          Image($r('app.media.playing'))
            .width(80)
            .height(80)
            .margin(5)
            .onClick(() => {
              this.continue()
            })
        } else {
          Image($r('app.media.pause'))
            .width(80)
            .height(80)
            .margin(5)
            .onClick(() => {
              this.pause()
            })
        }

        Image($r('app.media.next'))
          .width(60)
          .height(60)
          .margin(5)
          .onClick(() => {
            this.jumpToNextMusic()
          })

        Image($r('app.media.addtoplaylist'))
          .width(40)
          .height(40)
          .margin(5)
          .onClick(()=>{
            this.listPopup = !this.listPopup
          })
          .bindPopup(this.listPopup, {
            builder: this.popupBuilder, // 气泡的内容
            placement:Placement.Bottom, // 气泡的弹出位置
            popupColor:0xF1F3F5, // 气泡的背景色
            onStateChange: (e) => {
              if (!e.isVisible) {
                this.listPopup = false
              }
            }
          })

      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ right: 20 })
      .width('100%')
      .height('10%')
    }
  }
}

@Component
struct playListItem{
  @Prop listid: number = 0
  @Prop musicid: number = 0
  @State playlist:playList = EmptyPlayList
  add?:()=>void

  aboutToAppear(){
    getPlayListById(this.listid).then((res:AxiosResponse)=>{
      if(res.data.code==='200'){
        this.playlist = res.data.result as playList
      }
      else{
        hilog.error(0x00002,'PLAYLIST','获取歌单失败')
      }
    })
  }

  build() {
    if (this.playlist && this.playlist.id) { // 确保 playlist 数据存在
      Row() {
        Image(this.playlist.imageUrl === '' ? Constants.DEFAULT_MUSIC_IMAGE : this.playlist.imageUrl)
          .width(40)
          .height(40)
          .borderRadius(10)
          .margin(5);
        Text(this.playlist.listName)
          .fontSize(20);
      }
      .height(100)
      .width('100%')
      .backgroundColor(Color.White)
      .onClick(()=>{
        if(this.add){
          this.add()
        }
      })
    } else {
      // 在数据加载完成之前，可以添加一个加载中的提示
      Row() {
        Text('加载中...')
          .fontSize(20)
          .fontColor(Color.Gray);
      }
    }
  }
}



