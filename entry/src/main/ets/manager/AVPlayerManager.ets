import { media } from "@kit.MediaKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { audio } from "@kit.AudioKit";
import { DatabaseManager } from "./DatabaseManager";
import { Music, MusicPlayStrategy, PlayState, EmptyMusic } from "../viewmodel/MusicViewModel";
import App from "@system.app";

/**
 * 音乐播放逻辑实现类。提供一些与音乐播放相关的方法，供其它组件调用播放
 * 单例类，需要调用getInstance获取实例
 */
export class AVPlayerManager{
  private avPlayer: media.AVPlayer | null = null;

  private timeUpdateCallback: (time: number)=>void = (time: number)=>{}

  private prepareCallback: (musicTime: number)=>void = (musicTime: number)=>{}

  private musicList: Array<Music> = []

  private currentMusicIndex = 0;

  private strategy: MusicPlayStrategy = MusicPlayStrategy.SEQUENCE;

  private currentMusic: SubscribedAbstractProperty<Music> = AppStorage.link('currentMusic')

  private currentState: SubscribedAbstractProperty<PlayState> = AppStorage.link('currentState')

  private currentStrategy: SubscribedAbstractProperty<MusicPlayStrategy> = AppStorage.link('currentStrategy')

  private currentTime: SubscribedAbstractProperty<number> = AppStorage.link('currentTime')

  private totalTime: SubscribedAbstractProperty<number> = AppStorage.link('totalTime')

  private time: number = 0

  private static instance: AVPlayerManager;

  private constructor() {
    AppStorage.setOrCreate('currentMusic', EmptyMusic)
    AppStorage.setOrCreate('currentState', PlayState.PAUSE)
    AppStorage.setOrCreate('currentStrategy', MusicPlayStrategy.SEQUENCE)
    AppStorage.setOrCreate('currentTime', 0)
    AppStorage.setOrCreate('totalTime', 1)

    this.currentMusic = AppStorage.link('currentMusic')
    this.currentState = AppStorage.link('currentState')
    this.currentStrategy = AppStorage.link('currentStrategy')
    this.currentTime = AppStorage.link('currentTime')
    this.totalTime = AppStorage.link('totalTime')

    this.timeUpdateCallback = (time: number)=> {
      if (time - this.time <= 1000) return
      this.time = time
      console.log('AVPlayer timeUpdate ' + time)
      this.currentTime.set(time)
    }
  }

  public clear(){
    AppStorage.setOrCreate('currentMusic', EmptyMusic)
    AppStorage.setOrCreate('currentState', PlayState.PAUSE)
    AppStorage.setOrCreate('currentStrategy', MusicPlayStrategy.SEQUENCE)
    AppStorage.setOrCreate('currentTime', 0)
    AppStorage.setOrCreate('totalTime', 1)
    this.musicList = []
    this.time = 0
    this.avPlayer?.reset()
  }

  public static async getInstance(): Promise<AVPlayerManager>{
    if(!AVPlayerManager.instance){
      console.info("即将创建实例")
      AVPlayerManager.instance = new AVPlayerManager();
      await AVPlayerManager.instance.init()
    }
    return AVPlayerManager.instance;
  }





  /**
   * 设置当前的播放列表。设置完毕后即自动播放该列表中的音乐，并在一首音乐播放完毕后根据音乐策略自动切换至下一首音乐
   * @param musicList 音乐播放列表
   */
  async setMusicList(musicList: Array<Music>){
    this.musicList = musicList
    if(musicList.length > 0){
      if(this.strategy === MusicPlayStrategy.SEQUENCE || this.strategy === MusicPlayStrategy.LOOP){
        this.currentMusicIndex = 0
      }else if(this.strategy === MusicPlayStrategy.RANDOM){
        this.currentMusicIndex = Math.floor(Math.random() * musicList.length)
      }
      await this.loadListMusic()
    }
  }

  /**
   * 设置音乐播放策略，分为顺序播放、随机播放、单曲循环。
   * 默认为顺序播放
   * @param strategy 音乐播放策略
   */
  setStrategy(strategy: MusicPlayStrategy){
    this.strategy = strategy
    this.currentStrategy.set(strategy)
  }

  /**
   * 跳转至播放列表中的下一首曲子。若此时音乐列表为空，则重新播放当前正在播放的曲子
   */
  async jumpToNextMusic(){
    if(this.avPlayer){
      if(this.musicList.length === 0){
        if(this.avPlayer.state === 'prepared'){
          this.avPlayer.seek(0)
          this.avPlayer.play()
        }
      }else{
        if(this.strategy === MusicPlayStrategy.SEQUENCE){
          this.currentMusicIndex = (this.currentMusicIndex + 1) % this.musicList.length
        }else if(this.strategy === MusicPlayStrategy.RANDOM){
          let nextIndex = Math.floor(Math.random() * (this.musicList.length-1))
          if(nextIndex >= this.currentMusicIndex){
            nextIndex++
          }
          if(this.musicList.length === 1){
            nextIndex = 0
          }
          this.currentMusicIndex = nextIndex
        }else if(this.strategy === MusicPlayStrategy.LOOP){
          this.currentMusicIndex = (this.currentMusicIndex + 1) % this.musicList.length
        }
        await this.loadListMusic()
      }
    }
  }

  /**
   * 跳转至播放列表中的上一首曲子。若此时音乐列表为空，则重新播放当前正在播放的曲子
   */
  async jumpToPrevMusic(){
    if(this.avPlayer){
      if(this.musicList.length === 0){
        if(this.avPlayer.state === 'prepared'){
          this.avPlayer.seek(0)
          this.avPlayer.play()
        }
      }else{
        if(this.strategy === MusicPlayStrategy.SEQUENCE){
          this.currentMusicIndex = (this.currentMusicIndex + this.musicList.length - 1) % this.musicList.length
        }else if(this.strategy === MusicPlayStrategy.RANDOM){
          let nextIndex = Math.floor(Math.random() * (this.musicList.length-1))
          if(nextIndex >= this.currentMusicIndex){
            nextIndex++
          }
          if(this.musicList.length === 1){
            nextIndex = 0
          }
          this.currentMusicIndex = nextIndex
        }else if(this.strategy === MusicPlayStrategy.LOOP){
          this.currentMusicIndex = (this.currentMusicIndex + this.musicList.length - 1) % this.musicList.length
        }
        await this.loadListMusic()
      }
    }
  }

  /**
   * 跳转到播放列表中指定位置的歌曲
   */
  async jumpTo(index: number) {
    if (this.avPlayer && index >= 0 && index < this.musicList.length) {
      this.currentMusicIndex = index
      await this.loadListMusic()
    }
  }


  /**
   * 暂停播放音乐。可以通过调用continue函数继续播放音乐
   */
  async pause(){
    if(this.avPlayer){
      this.currentState.set(PlayState.PAUSE)
      await this.avPlayer.pause()
    }
  }

  /**
   * 在音乐暂停后继续播放音乐。从暂停的位置开始继续播放
   */
  async continue(){
    if(this.avPlayer){
      this.currentState.set(PlayState.PLAYING)
      await this.avPlayer.play()
    }
  }

  /**
   * 设置当前音乐播放进度。使用百分比设定，音乐会跳转至整首音乐的该百分比处开始播放
   * @param timePercent 要跳转到的音乐播放进度百分比
   */
  async seekByPercent(timePercent: number){
    if(timePercent > 1){
      return
    }
    if(this.avPlayer){
      this.time = 0
      this.avPlayer.seek(this.avPlayer.duration * timePercent)
    }
  }

  /**
   * 设置当前音乐播放进度。使用绝对时间来设定，单位为毫秒，音乐会跳转至整首音乐的该时间处开始播放
   * @param time 要跳转至的音乐播放进度时间，单位为毫秒
   */
  async seekByTime(time: number){
    if(this.avPlayer){
      this.time = 0
      this.avPlayer.seek(time)
    }
  }

  /**
   * 设置当音乐进度变化的时候的回调函数，回调函数的参数为当前音乐播放进度时间。
   * 可用于更新进度条
   * @param callBack 音乐播放进度变化时候的回调函数
   */
  async setTimeUpdateCallBack(callBack: (time: number)=>void){
    this.timeUpdateCallback = callBack
  }

  /**
   * 设置当加载新的音乐的时候的回调函数，回调函数的参数为当前音乐的总时长
   * 可用于为进度条设置当前音乐时长
   * @param callBack 加载新音乐的时候的回调函数
   */
  async setPrepareCallBack(callBack: (musicTime: number)=>void){
    this.prepareCallback = callBack
  }

  /**
   * 加载新的音乐并播放。
   * 通常由本类内函数调用，一般不推荐其它类直接调用该函数
   * @param url 音乐url
   */
  async loadMusic(url:string){
    if(this.avPlayer){
      this.currentMusic.set(this.musicList[this.currentMusicIndex])
      this.currentState.set(PlayState.PLAYING)
      await this.avPlayer.reset()
      this.avPlayer.url = url
    }
  }

  /**
   * 新增方法：开始播放指定的歌曲
   * @param song 要播放的歌曲
   */
  async playSong(song: Music){
    try {
      // 检查歌曲是否在当前播放列表中
      const index = this.musicList.findIndex(m => m.id === song.id)
      if(index !== -1){
        // 歌曲在播放列表中，设置当前索引并播放
        this.currentMusicIndex = index
      } else {
        // 歌曲不在播放列表中，插入到列表首位
        this.musicList.unshift(song)
        this.currentMusicIndex = 0
      }
      await this.loadListMusic()
    } catch (error) {
      console.error('播放指定歌曲失败:', error)
      // 可以添加用户提示或其他错误处理逻辑
    }
  }


  /**
   * 初始化avplayer
   */
  private async init(){
    let avPlayer: media.AVPlayer = await media.createAVPlayer();
    this.setAVPlayerCallback(avPlayer)
    this.avPlayer = avPlayer
  }

  /**
   * 设置avplayer的一些事件的回调函数，在初始化时调用
   * @param avPlayer 播放器实例
   */
  private setAVPlayerCallback(avPlayer: media.AVPlayer){
    //seek操作结果回调函数
    avPlayer.on('seekDone',(seekDoneTime: number)=>{
      console.info('AVPlayer seek成功，seek时间：'+seekDoneTime)
    })

    //err回调监听函数，当avplayer在操作过程中出现错误时调用reset接口触发重置流程
    avPlayer.on('error',(error: BusinessError)=>{
      console.error('Invoke avPlayer失败，错误码：'+error.code+'，错误信息：'+error.message)
      avPlayer.reset()//调用reset重置资源，触发idle状态
    })

    avPlayer.on('timeUpdate',(time: number)=>{
      this.timeUpdateCallback(time)
    })

    // 设置歌曲总时长
    avPlayer.on('durationUpdate', (duration: number) => {
      console.info('AVPlayer durationUpdate' + duration)
      this.totalTime.set(duration)
    })

    //状态机变化回调函数
    avPlayer.on('stateChange',async (state: string,reason: media.StateChangeReason)=>{
      switch (state){
      //成功调用reset接口
        case 'idle':
          console.info('AVPlayer state idle 被调用')
          break

      //avplayer设置播放源后触发该上报
        case 'initialized':
          console.info('AVPlayer state initialized 被调用')
          avPlayer.audioRendererInfo = {
            usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
            rendererFlags: 0
          }// 177711
          avPlayer.prepare()
          break

      //prepare调用成功后触发
        case 'prepared':
          console.info('AVPlayer state prepared 被调用')
          this.prepareCallback(avPlayer.duration)
          avPlayer.play()
          break

      //play成功调用后触发
        case 'playing':
          console.info('AVPlayer state playing 被调用')
          break

      //pause成功调用后触发
        case 'paused':
          console.info('AVplayer state paused 被调用')
          break

      //播放结束后触发
        case 'completed':
          console.info('AVPlayer state completed 被调用')
          //根据策略选择下一首歌
          if(this.musicList.length === 0){
            avPlayer.seek(0)
            avPlayer.play()
            break
          }
          if(this.strategy === MusicPlayStrategy.SEQUENCE){
            this.currentMusicIndex = (this.currentMusicIndex + 1) % this.musicList.length
            this.loadListMusic()
          }else if(this.strategy === MusicPlayStrategy.RANDOM){
            let nextIndex = Math.floor(Math.random() * (this.musicList.length-1))
            if(nextIndex >= this.currentMusicIndex){
              nextIndex++
            }
            if(this.musicList.length === 1){
              nextIndex = 0
            }
            this.currentMusicIndex = nextIndex
            this.loadListMusic()
          }else if(this.strategy === MusicPlayStrategy.LOOP){
            avPlayer.seek(0)
            avPlayer.play()
          }
          break

      //stop接口成功调用时触发
        case 'stopped':
          console.info('AVPlayer state stopped 被调用')
          break

      //released
        case 'released':
          console.info('AVPlayer state released 被调用')
          break

        default :
          console.info('AVPlayer state unknown 被调用')
          break
      }
    })
  }

  /**
   * 加载当前指向的音乐列表中的音乐并播放
   * 会同时存储播放的历史记录
   */
  private async loadListMusic(){
    if(this.avPlayer){
      if(this.currentMusicIndex >= 0 && this.currentMusicIndex < this.musicList.length){
        this.time = 0
        await this.loadMusic(this.musicList[this.currentMusicIndex].musicUrl)
        this.saveHistory(this.musicList[this.currentMusicIndex])
      }
    }
  }

  /**
   * 将当前播放的音乐存入历史记录
   * @param music 当前播放的音乐
   */
  private async saveHistory(music: Music){
    DatabaseManager.saveMusicHistory(music,getContext(this))
  }


  getMusicList() {
    return this.musicList
  }

}