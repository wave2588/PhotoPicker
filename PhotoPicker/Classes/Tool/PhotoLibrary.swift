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
    /// 加载完一个相册后, 先传出去一个渲染出来
    var preloadAlbumList: PublishSubject<[AlbumItem]> { get }

    /// 添加的
    var insertedAssetItems: PublishSubject<[AssetItem]> { get }
    /// 删除的
    var removedAssetItems: PublishSubject<[AssetItem]> { get }

}

class PhotoLibrary: NSObject {
    
    var inputs: PhotoLibraryInputs { return self }
    let seletedAlbum = PublishSubject<AlbumItem>()
    
    var outputs: PhotoLibraryOutputs { return self }
    let albumPermissions = PublishSubject<Bool>()
    let albumList = PublishSubject<[AlbumItem]>()
    let preloadAlbumList = PublishSubject<[AlbumItem]>()
    let insertedAssetItems = PublishSubject<[AssetItem]>()
    let removedAssetItems = PublishSubject<[AssetItem]>()
    
    // 列出所有系统的智能相册
    var smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                              subtype: .any,
                                                              options: PHFetchOptions())
    /// 用户自己创建的
    var userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
    
    /// 排序规则
    let fetchOptions = PHFetchOptions()

    /// 最终结果
    var resultAlbumItems = [AlbumItem]()
    
//    var allPhotosFetchResult: PHFetchResult<PHAsset>!
}

extension PhotoLibrary: PhotoLibraryInputs { }
extension PhotoLibrary: PhotoLibraryOutputs { }

extension PhotoLibrary: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
//        guard let changes = changeInstance.changeDetails(for: allPhotosFetchResult) else { return }
//
//        removedAssetItems.onNext(changes.removedObjects.map { phAsset -> AssetItem in
//                return AssetItem(id: phAsset.localIdentifier, phAsset: phAsset)
//            })
//        
//        insertedAssetItems.onNext(changes.insertedObjects.map { phAsset -> AssetItem in
//                return AssetItem(id: phAsset.localIdentifier, phAsset: phAsset)
//            })
//        
//        let allPhotosOptions = PHFetchOptions()
//        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//        allPhotosFetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
    }
}

private extension PhotoLibrary {
    
    func getAllAlbumItems() {
        
//        let allPhotosOptions = PHFetchOptions()
//        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//        allPhotosFetchResult = PHAsset.fetchAssets(with: allPhotosOptions)

        PHPhotoLibrary.shared().register(self)
        
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        /// 所有照片 相机胶卷 视频Videos 最近添加Recently Added 个人收藏Favorites 自拍Selfies 人像Portrait
        var titles = [
            "All Photos",
            "Camera Roll",
            "Videos",
            "Recently Added",
            "Favorites",
            "Selfies",
            "Portrait",
        ]

        smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                  subtype: .any,
                                                                  options: PHFetchOptions())
        userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)

        DispatchQueue.global().async {
            
            /// 获取所有文件夹下的相簿
            func getFolderAssets(collectionList: PHCollectionList) {
                let folders = PHCollection.fetchCollections(in: collectionList, options: nil)
                for i in 0..<folders.count {
                    if let collection = folders[i] as? PHAssetCollection,
                        let title = collection.localizedTitle {
                        let fetchResult = PHAsset.fetchAssets(in: collection, options: self.fetchOptions)
                        if fetchResult.count == 0 {
                            continue
                        }
                        let assetItems = getAllAssetItems(fetchResult)
                        let item = AlbumItem(id: collection.localIdentifier, title: self.titleOfAlbumForChinse(title: title), assetItems: assetItems)
                        self.resultAlbumItems.append(item)
                    } else {
                        if let collection = folders[i] as? PHCollectionList {
                            getFolderAssets(collectionList: collection)
                        }
                    }
                }
            }
            
            /// 获取相簿下所有图片
            func getAllAssetItems(_ fetchResult: PHFetchResult<PHAsset>) -> [AssetItem] {
                let count = fetchResult.count
                var assetItems = [AssetItem]()
                for i in 0 ..< count {
                    let phAsset = fetchResult[i]
                    assetItems.append(AssetItem(id: phAsset.localIdentifier, phAsset: phAsset))
                }
                return assetItems
            }

            var items = [String: (String, [AssetItem])]()
            var albumItems = [AlbumItem]()

            for i in 0..<self.smartAlbums.count {
                let collection = self.smartAlbums[i]
                if let title = collection.localizedTitle {
                    let fetchResult = PHAsset.fetchAssets(in: collection, options: self.fetchOptions)
                    if fetchResult.count == 0 {
                        continue
                    }
                    if !titles.contains(title) {
                        titles.append(title)
                    }
                    let assetItems = getAllAssetItems(fetchResult)
                    items[title] = (collection.localIdentifier, assetItems)
                }
            }
            
            for index in 0..<titles.count {
                let title = titles[index]
                if let item = items[title] {
                    let item = AlbumItem(id: item.0, title: self.titleOfAlbumForChinse(title: title), assetItems: item.1)
                    if title == titles[0] || title == titles[1] {
                        DispatchQueue.main.async {
                            self.preloadAlbumList.onNext([item])
                        }
                        self.resultAlbumItems.append(item)
                    } else {
                        albumItems.append(item)
                    }
                }
            }
            
            /// 用户自己创建的相册
            for i in 0 ..< self.userCollections.count {
                if let collection = self.userCollections[i] as? PHAssetCollection,
                   let title = collection.localizedTitle {
                    let fetchResult = PHAsset.fetchAssets(in: collection, options: self.fetchOptions)
                    if fetchResult.count == 0 {
                        continue
                    }
                    let assetItems = getAllAssetItems(fetchResult)
                    let item = AlbumItem(id: collection.localIdentifier, title: self.titleOfAlbumForChinse(title: title), assetItems: assetItems)
                    albumItems.append(item)
                } else {
                    if let collection = self.userCollections[i] as? PHCollectionList {
                        getFolderAssets(collectionList: collection)
                    }
                }
            }

            DispatchQueue.main.async {
                self.resultAlbumItems = self.resultAlbumItems + albumItems
                self.albumList.onNext(albumItems)
            }
        }
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
