import  { axios} from "./request"
import { AxiosResponse } from '@ohos/axios'
import { USER_MODULE, REGISTER_MODULE, USERLOGIN_MODULE, ADMINLOGIN_MODULE } from './_prefix';

export interface userInInfo {
  username: string;
  password: string;
}

export interface registerInfo {
  username: string;
  password: string;
}

export interface loginInfo {
  username: string;
  password: string;
}

export interface adminLoginInfo {
  username: string;
  password: string;
}
export const register = async (userInInfo: registerInfo) => {
  return axios
    .post(`${REGISTER_MODULE}`, userInInfo, {
      headers: {
        'Content-Type': 'application/json',
      },
    })
    .then((res:AxiosResponse) => {
      return res;
    });
};


export const userLogin = async (userInInfo: loginInfo) => {
  return axios
    .post(`${USERLOGIN_MODULE}`, userInInfo, {
      headers: {
        'Content-Type': 'application/json',
      },
    })
    .then((res:AxiosResponse) => {
      // localStorage.setItem('Token', res.data.result);
      AppStorage.setOrCreate<string>("Token",res.data.result)
      console.error("登陆成功",res.data.result);
      return res;
    });
};



export const getUserInfo = () => {
  return axios.get(`${USER_MODULE}`).then((res:AxiosResponse) => {
    return res;
  });
};
