import { dataSharePredicates } from '@kit.ArkData';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

const context = getContext(this);
let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context)


class MediaDataHandler implements photoAccessHelper.MediaAssetDataHandler<ArrayBuffer> {

  setOnDataRead(func: (data: ArrayBuffer)=>void ){
    this.onDataPrepared = func
  }

  onDataPrepared: (data: ArrayBuffer)=>void = (data: ArrayBuffer)=>{}
}


export async function fetchMediaData(uri: string, onDataRead: (data: ArrayBuffer)=>void){
  let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
  predicates.equalTo(photoAccessHelper.PhotoKeys.URI, uri.toString());
  let fetchOptions: photoAccessHelper.FetchOptions = {
    fetchColumns: [photoAccessHelper.PhotoKeys.TITLE],
    predicates: predicates,
  }

  try {
    let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> = await phAccessHelper.getAssets(fetchOptions)
    let photoAsset: photoAccessHelper.PhotoAsset = await fetchResult.getFirstObject()

    // 请求图片资源数据
    let requestOptions: photoAccessHelper.RequestOptions = {
      deliveryMode: photoAccessHelper.DeliveryMode.HIGH_QUALITY_MODE,
    }
    let handler: MediaDataHandler = new MediaDataHandler();
    handler.setOnDataRead(onDataRead)
    await photoAccessHelper.MediaAssetManager.requestImageData(context, photoAsset, requestOptions, handler);
    console.info('requestImageData successfully');
    fetchResult.close();
  }catch (err) {
    console.error('getAssets failed with err: ' + err);
  }
}



