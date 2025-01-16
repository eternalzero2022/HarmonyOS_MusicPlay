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

  // 左滑删除按钮
  @Builder
  deleteHistory(index: number) {
    Row() {
      Text('删除')
        .fontColor(Color.White)
        .fontSize(18)
        .textAlign(TextAlign.Center)
        .width('150lpx')
    }
    .height('100%')
    .backgroundColor(0xea5455)
    .justifyContent(FlexAlign.SpaceEvenly)
    .borderRadius({ topRight: 10, bottomRight: 10 })
    .onClick(() => {
      DatabaseManager.deleteHistory(this.historyList[index].id, getContext(this))
      this.historyList.splice(index, 1)
    })
  }

  build() {
    Column() {
      Row() {
        // 历史记录标题
        Text('最近播放')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin(15)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      // 历史记录列表
      List() {
        ForEach(this.historyList, (history: Music, index: number) => {
          ListItem() {
            Row() {
              if (history.id == this.currentMusic.id) { // 当前播放中的音乐
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
          }
          .swipeAction({ end: this.deleteHistory(index) }) // 左滑删除
        })
      }
      .divider({
        strokeWidth: 1,
        startMargin: 15,
        endMargin: 15,
        color: '#ffe9f0f0'
      })
      .height('73%')
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
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 2 })

        Text(this.music.singer)
          .fontSize(14)
          .fontColor(Color.Gray)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
  }
}