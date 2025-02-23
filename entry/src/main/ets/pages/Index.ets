import {AVPlayerManager} from "../manager/AVPlayerManager"
import { taskpool } from '@kit.ArkTS'
import { Music, MusicPlayStrategy, PlayState } from '../viewmodel/MusicViewModel';
import { DatabaseManager } from '../manager/DatabaseManager';
import { router } from '@kit.ArkUI';
import { PlayBar } from '../view/PlayBar'
import { MinePage } from '../pages/Mine'
import { getAllShareListIds, getPlayListById, playList } from '../api/playlist';
import { Constants } from '../constants/Constants';
import { getAllMusic } from '../api/music';
import { AxiosResponse } from '@ohos/axios';
import { PlayListPage } from './PlayLists';
import { SearchPage } from '../pages/SearchPage'
import { hilog } from '@kit.PerformanceAnalysisKit';
import text from '@ohos.graphics.text';

/**
 * AVPlayerManager和DatabaseManager使用示例
 */
@Entry
@Component
struct Index {
  private swiperController: SwiperController = new SwiperController()
  @State message: string = 'Hello World';

  @State strategy: MusicPlayStrategy = MusicPlayStrategy.SEQUENCE

  @State history:string = ""

  @State selectedTab:string = router.getParams()?'playlist':'home';

  @State recommendedSongs: Music[] = []
  @State recommendedPlaylists:playList[] = []


  async aboutToAppear(): Promise<void> {
    if(!AppStorage.get("Token")){
      router.replaceUrl({url : "pages/UserLogin"})
    }
    await this.fetchRecommendedContent()
  }

  /**
   * 异步方法：依次请求所有音乐和所有共享歌单ID，并随机选择最多10个填充到推荐歌曲和推荐歌单中。
   */
  async fetchRecommendedContent() {
    // 调用获取所有音乐的请求
    console.error("?")
    getAllMusic()
      .then((res: AxiosResponse): void => {
        if (res.data.code === '200') {
          console.error(res.data.code + " 1")
          const allMusic: Array<Music> = res.data.result; // 获取所有音乐数据

          // 随机选择最多10个音乐
          const selectedSongs: Array<Music> = this.selectRandomItems(allMusic, 10);
          this.recommendedSongs = selectedSongs; // 更新推荐歌曲状态
          hilog.error(0x00002,'MUSIC',`${JSON.stringify(this.recommendedSongs)}`)
          getAllShareListIds().then(async (playlistResponse: AxiosResponse): Promise<void> => {
            if (playlistResponse.data.code === '200') {
              console.error(res.data.code + " 2")
              const listids: number[] = playlistResponse.data.result; // 获取所有歌单数据
              const allPlayList: playList[] = []

              if (listids && listids.length > 0) {
                // 按顺序请求所有的音乐信息
                for (const id of listids) {
                  try {
                    await getPlayListById(id).then((res:AxiosResponse)=>{
                      if (res.data.code === '200') {
                        allPlayList.push(res.data.result) // 添加到音乐列表中
                      } else {
                        hilog.error(0x00002, 'PLAYLIST', `获取列表 ${id} 失败`)
                      }
                    })
                  } catch (error) {
                    hilog.error(0x00002, 'PLAYLIST', `请求列表 ${id} 发生错误`, error)
                  }
                }
              }

              // 随机选择最多10个歌单
              const selectedPlaylists: Array<playList> = this.selectRandomItems(allPlayList, 10);
              this.recommendedPlaylists = selectedPlaylists; // 更新推荐歌单状态

              hilog.error(0x00002,'PLAYLIST',`${JSON.stringify(this.recommendedPlaylists)}`)
            }
          })
        }else{
          console.error(res.data.code + " 3")
        }
      })
  }

  /**
   * 辅助方法：从给定数组中随机选择最多count个项目。
   * 如果数组长度小于等于count，则返回整个数组。
   * @param items 原始数组
   * @param count 最大选择数量
   * @returns 随机选择的项目数组
   */
  selectRandomItems<T>(items: Array<T>, count: number): Array<T> {
    if (items.length <= count) {
      return items;
    }

    const selectedItems: Array<T> = [];
    const indices = new Set<number>(); // 用于存储已选择的索引，避免重复

    while (selectedItems.length < count) {
      const randomIndex = Math.floor(Math.random() * items.length);
      if (!indices.has(randomIndex)) {
        indices.add(randomIndex);
        selectedItems.push(items[randomIndex]);
      }
    }

    return selectedItems;
  }


  build() {
      Column() {

        // 内容区域，根据 selectedTab 切换内容
        Stack() {
          if (this.selectedTab === 'test') {
            Column() {
              Button('登录')
                .width(200)
                .height(40)
                .margin({ top: 20 })
                .borderRadius(10)
                .backgroundColor('#00BFFF')
                .fontColor("FFFFFF")
                .fontSize(24)
                .onClick(() => {
                  router.pushUrl({ url: "pages/UserLogin" })
                })
              Button('播放音乐')
                .width(200)
                .height(40)
                .margin({ top: 20 })
                .borderRadius(10)
                .backgroundColor('#00BFFF')
                .fontColor("FFFFFF")
                .fontSize(24)
                .onClick(() => {
                  this.setMusicList()
                })

              Button('下一首')
                .width(200)
                .height(40)
                .margin({ top: 20 })
                .borderRadius(10)
                .backgroundColor('#00BFFF')
                .fontColor("FFFFFF")
                .fontSize(24)
                .onClick(() => {
                  this.jumpToNextMusic()
                })

              Button('上一首')
                .width(200)
                .height(40)
                .margin({ top: 20 })
                .borderRadius(10)
                .backgroundColor('#00BFFF')
                .fontColor("FFFFFF")
                .fontSize(24)
                .onClick(() => {
                  this.jumpToPrevMusic()
                })

              Button('暂停')
                .width(200)
                .height(40)
                .margin({ top: 20 })
                .borderRadius(10)
                .backgroundColor('#00BFFF')
                .fontColor("FFFFFF")
                .fontSize(24)
                .onClick(() => {
                  this.pause()
                })

              Button('继续播放')
                .width(200)
                .height(40)
                .margin({ top: 20 })
                .borderRadius(10)
                .backgroundColor('#00BFFF')
                .fontColor("FFFFFF")
                .fontSize(24)
                .onClick(() => {
                  this.continue()
                })

              Button('设置回调')
                .width(200)
                .height(40)
                .margin({ top: 20 })
                .borderRadius(10)
                .backgroundColor('#00BFFF')
                .fontColor("FFFFFF")
                .fontSize(24)
                .onClick(() => {
                  this.setTimeUpdateCallBack()
                })

              Button('设置播放策略')
                .width(200)
                .height(40)
                .margin({ top: 20 })
                .borderRadius(10)
                .backgroundColor('#00BFFF')
                .fontColor("FFFFFF")
                .fontSize(24)
                .onClick(() => {
                  this.changeStrategy()
                })
              Text("当前策略：" + this.parseStrategy(this.strategy)).fontSize(20)

              Button('音乐进度至95%')
                .width(200)
                .height(40)
                .margin({ top: 20 })
                .borderRadius(10)
                .backgroundColor('#00BFFF')
                .fontColor("FFFFFF")
                .fontSize(24)
                .onClick(() => {
                  this.seekTo95Percent()
                })

              Button('获取历史记录')
                .width(200)
                .height(40)
                .margin({ top: 20 })
                .borderRadius(10)
                .backgroundColor('#00BFFF')
                .fontColor("FFFFFF")
                .fontSize(24)
                .onClick(() => {
                  this.getHistory()
                })


              Text(this.message).fontSize(20)
            }
          } else if (this.selectedTab === 'home') {
            if((!AppStorage.get("Id")) || AppStorage.get("Id")=== -1 ){
              Column(){
                Text('请先登录')
                  .fontColor(Color.Gray)
                  .fontSize(50)
              }
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.Center)
              .width('100%')
              .height('80%')

            }else{
            Scroll() {
              Column() {
                TextInput({ placeholder: '搜索' })
                  .onClick( ()=> {
                    this.selectedTab = 'search';
                  })
                  .margin({ bottom: 5 })

                Text('为您推荐')
                  .width('80%')
                  .margin({ top: 10 })
                  .fontSize(40)
                  .fontWeight(FontWeight.Bold)


                // 轮播图展示推荐歌曲的封面
                Swiper(this.swiperController) {
                  ForEach(this.recommendedSongs, (song: Music) => {
                    Image(song.imageUrl === "" ?
                    Constants.DEFAULT_MUSIC_IMAGE : song.imageUrl)
                      .width('90%')
                      .height('30%')
                      .objectFit(ImageFit.Cover)
                      .borderRadius(5)
                      .onClick(() => {
                        this.playSong(song)
                      })
                  })
                }
                .borderRadius(5)
                .width('100%')
                .margin({ top: 20 })
                .autoPlay(true)
                .loop(true)

                // 推荐歌曲图标部分
                Column() {
                  Text('推荐歌曲')
                    .fontSize(25)
                    .margin({ top: 20 })
                  if (this.recommendedSongs.length > 0) {
                    Row() {
                      List() {
                        ForEach(this.recommendedSongs, (song: Music, index: number) => {
                          ListItem() {
                            Row() {
                              Image(song.imageUrl === "" ?
                              Constants.DEFAULT_MUSIC_IMAGE : song.imageUrl)
                                .width(40)
                                .height(40)
                                .margin({ left: 2, right: 15, top: 15, bottom: 15 })
                                .borderRadius(5)
                              Column() {
                                Text(song.musicName)
                                  .fontWeight(FontWeight.Medium)
                                  .margin({ bottom: 2 })
                                  .fontSize(20)
                                  .height(20)
                                  .maxFontSize(20)
                                  .minFontSize(10)

                                Text(song.singer)
                                  .fontSize(15)
                                  .height(15)
                                  .maxFontSize(15)
                                  .minFontSize(5)
                                  .fontColor(Color.Gray)
                              }
                              .alignItems(HorizontalAlign.Start)
                            }
                            .width('100%')
                            .justifyContent(FlexAlign.Start)
                            // .height(40)
                            // .backgroundColor(Color.Gray)
                            .alignItems(VerticalAlign.Center)
                            .onClick(() => {
                              this.playSong(song)
                              router.pushUrl({url: 'pages/Detail'})
                            })

                          }
                        })
                      }
                      .divider({
                        strokeWidth: 1,
                        startMargin: 5,
                        endMargin: 5,
                        color: 0xE2E3E5
                      })
                    }.margin({top:10})
                  } else {
                    Text('获取推荐歌曲中...')
                      .fontSize(14)
                      .fontColor(Color.Gray)
                      .margin({ top: 10 })
                  }
                }
                .alignItems(HorizontalAlign.Start)

                // 推荐歌单图标部分
                Column() {
                  Text('推荐歌单')
                    .fontSize(25)
                    .margin({ top: 20 })
                  if (this.recommendedPlaylists.length > 0) {

                    Scroll() {
                      Row() {
                        ForEach(this.recommendedPlaylists, (playlist: playList) => { // 根据实际类型替换 any

                          Column() {
                            Image(playlist.imageUrl === "" ?
                            Constants.DEFAULT_MUSIC_IMAGE : playlist.imageUrl)
                              .width(60)
                              .height(60)
                              .borderRadius(30)
                              .objectFit(ImageFit.Cover)
                              .onClick(() => {
                                router.pushUrl({
                                  url:'pages/PlayListDetail',
                                  params: { listId : playlist.id , from : false}
                                })
                              })
                            Text(playlist.listName)
                              .fontSize(12)
                              .textAlign(TextAlign.Center)
                              .margin({ top: 5 })
                          }
                          .margin({ right: 10, bottom: 10 })

                        })
                      }.margin({ top: 10 })
                    }.scrollBar(BarState.Off)
                    .scrollable(ScrollDirection.Horizontal)

                  } else {
                    Text('获取推荐歌单中...')
                      .fontSize(14)
                      .fontColor(Color.Gray)
                      .margin({ top: 10 })
                  }
                }
                .alignItems(HorizontalAlign.Start)
              }
              .padding(25)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(0xF2F3F5)
            }.scrollBar(BarState.Off)
            }
          } else if (this.selectedTab === 'playlist') {
            Column(){
              PlayListPage()
            }
          } else if (this.selectedTab === 'my') {
            Column() {
              MinePage()
            }
          }else if (this.selectedTab === 'search') {
            Column() {
              SearchPage()
            }
          }
        }
        .height('85%')


        Column() {
          Row() {
            PlayBar()
          }

          Row() {
            Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround }) {
              // 首页按钮
              Column() {
                Image(this.selectedTab === 'home' ? $r('app.media.homefill') : $r('app.media.home'))
                  .width(30)
                  .height(30)
                  .margin(5)
                  .objectFit(ImageFit.Auto)

                Text('首页')
              }
              .onClick(() => {
                this.selectedTab = 'home';
              })

              //歌单按钮
              Column() {
                Image(this.selectedTab === 'playlist' ? $r('app.media.playlistfill') : $r('app.media.playlist'))
                  .width(30)
                  .height(30)
                  .margin(5)
                  .borderRadius(5)
                  .backgroundColor(this.selectedTab === 'playlist' ? Color.Black : '')
                  .objectFit(ImageFit.Auto)

                Text('歌单')
              }
              .onClick(() => {
                this.selectedTab = 'playlist';
              })

              // 我的按钮
              Column() {
                Image(this.selectedTab === 'my' ? $r('app.media.spacefill') : $r('app.media.space'))
                  .width(30)
                  .height(30)
                  .margin(5)
                  .objectFit(ImageFit.Auto)

                Text('我的')
              }
              .onClick(() => {
                this.selectedTab = 'my';
              })
            }
          }
          .height('10%')
          .width('100%')
        }
      }
  }

  async setMusicList(){
    let avPlayer = await AVPlayerManager.getInstance()
    await avPlayer.setMusicList([{
      id: 1,
      musicName: '>ω<',
      singer: '1',
      musicUrl: 'https://musicplay-oss.oss-cn-hangzhou.aliyuncs.com/%E7%BE%BD%E7%BF%BC%E6%B7%B1%E8%93%9D%20-%20%CF%89.mp3',
      imageUrl: ''
    },{
      id: 2,
      musicName: 'I got smoke',
      singer: '2',
      musicUrl: 'https://musicplay-oss.oss-cn-hangzhou.aliyuncs.com/V%E5%9C%A8%E7%87%83%E7%83%A7%20-%20I%20Got%20Smoke.mp3',
      imageUrl: ''
    },{
      id: 3,
      musicName: 'title theme',
      singer: '3',
      musicUrl: 'https://musicplay-oss.oss-cn-hangzhou.aliyuncs.com/Ari%20Pulkkinen%20-%20Title%20Theme.mp3',
      imageUrl: ''
    },{
      id: 4,
      musicName: 'zood',
      singer: '4',
      musicUrl: 'https://musicplay-oss.oss-cn-hangzhou.aliyuncs.com/bbblckck%20-%20Zood.mp3',
      imageUrl: ''
    }])
  }

  async changeStrategy(){
    let avPlayer = await AVPlayerManager.getInstance()
    if(this.strategy == MusicPlayStrategy.SEQUENCE){
      this.strategy = MusicPlayStrategy.RANDOM
    }else if(this.strategy == MusicPlayStrategy.RANDOM){
      this.strategy = MusicPlayStrategy.LOOP
    }else if(this.strategy == MusicPlayStrategy.LOOP){
      this.strategy = MusicPlayStrategy.SEQUENCE
    }
    avPlayer.setStrategy(this.strategy)
  }

  async jumpToNextMusic(){
    let avPlayer = await AVPlayerManager.getInstance()
    await avPlayer.jumpToNextMusic()
  }

  async jumpToPrevMusic(){
    let avPlayer = await AVPlayerManager.getInstance()
    await avPlayer.jumpToPrevMusic()
  }

  async pause(){
    let avPlayer = await AVPlayerManager.getInstance()
    await avPlayer.pause()
  }

  async continue(){
    let avPlayer = await AVPlayerManager.getInstance()
    await avPlayer.continue()
  }


  async setTimeUpdateCallBack(){
    let avPlayer = await AVPlayerManager.getInstance()
    await avPlayer.setTimeUpdateCallBack((time: number)=>{
      this.message = time.toString()
    })
  }

  async seekTo95Percent(){
    let avPlayer = await AVPlayerManager.getInstance()
    await avPlayer.seekByPercent(0.95)
  }

  async getHistory(){
    const history: Array<Music> = await DatabaseManager.getAllHistory(getContext(this))
    //提取history中的每个musicName，并写入history，名称之间包含空格
    this.history ='\n'+ history.map((music)=>{
      return music.musicName
    }).join('\n')
  }

  async playSong(music:Music){
    let avPlayer = await AVPlayerManager.getInstance()
    await avPlayer.playSong(music)
  }



  parseStrategy(strategy: MusicPlayStrategy){
    switch (strategy){
      case MusicPlayStrategy.SEQUENCE:
        return '顺序播放'
      case MusicPlayStrategy.RANDOM:
        return '随机播放'
      case MusicPlayStrategy.LOOP:
        return '循环播放'
    }
  }



}