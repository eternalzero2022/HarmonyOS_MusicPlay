import { AVPlayerManager } from "../manager/AVPlayerManager"
import { Music, MusicPlayStrategy, PlayState, EmptyMusic } from '../viewmodel/MusicViewModel';
import { router } from '@kit.ArkUI';
import { Constants } from '../constants/Constants'


@Component
export struct PlayBar {
  @StorageProp('currentMusic') currentMusic: Music = EmptyMusic
  @StorageProp('currentState') currentState: PlayState = PlayState.PAUSE
  @StorageProp('currentStrategy') currentStrategy: MusicPlayStrategy = MusicPlayStrategy.SEQUENCE
  @StorageProp('currentTime') currentTime: number = 0
  @StorageProp('totalTime') totalTime: number = 1
  @State listPopup: boolean = false

  avPlayer: AVPlayerManager | null = null

  async aboutToAppear() {
    this.avPlayer = await AVPlayerManager.getInstance()
  }

  @Builder
  listPopupBuilder() {
    PlayingList({ currentMusic: this.currentMusic, currentState: this.currentState })
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
    Column() {

      Row() {

        // 当前播放的音乐
        Row() {
          Image(this.currentMusic.imageUrl)
            .width(40)
            .height(40)
            .margin(10)
            .borderRadius(5)

          Column() {
            Text(this.currentMusic.musicName)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 2 })
              .fontSize(20)
              .height(20)
              .maxFontSize(20)
              .minFontSize(8)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text(this.currentMusic.singer)
              .fontSize(15)
              .height(15)
              .maxFontSize(15)
              .minFontSize(5)
              .fontColor(Color.Gray)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('70%')
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .align(Alignment.Start)
        .onClick(()=>{
          router.pushUrl({url: 'pages/Detail'})
        })

        Row() {
          // 播放顺序策略图标
          Row() {
            if (this.currentStrategy == MusicPlayStrategy.SEQUENCE) {
              IconImage({ icon: $r('app.media.sequence') })
            } else if (this.currentStrategy == MusicPlayStrategy.RANDOM) {
              IconImage({ icon: $r('app.media.random') })
            } else if (this.currentStrategy == MusicPlayStrategy.LOOP) {
              IconImage({ icon: $r('app.media.loop') })
            }
          }
          .onClick(() => {
            this.changeStrategy()
          })

          // 上一首
          IconImage({ icon: $r('app.media.last') })
            .onClick(() => {
              this.jumpToPrevMusic()
            })
          // 暂停/继续
          if (this.currentState == PlayState.PAUSE) {
            IconImage({ icon: $r('app.media.playing') })
              .onClick(() => {
                this.continue()
              })
          } else {
            IconImage({ icon: $r('app.media.pause') })
              .onClick(() => {
                this.pause()
              })
          }
          // 下一首
          IconImage({ icon: $r('app.media.next') })
            .onClick(() => {
              this.jumpToNextMusic()
            })
          // 播放列表
          IconImage({ icon: $r('app.media.list') })
            .onClick(() => {
              this.listPopup = !this.listPopup
            })
            .bindPopup(this.listPopup, {
              builder: this.listPopupBuilder,
              placement: Placement.Bottom,
              onStateChange: (e) => {
                if (!e.isVisible) {
                  this.listPopup = false
                }
              }
            })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.End)
        .margin({ right: 20 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      // 播放进度滑动条
      Slider({ value: this.currentTime, max: this.totalTime, style: SliderStyle.OutSet })
        .width('95%')
        .height(4)
        .blockSize({ width: 6, height: 6 })
        .onChange((value: number) => {
          this.seek(value)
        })
    }
    .width('100%')
    .height(65)
    .backgroundColor(0xf4f7f7)
  }
}


@Component
struct IconImage {
  icon: Resource = $r('app.media.last')

  build() {
    Image(this.icon)
      .width(25)
      .height(25)
      .margin(5)
  }
}

@Component
struct PlayingList {
  musicList: Music[] = []
  @Prop currentMusic: Music = EmptyMusic
  @Prop currentState: PlayState = PlayState.PAUSE

  avPlayer: AVPlayerManager | null = null


  async aboutToAppear() {
    this.avPlayer = await AVPlayerManager.getInstance()
    this.musicList = this.avPlayer.getMusicList()
  }

  build() {
    Column() {
      Text('当前播放列表')
        .fontWeight(FontWeight.Bold)
        .fontSize(16)
        .width('90%')
        .margin({ bottom: 10 })

      if (this.musicList.length == 0) {
        Text('暂无播放中的歌曲')
          .fontColor(Color.Gray)
          .alignSelf(ItemAlign.Center)
          .fontSize(14)
          .margin(20)
      } else {

        List({ space: 8 }) {
          ForEach(this.musicList, (music: Music, index: number) => {
            ListItem() {
              Row() {

                if (music.id == this.currentMusic.id) {
                  // 目前播放中的
                  if (this.currentState == PlayState.PAUSE) {
                    Image($r("app.media.play1"))
                      .width(20)
                      .height(20)
                      .onClick(() => {
                        this.avPlayer?.continue()
                      })

                  } else {
                    Image($r("app.media.pause1"))
                      .width(20)
                      .height(20)
                      .onClick(() => {
                        this.avPlayer?.pause()
                      })
                  }

                  Image(music.imageUrl == '' ? Constants.DEFAULT_MUSIC_IMAGE : music.imageUrl)
                    .width(25)
                    .height(25)
                    .padding(2)
                    .margin({ right: 5 })
                    .borderRadius(5)
                    .foregroundColor($r('app.media.playing'))

                  Text(music.musicName)
                    .fontWeight(FontWeight.Bold)

                  Text(' · ')

                  Text(music.singer)
                    .fontSize(14)
                    .fontColor(Color.Gray)

                } else {
                  Image(music.imageUrl == '' ? Constants.DEFAULT_MUSIC_IMAGE : music.imageUrl)
                    .width(25)
                    .height(25)
                    .padding(2)
                    .margin({ right: 5 })
                    .borderRadius(5)

                  Text(music.musicName)

                  Text(' · ')

                  Text(music.singer)
                    .fontSize(14)
                    .fontColor(Color.Gray)
                }
              }
              .onClick(() => {
                this.avPlayer?.jumpTo(index)
              })
            }
          })
        }
        .width('90%')
        .divider({
          strokeWidth: 1,
          startMargin: 0,
          endMargin: 20,
          color: '#ffe9f0f0'
        })
      }
    }
    .padding({
      left: 10,
      right: 10,
      top: 15,
      bottom: 15
    })
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
  }
}