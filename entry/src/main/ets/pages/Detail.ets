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
  // 从本地存储读取当前的音乐信息，默认为EmptyMusic
  @StorageProp('currentMusic') currentMusic: Music = EmptyMusic
  // 从本地存储读取当前播放状态，默认为暂停状态
  @StorageProp('currentState') currentState: PlayState = PlayState.PAUSE
  // 从本地存储读取当前播放策略，默认为顺序播放
  @StorageProp('currentStrategy') currentStrategy: MusicPlayStrategy = MusicPlayStrategy.SEQUENCE
  // 从本地存储读取当前播放时间，默认为0
  @StorageProp('currentTime') currentTime: number = 0
  // 从本地存储读取音乐总时长，默认为1
  @StorageProp('totalTime') totalTime: number = 1
  // 控制歌单弹出框显示与否
  @State listPopup: boolean = false
  // 存储歌单ID
  @State listIds: number[] = []

  // 初始化播放器实例
  avPlayer: AVPlayerManager | null = null

  // 将音乐添加到指定歌单
  addMusicToPlayList(musicid:number, listid:number) {
    // 调用API将音乐添加到歌单
    addMusic({id:0, music_id:musicid, list_id:listid}).then((res:AxiosResponse) => {
      if(res.data.code === '200') {
        this.listPopup = !this.listPopup  // 添加成功，关闭歌单弹框
      } else {
        hilog.error(0x00002, 'MUSIC', `加入歌单失败 ${musicid} ${listid}`)
      }
    })
  }

  // 构建歌单选择弹框
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
            // 在每个歌单项中添加音乐
            playListItem({ listid: item, musicid: this.currentMusic.id, add: () => { this.addMusicToPlayList(this.currentMusic.id, item) }})
          }
        })
      }.width('90%')
      .height('80%')
    }
    .height('40%')
    .justifyContent(FlexAlign.Start)
  }

  // 页面即将显示时获取播放器实例和歌单ID
  async aboutToAppear() {
    this.avPlayer = await AVPlayerManager.getInstance()
    getListIds().then((res:AxiosResponse) => {
      if(res.data.code === '200') {
        this.listIds = res.data.result as number[]  // 设置歌单ID
      } else {
        hilog.error(0x00002, 'PLAYLIST', '获取列表id失败')
      }
    })
  }

  // 切换播放策略：顺序 -> 随机 -> 循环 -> 顺序
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

  // 跳转到下一首音乐
  async jumpToNextMusic() {
    await this.avPlayer?.jumpToNextMusic()
  }

  // 跳转到上一首音乐
  async jumpToPrevMusic() {
    await this.avPlayer?.jumpToPrevMusic()
  }

  // 暂停播放
  async pause() {
    await this.avPlayer?.pause()
  }

  // 继续播放
  async continue() {
    await this.avPlayer?.continue()
  }

  // 根据时间跳转
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



