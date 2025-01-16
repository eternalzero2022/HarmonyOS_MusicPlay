import { DatabaseManager } from "../manager/DatabaseManager"
import { Music, PlayState, EmptyMusic } from '../viewmodel/MusicViewModel';
import { AVPlayerManager } from "../manager/AVPlayerManager"
import { Constants } from '../constants/Constants'

@Entry
@Component
export struct History {
  @State historyList: Music[] = []
  @StorageProp('currentMusic') currentMusic: Music = EmptyMusic
  @StorageProp('currentState') currentState: PlayState = PlayState.PAUSE
  avPlayer: AVPlayerManager | null = null

  async aboutToAppear() {
    this.avPlayer = await AVPlayerManager.getInstance()
    DatabaseManager.getAllHistory(getContext(this)).then((historyList) => {
      this.historyList = historyList;
    });
  }

  async playHistoryMusic(index: number) {
    let avPlayer = await AVPlayerManager.getInstance()
    await avPlayer.setMusicList(this.historyList.slice(index).concat(this.historyList.slice(0, index)))
  }

  build() {

    Column() {
      Row() {

        Text('最近播放')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin(15)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)


      List() {
        ForEach(this.historyList, (history: Music, index: number) => {
          ListItem() {

            if (history.musicName == this.currentMusic.musicName) {

              Row() {
                if (this.currentState == PlayState.PAUSE) {
                  Image($r("app.media.play1"))
                    .width(40)
                    .height(40)
                    .margin({ left: 15 })
                    .onClick(() => {
                      this.avPlayer?.continue()
                    })

                } else {
                  Image($r("app.media.pause1"))
                    .width(40)
                    .height(40)
                    .margin({ left: 15 })
                    .onClick(() => {
                      this.avPlayer?.pause()
                    })
                }

                MusicItem({ music: history })
                  .onClick(() => {
                    this.playHistoryMusic(index)
                  })
              }

            } else {
              MusicItem({ music: history })
                .onClick(() => {
                  this.playHistoryMusic(index)
                })
            }
          }
        })
      }
      .divider({
        strokeWidth: 1,
        startMargin: 15,
        endMargin: 15,
        color: '#ffe9f0f0'
      })
    }
  }
}

@Component
struct MusicItem {
  music: Music = EmptyMusic

  build() {
    Row() {
      Image(this.music.imageUrl === "" ?
      Constants.DEFAULT_MUSIC_IMAGE : this.music.imageUrl)
        .height(40)
        .height(40)
        .margin(15)
        .borderRadius(5)
      Column() {
        Text(this.music.musicName)
        Text(this.music.singer)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
  }
}