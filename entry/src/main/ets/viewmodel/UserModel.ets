import { Constants } from '../constants/Constants'

export interface User {
  id: number
  username: string
  password: string
  imageUrl: string
  isManager: boolean
  likeListId: number
  collectedPlayLists: number[]
}

export const EmptyUser: User = {
  id: -1,
  username: "未登录",
  password: "",
  imageUrl: Constants.DEFAULT_HEAD_IMAGE,
  isManager: false,
  likeListId: -1,
  collectedPlayLists: []
}