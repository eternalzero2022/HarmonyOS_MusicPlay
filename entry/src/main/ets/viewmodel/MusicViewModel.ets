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