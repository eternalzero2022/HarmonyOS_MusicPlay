import {userLogin, getUserInfo} from '../api/user'
import axios, { AxiosResponse } from '@ohos/axios'
import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { User } from '../viewmodel/UserModel'

@Entry
@Component

struct UserLogin {
  // 用户名和密码的绑定变量
  username: string = '';
  password: string = '';

  async handleLogin() {
    userLogin({username: this.username, password: this.password}).then((res:AxiosResponse) => {
      if (res.data.code === '200') {
        // 登录成功
        getUserInfo().then((res:AxiosResponse) => {
          if (res.data.code === '200') {
            //localStorage.setItem('Id', res.data.result.id);
            AppStorage.setOrCreate<number>("Id",res.data.result.id)
            AppStorage.setOrCreate<User>("user", res.data.result)
            console.error("Id 是",AppStorage.get('Id'))
          }
        });
        router.back()
      } else if (res.data.code === '400') {
        // 登录失败
        AlertDialog.show({
          title: "警告",
          message: "用户名或密码错误",
          alignment: DialogAlignment.Center,
          confirm: {
            value: "确认",
            fontColor: Color.Black,
            backgroundColor: "#aabbcc",
            action: () => {
              console.log("点击了")
            }
          }
        })
      }
    })
      .catch((error:BusinessError) => {
        console.log(error.message);
        AlertDialog.show({
          title: "警告",
          message: "用户名或密码错误",
          alignment: DialogAlignment.Center,
          confirm: {
            value: "确认",
            fontColor: Color.Black,
            backgroundColor: "#aabbcc",
            action: () => {
              console.log("点击了")
            }
          }
        })
      });
  }

  build() {
    Stack() {
      Column() {
        // 顶部的欢迎文字

        Column() {
          RelativeContainer() {
            Text('请登录')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.Red)
              .alignRules({
                top: { anchor: '__container__', align: VerticalAlign.Top },
                center: { anchor: '__container__', align: VerticalAlign.Center }
              })
              .width('100%');

          }
          .height('30%')
          .width('100%')
          .padding({ left: 32, right: 32 })
          .backgroundColor(Color.White);

          // 用户名和密码输入框
          Column() {
            // 用户名输入框
            Column() {
              TextInput({ placeholder: '请输入用户名', text: this.username })
                .onChange((value: string) => {
                  this.username = value;
                })
                .fontSize(18)
                .fontColor(Color.Black)
                .width('100%')
                .height(50)
                .padding({ left: 10, right: 10 });
              Divider().height(1).color('#194487fe'); // 下划线
            }

            // 密码输入框
            Column() {
              TextInput({ placeholder: '请输入密码', text: this.password })
                .onChange((value: string) => {
                  this.password = value;
                })
                .fontSize(18)
                .fontColor(Color.Black)
                .width('100%')
                .height(50)
                .padding({ left: 10, right: 10 })
                .type(InputType.Password);
              Divider().height(1).color('#194487fe'); // 下划线
            }.margin({ top: 32 });
          }
          .width('100%')
          .padding({ left: 32, right: 32 })
          .backgroundColor(Color.White);

          Row(){
            Button('登 录')
              .width('40%')
              .height(50)
              .backgroundColor(Color.Red)
              .fontSize(18)
              .fontColor(Color.White)
              .onClick(() => {
                this.handleLogin();
              })
              .margin({ top: 56 });
            Button('去注册')
              .width('40%')
              .height(50)
              .backgroundColor(Color.Red)
              .fontSize(18)
              .fontColor(Color.White)
              .onClick(() => {
                router.pushUrl({url: "pages/UserRegister"})
              })
              .margin({ top: 56 });
          }
          // 登录按钮

        }
        .height('100%')
        .width('100%')
        .backgroundColor(Color.White)
        .justifyContent(FlexAlign.SpaceBetween);

      }
    }
  }

}
