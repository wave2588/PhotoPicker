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

extension PhotoLibrary: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        debugPrint("photo change...")
    }
}

private extension PhotoLibrary {
    
    func getAllAlbumItems() {

        PHPhotoLibrary.shared().register(self)
        
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
        
        /// 所有照片 相机胶卷 视频Videos  最近添加Recently Added 个人收藏Favorites 自拍Selfies 人像Portrait
        var titles = [
            "All Photos",
            "Camera Roll",
            "Videos",
            "Recently Added",
            "Favorites",
            "Selfies",
            "Portrait",
        ]
        
        DispatchQueue.global().async {
            
            var items = [String: [AssetItem]]()
            for i in 0..<smartAlbums.count {
                let collection = smartAlbums[i]
                if let title = collection.localizedTitle {
                    let fetchResult = PHAsset.fetchAssets(in: collection, options: resultsOptions)
                    if fetchResult.count == 0 {
                        continue
                    }
                    if !titles.contains(title) {
                        titles.append(title)
                    }
                    let assetItems = self.getAllAssetItems(fetchResult)
                    items[title] = assetItems
                }
            }
            
            var albumItems = [AlbumItem]()
            for index in 0..<titles.count {
                let title = titles[index]
                if let assetItems = items[title] {
                    let item = AlbumItem(id: NSUUID().uuidString, title: self.titleOfAlbumForChinse(title: title), assetItems: assetItems)
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
                    let assetItems = self.getAllAssetItems(fetchResult)
                    let item = AlbumItem(id: NSUUID().uuidString, title: self.titleOfAlbumForChinse(title: title), assetItems: assetItems)
                    albumItems.append(item)
                }
            }

            DispatchQueue.main.async {
                self.albumList.onNext(albumItems)
            }
        }
    }
    
    func getAllAssetItems(_ fetchResult: PHFetchResult<PHAsset>) -> [AssetItem] {
        let count = fetchResult.count
        var assetItems = [AssetItem]()
        for i in 0 ..< count {
            let phAsset = fetchResult[i]
            assetItems.append(AssetItem(id: phAsset.localIdentifier, phAsset: phAsset))
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
