import {AVPlayerManager} from "../manager/AVPlayerManager"
import { taskpool } from '@kit.ArkTS'
import { Music, MusicPlayStrategy, PlayState } from '../viewmodel/MusicViewModel';
import { DatabaseManager } from '../manager/DatabaseManager';
import { router } from '@kit.ArkUI';
import { PlayBar } from '../view/PlayBar'
/**
 * AVPlayerManager和DatabaseManager使用示例
 */
@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  
  @State strategy: MusicPlayStrategy = MusicPlayStrategy.SEQUENCE
  
  @State history:string = ""

  build() {
    Column(){
      PlayBar()

      Button('播放音乐')
        .width(200)
        .height(40)
        .margin({ top: 20 })
        .borderRadius(10)
        .backgroundColor('#00BFFF')
        .fontColor("FFFFFF")
        .fontSize(24)
        .onClick(()=>{
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
        .onClick(()=>{
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
        .onClick(()=>{
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
        .onClick(()=>{
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
        .onClick(()=>{
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
        .onClick(()=>{
          this.setTimeUpdateCallBack()
        })
      
      Text(this.message).fontSize(20)
      
      Button('设置播放策略')
        .width(200)
        .height(40)
        .margin({ top: 20 })
        .borderRadius(10)
        .backgroundColor('#00BFFF')
        .fontColor("FFFFFF")
        .fontSize(24)
        .onClick(()=>{
          this.changeStrategy()
        })
      Text("当前策略："+this.parseStrategy(this.strategy)).fontSize(20)

      Button('音乐进度至95%')
        .width(200)
        .height(40)
        .margin({ top: 20 })
        .borderRadius(10)
        .backgroundColor('#00BFFF')
        .fontColor("FFFFFF")
        .fontSize(24)
        .onClick(()=>{
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
        .onClick(()=>{
          this.getHistory()
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

      Text("历史记录："+this.history).fontSize(20)


    }
    .height('100%')
    .width('100%')
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