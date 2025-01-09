import { Constants } from '../constants/Constants'

/**
 * 音乐类型
 */
export interface Music {
  id: number
  musicName: string
  singer: string
  musicUrl: string
  imageUrl: string
}

/**
 * 音乐播放策略，分别为随机播放、顺序播放、单曲循环
 */
export enum MusicPlayStrategy {
  RANDOM,
  SEQUENCE,
  LOOP
}

/**
 * 当前播放状态
 */
export enum PlayState {
  PAUSE,
  PLAYING
}

export const EmptyMusic: Music = {
  id: 0,
  musicName: "暂无歌曲",
  singer: "暂无",
  musicUrl: "",
  imageUrl: Constants.DEFAULT_MUSIC_IMAGE
}