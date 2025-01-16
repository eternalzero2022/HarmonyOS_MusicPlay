import { Music } from "../viewmodel/MusicViewModel"
import { DatabaseManager } from "../manager/DatabaseManager"
import { router } from '@kit.ArkUI';
import { AVPlayerManager } from "../manager/AVPlayerManager"
import { Constants } from '../constants/Constants'

@Entry
@Component
export struct History {
  @State historyList: Music[] = []

  aboutToAppear() {
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
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .margin(15)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)


      List() {
        ForEach(this.historyList, (history: Music, index: number) => {
          ListItem() {
            Row() {
              Image(history.imageUrl === "" ?
              Constants.DEFAULT_MUSIC_IMAGE : history.imageUrl)
                .height(40)
                .height(40)
                .margin(15)
                .borderRadius(5)
              Column() {
                Text(history.musicName)
                Text(history.singer)
              }
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            // .height(40)
            // .backgroundColor(Color.Gray)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {

              this.playHistoryMusic(index)

            })

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