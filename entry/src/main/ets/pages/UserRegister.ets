import {userLogin, getUserInfo, register} from '../api/user'
import axios, { AxiosResponse } from '@ohos/axios'
import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { preferencesManager } from '../manager/PreferencesManager';
import { preferences} from '@kit.ArkData';
@Entry
@Component

struct UserRegister {
  // 用户名和密码的绑定变量
  @State username: string = '';
  @State password: string = '';

  async handleRegister(){
    register({
      username: this.username,
      password: this.password
    }).then((res:AxiosResponse) => {
      if (res.data.code === '200') {
        promptAction.showToast({message:"注册成功"})
        preferencesManager.put("username", this.username)
        preferencesManager.flush()
        router.replaceUrl({ url : 'pages/UserLogin' });
      } else if (res.data.code === '400') {
        AlertDialog.show({
          title: "警告",
          message: "用户名已经存在",
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
    });
  }

  build() {
    Stack() {

      Column() {
        Blank().height('5%')
        RelativeContainer() {
          Text('请注册')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Red)
            .alignRules({
              top: { anchor: '__container__', align: VerticalAlign.Top },
              center: { anchor: '__container__', align: VerticalAlign.Center }
            })
            .width('100%');

        }
        .height(50)
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

        Row() {
          Button('注 册')
            .width('30%')
            .height(50)
            .backgroundColor(Color.Red)
            .fontSize(18)
            .fontColor(Color.White)
            .onClick(() => {
              this.handleRegister();
            })
            .margin({ top: 20 });
          Button('去登录')
            .width('30%')
            .height(50)
            .backgroundColor(0xF2F3F5)
            .fontSize(18)
            .fontColor(Color.Black)
            .onClick(() => {
              router.pushUrl({ url: "pages/UserLogin" })
            })
            .margin({ top: 20 });
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)

      }
      .height('80%')
      .width('100%')
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.SpaceBetween);

    }
  }

}
