import {
  PhotoPickerComponent,
  PickerController,
  PickerOptions,
  DataType,
  BaseItemInfo,
  ItemInfo,
  PhotoBrowserInfo,
  ItemType,
  ClickType,
  MaxCountType,
  PhotoBrowserRange,
  ReminderMode,
} from '@ohos.file.PhotoPickerComponent';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import { router } from '@kit.ArkUI';


/**
 * PhotoPicker页面，在需要选择图片的时候调用，例如选择歌单封面
 * 该页面中选择完图片后会自动调用router.back()返回上一级页面，且params参数中包含picUri的参数，表示图片的uri
 * 获取到图片Uri后仍需自己实现加载图片的逻辑
 */
@Entry
@Component
struct PhotoPicker {
  pickerOptions: PickerOptions = new PickerOptions();

  @State
  pickerController: PickerController = new PickerController();

  @State
  selectedUris: Array<string> = new Array<string>();

  @State
  currentUri: string = '';

  @State
  isBrowserShow: boolean = false

  @State
  message: string = "确定"

  aboutToAppear(): void {
    // picker宫格页数据类型
    this.pickerOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE

    // 最大选择数量
    this.pickerOptions.maxSelectNumber = 1

    //超出最大选择数量时
    this.pickerOptions.maxSelectedReminderMode = ReminderMode.TOAST

    //是否展示搜索框
    this.pickerOptions.isSearchSupported = false;

    //是否支持拍照
    this.pickerOptions.isPhotoTakingSupported = false;
  }

  //资源被选中回调
  private onItemClicked(itemInfo: ItemInfo, clickType: ClickType): boolean {
    if(!itemInfo){
      return false
    }
    let type: ItemType | undefined = itemInfo.itemType;
    let uri: string | undefined = itemInfo.uri;
    if(type === ItemType.CAMERA){
      return false
    }else{
      if(clickType === ClickType.SELECTED){//选中
        //应用自己业务处理

        if(uri){
          this.selectedUris.push(uri)
          this.pickerOptions.preselectedUris = [...this.selectedUris]
        }
        return true
      }else{//取消选中，UNSELECTED
        if (uri) {
          this.selectedUris = this.selectedUris.filter((item: string) => {
            return item != uri;
          });
          this.pickerOptions.preselectedUris = [...this.selectedUris];
        }
      }
      return true
    }
  }

  //进入大图的回调
  private onEnterPhotoBrowser(photoBrowserInfo: PhotoBrowserInfo): boolean {
    this.isBrowserShow = true
    return true
  }

  // 退出大图的回调
  private onExitPhotoBrowser(photoBrowserInfo: PhotoBrowserInfo): boolean {
    this.isBrowserShow = false;
    return true;
  }

  // 大图左右滑动的回调
  private onPhotoBrowserChanged(browserItemInfo: BaseItemInfo): boolean {
    this.currentUri = browserItemInfo.uri ?? '';
    return true;
  }

  private onPickerControllerReady(): void {
  }


  build() {
    Flex({
      direction: FlexDirection.Column,
      alignItems: ItemAlign.Start
    }) {
      Text('选择一张图片').alignSelf(ItemAlign.Center).margin(10)

      PhotoPickerComponent({
        pickerOptions: this.pickerOptions,
        onItemClicked: (itemInfo: ItemInfo, clickType: ClickType): boolean => this.onItemClicked(itemInfo,clickType),
        onEnterPhotoBrowser: (photoBrowserInfo: PhotoBrowserInfo): boolean => this.onEnterPhotoBrowser(photoBrowserInfo),
        onExitPhotoBrowser: (photoBrowserInfo: PhotoBrowserInfo): boolean => this.onExitPhotoBrowser(photoBrowserInfo),
        onPickerControllerReady: ():void => this.onPickerControllerReady(),
        onPhotoBrowserChanged: (browserItemInfo: BaseItemInfo): boolean => this.onPhotoBrowserChanged(browserItemInfo),
        pickerController: this.pickerController,
      })

      Button("确定")
        .width('33%')
        .alignSelf(ItemAlign.Center)
        .height('5%')
        .margin(10)
        .enabled(this.selectedUris.length > 0)
        .onClick(() => {
        if (this.selectedUris.length > 0) {
          router.back({
            url: 'pages/Index',
            params: {
              picUri: this.selectedUris[0]
            }
          });
        }
      })
    }
  }
}