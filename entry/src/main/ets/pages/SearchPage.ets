import { DatabaseManager } from "../manager/DatabaseManager"
import { Music, PlayState, EmptyMusic } from '../viewmodel/MusicViewModel';
import { AVPlayerManager } from "../manager/AVPlayerManager"
import { Constants } from '../constants/Constants'
import { AxiosResponse } from '@ohos/axios';
import { searchMusic } from '../api/music';
import { router } from '@kit.ArkUI';


@Entry
@Component
export struct SearchPage {

  @State List: Music[] = []
  @StorageProp('currentMusic') currentMusic: Music = EmptyMusic
  @StorageProp('currentState') currentState: PlayState = PlayState.PAUSE
  avPlayer: AVPlayerManager | null = null
  name: string = '';
  controller: SearchController = new SearchController()

  async aboutToAppear() {
    this.avPlayer = await AVPlayerManager.getInstance()
  }

  async playHistoryMusic(index: number) {
    let avPlayer = await AVPlayerManager.getInstance()
    await avPlayer.setMusicList(this.List.slice(index).concat(this.List.slice(0, index)))
  }

  async fetchRecommendedContent() {
    searchMusic(this.name).then((res:AxiosResponse) => {
      if (res.data.code === '200') {
        const allMusic: Array<Music> = res.data.result;
        this.List = allMusic;
      }
    })
  }

  build() {
    Column() {

      Search({ value: this.name, placeholder: 'search...', controller: this.controller })
        .searchButton('搜索')
        .width('95%')
        .height(40)
        .backgroundColor('#F5F5F5')
        .placeholderColor(Color.Grey)
        .placeholderFont({ size: 14, weight: 400 })
        .textFont({ size: 14, weight: 400 })
        .onSubmit((value: string) => {
          this.name = value;
          this.fetchRecommendedContent();
        })
        .onChange((value: string) => {
          this.name = value;
        })
        .margin(20)


      List() {
        ForEach(this.List, (history: Music, index: number) => {
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