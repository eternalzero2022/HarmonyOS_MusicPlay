import { Music } from "../viewmodel/MusicViewModel"
import { DatabaseManager } from "../manager/DatabaseManager"
import { router } from '@kit.ArkUI';
import { AVPlayerManager } from "../manager/AVPlayerManager"

@Entry
@Component
struct History {
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
        Image($r('app.media.back'))
          .width(20)
          .height(20)
          .margin(10)
          .onClick(() => {
            router.back()
          })
        Text('最近播放')
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)


      List() {
        ForEach(this.historyList, (history: Music, index: number) => {
          ListItem() {
            Row() {
              Image(history.imageUrl === "" ?
                "https://tse1.mm.bing.net/th?id=OIP.CDxtKQRYAPTUqYVGxNKuLQHaHa&w=474&h=474&c=7" : history.imageUrl)
                .height(40)
                .height(40)
                .margin(10)
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
        startMargin: 20,
        endMargin: 20,
        color: '#ffe9f0f0'
      })
    }
  }
}