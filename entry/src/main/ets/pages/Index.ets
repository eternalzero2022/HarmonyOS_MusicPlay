import {AVPlayerManager} from "../manager/AVPlayerManager"
import { taskpool } from '@kit.ArkTS'
import { Music, MusicPlayStrategy, PlayState } from '../viewmodel/MusicViewModel';
import { DatabaseManager } from '../manager/DatabaseManager';
import { router } from '@kit.ArkUI';
import { PlayBar } from '../view/PlayBar'
import { MinePage } from '../pages/Mine'

/**
 * AVPlayerManager和DatabaseManager使用示例
 */
@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  
  @State strategy: MusicPlayStrategy = MusicPlayStrategy.SEQUENCE
  
  @State history:string = ""

  @State selectedTab:string = 'home';

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
              .onClick(()=>{
                router.pushUrl({url: "pages/UserLogin"})
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
        }
        else if (this.selectedTab === 'home') {
          Column() {
            Button('登录')
              .width(200)
              .height(40)
              .margin({ top: 20 })
              .borderRadius(10)
              .backgroundColor('#00BFFF')
              .fontColor("FFFFFF")
              .fontSize(24)
              .onClick(()=>{
                router.pushUrl({url: "pages/UserLogin"})
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
            Button('历史记录页面')
              .width(200)
              .height(40)
              .margin({ top: 20 })
              .borderRadius(10)
              .backgroundColor('#00BFFF')
              .fontColor("FFFFFF")
              .fontSize(24)
              .onClick(()=>{
                router.pushUrl({url: "pages/History"})
              })
          }
        }
        else if (this.selectedTab === 'playlist') {
          Column() {
            Text('歌单')
          }
        }
        else if (this.selectedTab === 'my') {
          Column() {
            MinePage()
          }
        }
      }
      .height('85%')


      Column() {
        Row(){
          PlayBar()
        }
        Row() {
          Flex({ direction: FlexDirection.Row,justifyContent: FlexAlign.SpaceAround }) {
            // 首页按钮
            Column() {
              Image(this.selectedTab==='home'?$r('app.media.homefill'):$r('app.media.home'))
                .width(35)
                .height(35)
                .objectFit(ImageFit.Auto)
                .onClick(() => {
                  this.selectedTab = 'home';
                })
              Text('首页')
            }
            //歌单按钮
            Column() {
              Image(this.selectedTab==='playlist'?$r('app.media.playlistfill'):$r('app.media.playlist'))
                .width(35)
                .height(35)
                .borderRadius(5)
                .backgroundColor(this.selectedTab==='playlist'?Color.Black:'')
                .objectFit(ImageFit.Auto)
                .onClick(() => {
                  this.selectedTab = 'playlist';
                })
              Text('歌单')
            }
            // 我的按钮
            Column() {
              Image(this.selectedTab==='my'?$r('app.media.spacefill'):$r('app.media.space'))
                .width(35)
                .height(35)
                .objectFit(ImageFit.Auto)
                .onClick(() => {
                  this.selectedTab = 'my';
                })
              Text('我的')
            }
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