import  { axios} from "./request"
import { AxiosResponse, FormData } from '@ohos/axios'
import { IMAGE_MODULE } from './_prefix';

export const uploadImage = (imageData: ArrayBuffer)=>{
  let formData: FormData = new FormData();
  formData.append('file',imageData)
  return axios.post(`${IMAGE_MODULE}`,formData,{
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  }).then((res:AxiosResponse)=>{
    return res;
  })
}