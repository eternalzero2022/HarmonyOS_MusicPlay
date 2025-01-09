import { AVPlayerManager } from "../manager/AVPlayerManager"
import { taskpool } from '@kit.ArkTS'
import { Music, MusicPlayStrategy, PlayState, EmptyMusic } from '../viewmodel/MusicViewModel';
import { DatabaseManager } from '../manager/DatabaseManager';
import { router } from '@kit.ArkUI';
import { Constants } from '../constants/Constants'

@Component
export struct PlayBar {
  @StorageProp('currentMusic') currentMusic: Music = EmptyMusic
  @StorageProp('currentState') currentState: PlayState = PlayState.PAUSE
  @StorageProp('currentStrategy') currentStrategy: MusicPlayStrategy = MusicPlayStrategy.SEQUENCE
  @StorageProp('currentTime') currentTime: number = 0
  @StorageProp('totalTime') totalTime: number = 1

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
    let avPlayer = await AVPlayerManager.getInstance()
    await avPlayer.jumpToNextMusic()
  }

  async jumpToPrevMusic() {
    let avPlayer = await AVPlayerManager.getInstance()
    await avPlayer.jumpToPrevMusic()
  }

  async pause() {
    let avPlayer = await AVPlayerManager.getInstance()
    await avPlayer.pause()
  }

  async continue() {
    let avPlayer = await AVPlayerManager.getInstance()
    await avPlayer.continue()
  }

  async seek(time: number) {
    let avPlayer = await AVPlayerManager.getInstance()
    await avPlayer.seekByTime(time)
  }

  build() {
    Column() {

      Row() {
        Row() {
          Image(this.currentMusic.imageUrl)
            .height(40)
            .height(40)
            .margin(10)
            .borderRadius(5)

          Column() {
            Text(this.currentMusic.musicName)
            Text(this.currentMusic.singer)
              .fontSize(14)
              .fontColor(Color.Gray)
          }
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .align(Alignment.Start)

        Row() {

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


          IconImage({ icon: $r('app.media.last') })
            .onClick(() => {
              this.jumpToPrevMusic()
            })

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

          IconImage({ icon: $r('app.media.next') })
            .onClick(() => {
              this.jumpToNextMusic()
            })

          IconImage({ icon: $r('app.media.list') })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.End)
        .margin({ right: 20 })

      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      Slider({ value: this.currentTime, max: this.totalTime, style: SliderStyle.OutSet })
        .width('95%')
        .height(4)
        .blockSize({ width: 6, height: 6 })
        .onChange((value: number)=> {
          this.seek(value)
        })
    }
    .width('100%')
    .height(60)
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