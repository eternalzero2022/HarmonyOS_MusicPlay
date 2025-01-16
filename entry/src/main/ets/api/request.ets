import axios, { AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios'
import { BusinessError } from '@ohos.base';

const service = axios.create();
service.interceptors.request.use(
  (config:InternalAxiosRequestConfig) => {
    console.log('请求 URL:', config.url);
    console.log('请求方法:', config.method);
    console.log('请求数据:', config.data);
    console.log('请求参数:', config.params);
    console.log('请求头:', config.headers);
    if (AppStorage.get('Token')) {
      config.headers['Token'] = AppStorage.get('Token');
    }
    return config;
  },
  (error:BusinessError) => {
    console.log(error.message);
    return Promise.reject();
  },
);
export { service as axios };
