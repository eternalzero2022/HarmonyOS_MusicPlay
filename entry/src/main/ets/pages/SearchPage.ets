import { DatabaseManager } from "../manager/DatabaseManager"
import { Music, PlayState, EmptyMusic } from '../viewmodel/MusicViewModel';
import { AVPlayerManager } from "../manager/AVPlayerManager"
import { Constants } from '../constants/Constants'
import { AxiosResponse } from '@ohos/axios';
import { searchMusic } from '../api/music';
import { router } from '@kit.ArkUI';
import { relationalStore, ValuesBucket } from "@kit.ArkData";
import { EmptyUser, User } from "../viewmodel/UserModel";

class content{
  id:number = 0
  userid:string = ''
  text:string = ''
}

interface NoteItem extends ValuesBucket {
  id: number | null // 新增时设置 id 为空值 null，用于自增 id
  userid: string
  text: string
}
@Entry
@Component
export struct SearchPage {

  @StorageLink('user') user: User = EmptyUser
  @State isRefreshing: boolean = false

  @State arr: Array<content> = [];
  @State List: Music[] = []
  @StorageProp('currentMusic') currentMusic: Music = EmptyMusic
  @StorageProp('currentState') currentState: PlayState = PlayState.PAUSE
  avPlayer: AVPlayerManager | null = null
  name: string = '';
  search: string = '0';
  controller: SearchController = new SearchController()

  tableName: string = 'search_history'

  sqlCreate: string = `CREATE TABLE IF NOT EXISTS ${this.tableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userid TEXT NOT NULL,
        text TEXT NOT NULL
      )`

  // 操作数据库的管理对象
  store: relationalStore.RdbStore | null = null
  // 获取数据库管理对象
  async getStoreInstance() {
    // 如果已经存在，直接返回
    if (this.store) {
      return this.store
    }
    // 获取操作数据库的管理对象(如果数据库文件不存在，会自动创建数据库文件)
    this.store = await relationalStore.getRdbStore(getContext(), {
      name: 'rdb.db', // 数据库文件名
      securityLevel: relationalStore.SecurityLevel.S1, // 数据库安全级别
    })
    // 执行创建表的语句 execute 执行
    this.store.executeSql(this.sqlCreate)
    // 返回 store 对象
    return this.store
  }

  async aboutToAppear() {
    this.avPlayer = await AVPlayerManager.getInstance()
    this.arr = []
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.orderByDesc('id')
    const resultSet = await store.query(predicates)
    while (resultSet.goToNextRow()) {
      if(resultSet.getString(resultSet.getColumnIndex('userid')) == this.user.id.toString()){
        let t = new content();
        t.id = resultSet.getLong(resultSet.getColumnIndex('id'))
        t.userid = resultSet.getString(resultSet.getColumnIndex('userid'))
        t.text = resultSet.getString(resultSet.getColumnIndex('text'));
        this.arr.push(t)
      }
    }
  }

  async playHistoryMusic(index: number) {
    let avPlayer = await AVPlayerManager.getInstance()
    await avPlayer.setMusicList(this.List.slice(index).concat(this.List.slice(0, index)))
  }

  async fetchRecommendedContent() {
    this.search = '1'
    searchMusic(this.name).then((res:AxiosResponse) => {
      if (res.data.code === '200') {
        const allMusic: Array<Music> = res.data.result;
        this.List = allMusic;
      }
    })
    if(this.name != ''){
      let same = 0;
      const store = await this.getStoreInstance()
      const predicates = new relationalStore.RdbPredicates(this.tableName)
      predicates.orderByDesc('id')
      const resultSet = await store.query(predicates)
      while (resultSet.goToNextRow()) {
        if(resultSet.getString(resultSet.getColumnIndex('userid')) == this.user.id.toString()){
          if( this.name ==resultSet.getString(resultSet.getColumnIndex('text'))){
            same = 1
          }
        }
      }
      if(same == 0){
        const id = await store.insert(this.tableName, {
          id: null,
          userid:this.user.id.toString(),
          text: this.name
        } as NoteItem)
      }
    }
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
    .onClick(async () => {
      // 获取操作数据库对象
      const store = await this.getStoreInstance()
      const predicates = new relationalStore.RdbPredicates(this.tableName)
      // 注意!!!：记得添加 predicates 限定条件，否者会删除所有数据
      // predicates.equalTo('id', 2)        // equalTo 删除一条
      predicates.in('id', [index]) //  in      批量删除
      const affectedRows = await store.delete(predicates)

      AlertDialog.show({ message: '受影响行数：' + affectedRows })
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
          this.search = '1'
          this.fetchRecommendedContent();
        })
        .onChange((value: string) => {
          this.name = value;
        })
        .margin(20)


      if(this.List.length < 1){
        if(this.search == '1'){
          Column() {
            Image($r('app.media.planet'))
              .width('80%')
              .height('80%')

            Text('哎呀，什么也没有找到呢...')
              .width('80%')
              .margin({ top: 10 })
              .fontSize(20)
          }
        }else{
          List() {
            ForEach(this.arr, (item: content ) => {
              ListItem() {
                Column(){
                  Text(item.text.toString())
                    .fontSize(12)
                    .textAlign(TextAlign.Center)
                    .size({height: 40, width: "100%"})

                }.onClick(()=>{
                  this.name = item.text.toString()
                  this.search = '1'
                  this.fetchRecommendedContent();
                })
              }.margin(6)
              .borderRadius(10)
              .backgroundColor("#FFFFFFFF")
              .swipeAction({ end: this.deleteHistory(item.id)})
            })
          }
          .width('100%')
          .height('100%')
          .backgroundColor("#FFDCDCDC")
        }

      }

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