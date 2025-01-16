import { AxiosResponse } from '@ohos/axios'
import  { axios} from "./request"
import { PLAYLIST_MODULE } from './_prefix';

export interface playList {
  id: number | null;
  listName: string;
  imageUrl: string;
  creatorId: number | null;
  date: string | null;
  share: boolean;
  rate: number;
  rateNum: number;
  musicIds: number[];
  isFavorite: boolean | null;
}

export const EmptyPlayList:playList = {
  id: 0,
  listName: '',
  imageUrl: '',
  creatorId: null,
  date: null,
  share: false,
  rate: 0,
  rateNum: 0,
  musicIds: [],
  isFavorite: false
}

export const TestPlayList:playList = {
  id: 0,
  listName: 'test',
  imageUrl: '',
  creatorId: null,
  date: null,
  share: false,
  rate: 0,
  rateNum: 0,
  musicIds: [1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3],
  isFavorite: false
}

export interface musics {
  id: number;
  music_id: number | null;
  list_id: number;
}

export interface removeArgs {
  id: number;
  music_id: number;
  list_id: number;
}

export const createPlayList = async (playList: playList) => {
  return axios
    .post(`${PLAYLIST_MODULE}/create`, playList, {
      headers: {
        'Content-Type': 'application/json',
      },
    })
    .then((res:AxiosResponse) => {
      return res;
    });
};

export const getListIds = async () => {
  return axios.get(`${PLAYLIST_MODULE}/getListIds`).then((res:AxiosResponse) => {
    return res;
  });
};

export const getPlayListById = async (id: number) => {
  return axios
    .get(`${PLAYLIST_MODULE}/getList`, {
      params: {
        listId: id,
      },
    })
    .then((res:AxiosResponse) => {
      return res;
    });
};

export const addMusic = async (musics: musics) => {
  return axios
    .post(`${PLAYLIST_MODULE}/addMusic`, musics, {
      headers: {
        'Content-Type': 'application/json',
      },
    })
    .then((res:AxiosResponse) => {
      return res;
    });
};

export const deleteList = async (id: number) => {
  return axios
    .delete(`${PLAYLIST_MODULE}/delete`, {
      params: {
        listId: id,
      },
    })
    .then((res:AxiosResponse) => {
      return res;
    });
};

export const removeMusic = async (removeArgs: removeArgs) => {
  return axios
    .delete(`${PLAYLIST_MODULE}/removeMusic`, {
      params: {
        musicId: removeArgs.music_id,
        listId: removeArgs.list_id,
      },
    })
    .then((res:AxiosResponse) => {
      return res;
    });
};

export const getAllShareListIds = async () => {
  return axios.get(`${PLAYLIST_MODULE}/getAllShareListIds`).then((res:AxiosResponse) => {
    return res;
  });
};

export const favorite = async (listId: number) => {
  return axios.post(`${PLAYLIST_MODULE}/favorite?listId=${listId}`).then((res:AxiosResponse) => {
    return res;
  });
};

export const unFavorite = async (listId: number) => {
  return axios.delete(`${PLAYLIST_MODULE}/unfavorite`, { params: { listId: listId } }).then((res:AxiosResponse) => {
    return res;
  });
};

export const getFavoriteListIds = async () => {
  return axios.get(`${PLAYLIST_MODULE}/getFavoriteListIds`).then((res:AxiosResponse) => {
    return res;
  });
};
