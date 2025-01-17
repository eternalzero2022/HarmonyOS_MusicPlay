import { AxiosResponse } from "@ohos/axios"
import { EmptyPlayList, getFavoriteListIds, getListIds, getPlayListById, playList } from "../api/playlist"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { Constants } from "../constants/Constants"
import { router } from "@kit.ArkUI"


@Entry
@Component
export struct PlayListPage{
  // 声明状态变量，存储歌单的ID、收藏歌单的ID、当前选中的索引、歌单数据和收藏歌单数据
  @State listIds: number[] = []
  @State favoriteIds: number[] = []
  @State currentIndex: number = 0
  @State playlists: playList[] = []
  @State favplaylists: playList[] = []

  // 页面即将显示时调用的函数
  aboutToAppear(){
    // 请求获取歌单ID
    getListIds().then(async (res: AxiosResponse) => {
      if (res.data.code === '200') {
        this.listIds = res.data.result as number[] // 将返回的歌单ID存储在listIds中
        if (this.listIds && this.listIds.length > 0) {
          // 按顺序获取所有歌单的信息
          for (const id of this.listIds) {
            try {
              await getPlayListById(id).then((res: AxiosResponse) => {
                if (res.data.code === '200') {
                  this.playlists.push(res.data.result) // 将获取到的歌单添加到playlists数组中
                } else {
                  hilog.error(0x00002, 'PLAYLIST', `获取列表 ${id} 失败`) // 如果获取歌单失败，记录错误日志
                }
              })
            } catch (error) {
              hilog.error(0x00002, 'PLAYLIST', `请求列表 ${id} 发生错误`, error) // 捕获请求过程中的错误并记录
            }
          }
        }
      } else {
        hilog.error(0x00002, 'PLAYLIST', '获取列表id失败') // 如果获取歌单ID失败，记录错误日志
      }
    })

    // 请求获取收藏的歌单ID
    getFavoriteListIds().then(async (res: AxiosResponse) => {
      if (res.data.code === '200') {
        this.favoriteIds = res.data.result as number[] // 将返回的收藏歌单ID存储在favoriteIds中
        if (this.favoriteIds && this.favoriteIds.length > 0) {
          // 按顺序获取所有收藏歌单的信息
          for (const id of this.favoriteIds) {
            try {
              await getPlayListById(id).then((res: AxiosResponse) => {
                if (res.data.code === '200') {
                  this.favplaylists.push(res.data.result) // 将获取到的收藏歌单添加到favplaylists数组中
                } else {
                  hilog.error(0x00002, 'PLAYLIST', `获取列表 ${id} 失败`) // 如果获取收藏歌单失败，记录错误日志
                }
              })
            } catch (error) {
              hilog.error(0x00002, 'PLAYLIST', `请求列表 ${id} 发生错误`, error) // 捕获请求过程中的错误并记录
            }
          }
        }
      } else {
        hilog.error(0x00002, 'PLAYLIST', '获取收藏列表id失败') // 如果获取收藏歌单ID失败，记录错误日志
      }
    })
  }


  //自定义tabbar渲染器
  @Builder tabBuilder(title: string, targetIndex: number) {
    Column() {
      Text(title)
        .fontSize(20)
        .fontWeight(this.currentIndex === targetIndex ? FontWeight.Bold : FontWeight.Normal)

      Blank().color(Color.Black).height(2).width('50%').visibility(this.currentIndex === targetIndex ?Visibility.Visible:Visibility.Hidden)
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Stack() {


      Tabs() {
        TabContent() {
          Scroll() {
            Column() {
              if(this.listIds.length>0) {
                Blank().height(10)
                List({ space: 10 }) {
                  ForEach(this.playlists, (item: playList) => {
                    ListItem() {
                      playListItem({ playlist:item})
                    }
                  })
                }
              }
              else{
                Column(){
                  Text('暂无歌单')
                    .fontColor(Color.Gray)
                    .fontSize(50)
                }
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Center)
                .width('100%')
                .height('80%')
              }
            }
            .height('100%')
            .justifyContent(FlexAlign.Start)
          }
        }
        .tabBar(this.tabBuilder('自建歌单', 0))
        .backgroundColor(0xF1F3F5)

        TabContent() {
          Scroll() {
            Column() {
              if(this.favoriteIds.length>0) {
                Blank().height(10)
                List({ space: 10 }) {
                  ForEach(this.favplaylists, (item: playList) => {
                    ListItem() {
                      playListItem({ playlist:item ,isFavorite: true})
                    }
                  })
                }
              }
              else{
                Column(){
                  Text('暂无歌单')
                    .fontColor(Color.Gray)
                    .fontSize(50)
                }
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Center)
                .width('100%')
                .height('80%')
              }
            }
            .height('100%')
            .justifyContent(FlexAlign.Start)
          }
        }
        .tabBar(this.tabBuilder('收藏歌单', 1))
        .backgroundColor(0xF1F3F5)

      }
      .onChange((index: number) => {
        this.currentIndex = index
      })


      Button({ type: ButtonType.Circle, stateEffect: false }){
        Image($r('app.media.add'))
          .width(40)
          .height(40)
      }
      .borderStyle(BorderStyle.Solid)
      .borderWidth(2)
      .width(70)
      .height(70)
      .backgroundColor(Color.White)
      .position({x: '75%', y: '85%'})
      .onClick(() => {
        router.pushUrl({url:'pages/CreatePlayList'})
      })

    }
  }

}

@Component
struct playListItem{
  @Prop isFavorite: boolean = false
  @Prop playlist:playList = EmptyPlayList


  build() {
    if (this.playlist && this.playlist.id) { // 确保 playlist 数据存在
      Row() {
        Image(this.playlist.imageUrl === '' ? Constants.DEFAULT_MUSIC_IMAGE : this.playlist.imageUrl)
          .width(70)
          .height(70)
          .borderRadius(10)
          .margin(20);
        Text(this.playlist.listName)
          .fontSize(20);
      }
      .height(100)
      .width('100%')
      .backgroundColor(Color.White)
      .onClick(()=>{
        router.pushUrl({
          url: 'pages/PlayListDetail',
          params: { listId: this.playlist.id , from: true }
        });
      });
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



