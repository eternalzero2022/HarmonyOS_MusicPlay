import { User, EmptyUser } from '../viewmodel/UserModel'
import { router } from '@kit.ArkUI'
import { Constants } from '../constants/Constants'
import { History } from '../pages/History'
import { AVPlayerManager } from '../manager/AVPlayerManager'

@Entry
@Component
export struct MinePage {
  @StorageLink('user') user: User = EmptyUser

  aboutToAppear(): void {
    if (this.user.id == -1) {
      // router.pushUrl({ url: Constants.LOGIN_PAGE })
    }
  }

  async reset(){
    this.user = EmptyUser
    AVPlayerManager.getInstance().then((Manager: AVPlayerManager)=>{
      Manager.clear()
    })
    AppStorage.setOrCreate<number>("Id",-1)
    AppStorage.setOrCreate<string>("Token","")
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Row() {
          Row() {
            Image(this.user.imageUrl == '' || this.user.imageUrl == null ? Constants.DEFAULT_HEAD_IMAGE :
            this.user.imageUrl)
              .width(48)
              .height(48)
              .borderRadius('100%')
              .clip(true)
            Column() {
              Text(this.user.username)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)

              if (this.user.id != -1) {
                Text('UID: ' + this.user.id)
                  .fontSize(12)
                  .margin({ top: 4 })
              }
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 24 })
          }
          .layoutWeight(1)
          .align(Alignment.Start)
          .onClick(() => {
            if (this.user.id == -1) {
              router.pushUrl({ url: Constants.LOGIN_PAGE })
            }
          })

          if (this.user.id != -1) {
            Row() {
              Button('退出登录', { type: ButtonType.Capsule })
                .width('60%')
                .height(40)
                .fontSize(16)
                .fontColor(0xFA2A2D)
                .fontWeight(FontWeight.Medium)
                .backgroundColor(0xE5E8EA)
                .onClick(() => {
                  this.reset()
                })
            }
            .width('30%')
            .padding({ right: 10 })
            .layoutWeight(1)
            .justifyContent(FlexAlign.End)
          }

        }
        .margin({ top: 24 })
        .alignItems(VerticalAlign.Center)
        .width('100%')
        .height(96)
        .backgroundColor(Color.White)
        .padding({ left: 24 })
        .borderRadius(16)
        .onClick(() => {
          if (this.user.id == -1) {
            router.pushUrl({ url: Constants.LOGIN_PAGE })
          }
        })


        History()
          .backgroundColor(Color.White)
          .borderRadius(16)
          .padding({ top: 4, bottom: 4 })


      }
      .height('100%')
    }
    .backgroundColor(0xF1F3F5)
  }
}