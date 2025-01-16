import { Music } from "../viewmodel/MusicViewModel";
import { taskpool } from "@kit.ArkTS";
import { relationalStore } from "@kit.ArkData";
import { SQL_CREATE_TABLE_MUSIC,
  SQL_DELETE_NOT_LAST_ROWS_TABLE_MUSIC,
  SQL_TABLE_MUSIC_NAME, STORE_CONFIG } from "../constants/DatabaseConstants";
import { BusinessError } from "@kit.BasicServicesKit";


/**
 * 数据库管理类，封装数据库操作
 */
export class DatabaseManager {
  /**
   * 保存一条历史记录到SQLite中。使用Taskpool机制实现多任务并发
   * 历史记录数量不超过100条
   * 如果历史记录中已经存在该歌曲，会覆盖原有的该歌曲的历史记录
   * @param music 待保存的Music对象
   * @param context 当前的Context，其它类中可以使用getContext(this)获取
   */
  static async saveMusicHistory(music: Music,context: Context){
    let task: taskpool.Task = new taskpool.Task(saveMusicHistoryTask,music,context)
    taskpool.execute(task).then(()=>{
      console.info("saveHistorySuccess")
    }).catch((e:Error)=>{
      console.error("saveHistoryFailed, message: "+e.message)
    })
  }
  
  /**
   * 删除所有历史记录。使用Taskpool机制实现多任务并发
   * @param context 当前的Context，其它类中可以使用getContext(this)获取
   */
  static async deleteAllHistory(context: Context){
    let task: taskpool.Task = new taskpool.Task(deleteAllHistoryTask,context)
    taskpool.execute(task).then(()=>{
      console.info("deleteAllHistorySuccess")
    }).catch((e:Error)=>{
      console.error("deleteAllHistoryFailed, message: "+e.message)
    })
  }
  
  /**
   * 获取所有历史记录。使用Taskpool机制实现多任务并发
   * @param context 当前的Context，其它类中可以使用getContext(this)获取
   * @returns 包含所有Music历史记录的数组的Promise，失败则reject
   */
  static async getAllHistory(context: Context): Promise<Array<Music>>{
    return new Promise((resolve,reject)=>{
      let task: taskpool.Task = new taskpool.Task(getAllHistoryTask,context)
      taskpool.execute(task).then((result:object)=>{
        let res = result as Array<Music>
        return resolve(res)
      }).catch((e:Error)=>{
        console.error("getAllHistoryFailed, message: "+e.message)
        return reject()
      })
    })
  }

  /**
   * 删除指定id的历史记录。使用Taskpool机制实现多任务并发
   * @param context 当前的Context，其它类中可以使用getContext(this)获取
   */
  static async deleteHistory(id: number, context: Context){
    let task: taskpool.Task = new taskpool.Task(deleteMusicHistoryTask, id, context)
    taskpool.execute(task).then(()=>{
      console.info("deleteHistorySuccess")
    }).catch((e:Error)=>{
      console.error("deleteHistoryFailed, message: "+e.message)
    })
  }
}


/**
 * 将歌曲历史记录保存至SQLite中。供Taskpool调用，实现多任务并发执行
 * @param music 待保存历史记录的音乐
 * @param context 当前的Context
 * @returns Promise，必然resolve
 */
@Concurrent
async function saveMusicHistoryTask(music: Music,context: Context): Promise<void>{
  relationalStore.getRdbStore(context, STORE_CONFIG,(err,store)=>{
    if(err){
      console.error('获取关系数据库失败')
      return
    }
    if(store.version === 0){//初始阶段，没有任何表
      store.executeSql(SQL_CREATE_TABLE_MUSIC)
      store.version = 1
    }

    store.executeSql(SQL_DELETE_NOT_LAST_ROWS_TABLE_MUSIC)//删除超过数量限制的数据

    //先删除已有的相同音乐id的数据
    let deletePredicates = new relationalStore.RdbPredicates(SQL_TABLE_MUSIC_NAME)
    deletePredicates.equalTo('MID', music.id)
    if(store !== undefined){
      (store as relationalStore.RdbStore).delete(deletePredicates,(err: BusinessError, rows:number)=>{
        if(err){
          console.error('删除存在的歌曲历史数据失败，错误码: '+err.code+'信息: '+err.message)
          return
        }else{
          console.info('删除存在的歌曲历史数据成功，删除行数: '+rows)

          //再插入新的历史记录
          const valueBucket: relationalStore.ValuesBucket = {
            'MID': music.id,
            'MUSICNAME': music.musicName,
            'SINGER': music.singer,
            'MUSICURL': music.musicUrl,
            'IMAGEURL': music.imageUrl
          }

          //插入数据
          if(store !== undefined){
            (store as relationalStore.RdbStore).insert(SQL_TABLE_MUSIC_NAME,valueBucket,(err: BusinessError, rowId: number)=>{
              if(err){
                console.error('存储歌曲历史数据失败，错误码: '+err.code+'信息: '+err.message)
                return
              }else{
                console.info('插入数据成功，rowId:'+rowId)
                return
              }
            })
          }
        }
      })
    }
  })
}

/**
 * 从SQLite中删除所有历史记录。供Taskpool调用，实现多任务并发执行
 * @param context 当前的Context
 * @returns 是否成功删除的Promise，成功则resolve，失败则reject
 */
@Concurrent
async function deleteAllHistoryTask(context: Context): Promise<void>{
  return await new Promise((resolve,reject)=>{
    relationalStore.getRdbStore(context, STORE_CONFIG,(err,store)=>{
      if(err){
        console.error('获取关系数据库失败')
        return reject()
      }
      if(store.version === 0){//初始阶段，没有任何表
        store.executeSql(SQL_CREATE_TABLE_MUSIC)
        store.version = 1
      }

      //先删除已有的相同音乐id的数据
      let deletePredicates = new relationalStore.RdbPredicates(SQL_TABLE_MUSIC_NAME)
      if(store !== undefined){
        (store as relationalStore.RdbStore).delete(deletePredicates,(err: BusinessError, rows:number)=>{
          if(err){
            console.error('删除历史记录失败，错误码: '+err.code+'信息: '+err.message)
            return reject()
          }else{
            console.info('删除历史记录成功，删除行数: '+rows)
            return resolve()
          }
        })
      }else{
        return reject()
      }
    })
  })
}

/**
 * 从SQLite中获取所有历史记录。供Taskpool调用，实现多任务并发执行
 * @param context 当前的Context，其它类中可以使用getContext(this)获取
 * @returns 包含所有Music历史记录的数组的Promise，失败则reject
 */
@Concurrent
async function getAllHistoryTask(context: Context):Promise<Array<Music>>{
  return await new Promise((resolve,reject)=>{
    relationalStore.getRdbStore(context, STORE_CONFIG,(err,store)=>{
      if(err){
        console.error('获取关系数据库失败')
        return reject([])
      }
      if(store.version === 0){//初始阶段，没有任何表
        store.executeSql(SQL_CREATE_TABLE_MUSIC)
        store.version = 1
      }

      let getPredicates = new relationalStore.RdbPredicates(SQL_TABLE_MUSIC_NAME)
      getPredicates.orderByDesc('ID')
      if(store !== undefined){
        (store as relationalStore.RdbStore).query(getPredicates,['MID','MUSICNAME','SINGER','MUSICURL','IMAGEURL'],(err: BusinessError, resultSet)=>{
          if(err){
            console.error('查询历史记录失败，错误码: '+err.code+'信息: '+err.message)
            return reject([])
          }
          console.info("历史记录数量: "+resultSet.rowCount)

          let musicList: Array<Music> = []
          while (resultSet.goToNextRow()){
            const music: Music = {
              id: resultSet.getLong(resultSet.getColumnIndex('MID')),
              musicName: resultSet.getString(resultSet.getColumnIndex('MUSICNAME')),
              singer: resultSet.getString(resultSet.getColumnIndex('SINGER')),
              musicUrl: resultSet.getString(resultSet.getColumnIndex('MUSICURL')),
              imageUrl: resultSet.getString(resultSet.getColumnIndex('IMAGEURL'))
            }
            musicList.push(music)
          }
          console.info("即将返回musiclist")
          return resolve(musicList)

        })
      }else{
        return reject([])
      }
    });
  })
}

/**
 * 删除指定id的历史记录
 * @param id 待删除的历史记录id
 * @param context 当前的Context
 * @returns Promise
 */
@Concurrent
async function deleteMusicHistoryTask(id: number, context: Context): Promise<void>{
  relationalStore.getRdbStore(context, STORE_CONFIG,(err,store)=>{
    if(err){
      console.error('获取关系数据库失败')
      return
    }
    if(store.version === 0){//初始阶段，没有任何表
      store.executeSql(SQL_CREATE_TABLE_MUSIC)
      store.version = 1
    }


    //先删除已有的相同音乐id的数据
    let deletePredicates = new relationalStore.RdbPredicates(SQL_TABLE_MUSIC_NAME)
    deletePredicates.equalTo('MID', id)
    if(store !== undefined){
      (store as relationalStore.RdbStore).delete(deletePredicates,(err: BusinessError, rows:number)=>{
        if(err){
          console.error('删除存在的歌曲历史数据失败，错误码: '+err.code+'信息: '+err.message)
          return
        }else{
          console.info('删除存在的歌曲历史数据成功，删除行数: '+rows)

        }
      })
    }
  })
}

