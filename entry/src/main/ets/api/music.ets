import  { axios} from "./request"
import { AxiosResponse } from '@ohos/axios'
import { MUSIC_MODULE } from './_prefix';


export const getAllMusic = () => {
  return axios.get(`${MUSIC_MODULE}/all`).then((res:AxiosResponse) => {
    return res;
  });
};

export const getMusicById = async (musicId: number) => {
  return axios.get(`${MUSIC_MODULE}/getMusicById`, { params: { musicId: musicId } }).then((res:AxiosResponse) => {

    return res;
  });
};


export const searchMusic = async (key: string) => {
  return axios.get(`${MUSIC_MODULE}/search`, { params: { key: key } }).then((res:AxiosResponse) => {
    return res;
  });
}
