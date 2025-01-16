import { AVPlayerManager } from '../manager/AVPlayerManager'
import { router } from '@kit.ArkUI'
import { Music, MusicPlayStrategy, PlayState, EmptyMusic } from '../viewmodel/MusicViewModel';
import { Constants } from '../constants/Constants';

@Entry
@Component
struct Detail {
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
            .fontSize(50)

          Text(this.currentMusic.singer)
            .fontSize(20)
        }
      }
      .justifyContent(FlexAlign.SpaceAround)
      .width('100%')
      .height('10%')

      Blank().height('2%')


      Row(){
        Text('歌词')
      }
      .width('100%')
      .height('15%')

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

      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ right: 20 })
      .width('100%')
      .height('10%')
    }
  }
}



