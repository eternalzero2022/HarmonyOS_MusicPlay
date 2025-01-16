import axios, { AxiosResponse } from '@ohos/axios'

import { MUSIC_MODULE } from './_prefix';

export interface musicInfo {
  id: number | null;
  musicName: string;
  lyric: string;
  musicUrl: string;
  imageUrl: string;
  rate: number;
  rateNum: number;
  singer: string;
}



export const createMusic = (musicInfo: musicInfo) => {
  return axios
    .post(`${MUSIC_MODULE}/createMusic`, musicInfo, {
      headers: {
        'Content-Type': 'application/json',
      },
    })
    .then((res: AxiosResponse<object>) => {
      return res;
    });
};

export const getAllMusic = () => {
  return axios.get(`${MUSIC_MODULE}/all`).then((res:AxiosResponse<object>) => {
    return res;
  });
};

export const getMusicById = async (musicId: number) => {
  return axios.get(`${MUSIC_MODULE}/getMusicById`, { params: { musicId: musicId } }).then((res:AxiosResponse<object>) => {

    return res;
  });
};

export const deleteMusic = async (musicId: number) => {
  return axios.delete(`${MUSIC_MODULE}/deleteMusic`,{params:{musicId:musicId}}).then((res:AxiosResponse<object>) => {
    return res;
  });
};

export const searchMusic = async (key: string) => {
  return axios.get(`${MUSIC_MODULE}/search`, { params: { key: key } }).then((res:AxiosResponse<object>) => {
    return res;
  });
}
