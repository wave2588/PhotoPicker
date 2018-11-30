//
//  PhotoLibrary.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/12.
//  Copyright © 2018 wave. All rights reserved.
//

import Foundation
import Photos
import RxSwift
import RxCocoa
import NSObject_Rx
import SwifterSwift

protocol PhotoLibraryInputs {

}

protocol PhotoLibraryOutputs {
    /// 是否有权限
    var albumPermissions: PublishSubject<Bool> { get }
    /// 传出相簿列表
    var albumList: PublishSubject<[AlbumItem]> { get }
}

class PhotoLibrary: NSObject {
    
    var inputs: PhotoLibraryInputs { return self }
    let seletedAlbum = PublishSubject<AlbumItem>()
    
    var outputs: PhotoLibraryOutputs { return self }
    let albumPermissions = PublishSubject<Bool>()
    let albumList = PublishSubject<[AlbumItem]>()
}

extension PhotoLibrary: PhotoLibraryInputs { }
extension PhotoLibrary: PhotoLibraryOutputs { }

private extension PhotoLibrary {
    
    func getAllAlbumItems() {
        
        // 列出所有系统的智能相册
        let smartOptions = PHFetchOptions()
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                  subtype: .albumRegular,
                                                                  options: smartOptions)
        let resultsOptions = PHFetchOptions()
        resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                           ascending: false)]
//        resultsOptions.predicate = NSPredicate(format: "mediaType = %d",
//                                               PHAssetMediaType.image.rawValue)

//        var totalPhoto = AlbumItem(id: NSUUID().uuidString, title: "全部相册", fetchResult: PHFetchResult(), assetItems: [])
        
        /// 系统相册需要取出来的部分
        /// 所有照片 视频Videos  最近添加Recently Added 个人收藏Favorites 自拍Selfies 人像Portrait
//        let titles = ["Videos", "Recently Added", "Favorites", "Portrait"]
        var albumItems = [AlbumItem]()
        for i in 0 ..< smartAlbums.count {
            let collection = smartAlbums[i]
            if let title = collection.localizedTitle {
                let fetchResult = PHAsset.fetchAssets(in: collection, options: resultsOptions)
                if fetchResult.count == 0 {
                    continue
                }
                let assetItems = getAllAssetItems(fetchResult)
                let item = AlbumItem(id: NSUUID().uuidString, title: titleOfAlbumForChinse(title: title), fetchResult: fetchResult, assetItems: assetItems)
                albumItems.append(item)
            }
        }
        
        /// 用户自己创建的相册
        let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        for i in 0 ..< userCollections.count {
            if let collection = userCollections[i] as? PHAssetCollection,
                let title = collection.localizedTitle {
                let fetchResult = PHAsset.fetchAssets(in: collection, options: resultsOptions)
                if fetchResult.count == 0 {
                    continue
                }
                let assetItems = getAllAssetItems(fetchResult)
                let item = AlbumItem(id: NSUUID().uuidString, title: titleOfAlbumForChinse(title: title), fetchResult: fetchResult, assetItems: assetItems)
                albumItems.append(item)
            }
        }
        
        /// 把所有照片替换到第一个
        if let index = albumItems.firstIndex(where: { item -> Bool in
            return item.title == "所有照片"
        }) {
            albumItems.swapAt(0, index)
        }
        
        albumList.onNext(albumItems)
    }
    
    func getAllAssetItems(_ fetchResult: PHFetchResult<PHAsset>) -> [AssetItem] {
        let count = fetchResult.count
        var assetItems = [AssetItem]()
        for i in 0 ..< count {
            let phAsset = fetchResult[i]
            assetItems.append(AssetItem(id: NSUUID().uuidString, phAsset: phAsset))
        }
        return assetItems
    }
}

extension PhotoLibrary {
    
    func checkAuthorization() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:         // 用户暂未权限认证
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                switch status {
                case .authorized:
                    self?.outputs.albumPermissions.onNext(true)
                    self?.getAllAlbumItems()
                    break
                default:
                    self?.outputs.albumPermissions.onNext(false)
                    break
                }
            }
        case .authorized:              // 用户允许使用相册
            outputs.albumPermissions.onNext(true)
            getAllAlbumItems()
            break
        case .restricted:              // APP禁止使用相册权限认证
            outputs.albumPermissions.onNext(false)
            break
        case .denied:                   // 用户拒绝使用相册
            outputs.albumPermissions.onNext(false)
            break
        }
    }
}

/// 以下是类方法, 直接调用
extension PhotoLibrary {
    
    static func fullResolutionImageData(asset: PHAsset) -> UIImage? {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.resizeMode = .none
        options.isNetworkAccessAllowed = false
        options.version = .current
        var image: UIImage? = nil
//        let manager = PHImageManager.default()
        PHCachingImageManager().requestImageData(for: asset, options: options) { (imageData, dataUIT, orientation, info) in
            if let data = imageData {
                image = UIImage(data: data)
            }
        }
        return image
    }
    
    static func imageAsset(asset: PHAsset, size: CGSize, options: PHImageRequestOptions?, completionBlock:@escaping (UIImage,Bool)-> Void) -> PHImageRequestID {
        var options = options
        if options == nil {
            options = PHImageRequestOptions()
            options?.isSynchronous = false
            options?.resizeMode = .exact
            options?.deliveryMode = .opportunistic
            options?.isNetworkAccessAllowed = true
        }
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: size.width*scale, height: size.height*scale)

        let requestId = PHCachingImageManager().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, info in
            let complete = (info?["PHImageResultIsDegradedKey"] as? Bool) == false
            if let image = image {
                completionBlock(image,complete)
            }
        }
        return requestId
    }
    
    static func video(asset: PHAsset, completionHandler:@escaping (_ session: AVAssetExportSession?) -> ()) {
        let options = PHVideoRequestOptions()
        options.version = .current
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true

        let manager = PHImageManager()
        manager.requestExportSession(forVideo: asset, options: options, exportPreset: AVAssetExportPresetHighestQuality) { session, info in
            completionHandler(session)
        }
    }
}
