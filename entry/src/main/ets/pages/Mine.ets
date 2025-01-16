import { User, EmptyUser } from '../viewmodel/UserModel'
import { router } from '@kit.ArkUI'
import { Constants } from '../constants/Constants'

@Entry
@Component
export struct MinePage {
  @StorageProp('user') user: User = EmptyUser

  aboutToAppear(): void {
    if (this.user.id == -1) {
      router.pushUrl({ url: Constants.LOGIN_PAGE })
    }
  }

  // @Builder
  // settingCell(item: MineItemData) {
  //   Row() {
  //     Row({ space: 12 }) {
  //       Image(item.image)
  //         .width(MinePageConstant.ICON_SIZE)
  //         .height(MinePageConstant.ICON_SIZE)
  //       Text(item.value)
  //         .fontSize(MinePageConstant.FONT_SIZE)
  //     }
  //   }
  //   .justifyContent(FlexAlign.SpaceBetween)
  //   .width(Constant.PERCENTAGE_100)
  //   .padding({
  //     left: 8, right: 22
  //   })
  // }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Row() {
          Image(this.user.imageUrl == '' ? Constants.DEFAULT_HEAD_IMAGE : this.user.imageUrl)
            .width(48)
            .height(48)
            .borderRadius('100%')
            .clip(true)
          Column() {
            Text(this.user.username)
              .fontSize(20)
            Text(this.user.id + '')
              .fontSize(12)
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 24 })
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

        //
        // List() {
        //   ForEach(this.itemList, (item: MineItemData) => {
        //     ListItem() {
        //       this.settingCell(item)
        //     }
        //     .height(MinePageConstant.LIST_ITEM_HEIGHT)
        //   }, (item: MineItemData) => JSON.stringify(item))
        // }
        // .backgroundColor(Color.White)
        // .width(Constant.PERCENTAGE_100)
        // // .height(Constant.PERCENTAGE_80)
        // .divider({
        //   strokeWidth: 1,
        //   color: Color.Grey,
        //   startMargin: 42,
        //   endMargin: 42
        // })
        // .borderRadius(16)
        // .padding({ top: 4, bottom: 4 })

        Blank()

        Button('退出登录', { type: ButtonType.Capsule })
          .width('90%')
          .height(40)
          .fontSize(16)
          .fontColor(0xFA2A2D)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(0xE5E8EA)
          .margin({ bottom: 55 })
          .onClick(() => {
            router.pushUrl({ url: Constants.LOGIN_PAGE })
          })
      }
      .height('100%')
    }
  }
}