//
//  PhotoPickerActionViewController.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/12.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Photos

protocol PhotoPickerActionViewControllerInputs {
    var editedAssetItem: PublishSubject<AssetItem> { get }
}

protocol PhotoPickerActionViewControllerOutputs {
    
    var clickVideo: PublishSubject<AVAssetExportSession> { get }
}

class PhotoPickerActionViewController: UIViewController {

    deinit {
        debugPrint("deinit \(self)")
    }

    var inputs: PhotoPickerActionViewControllerInputs { return self }
    let editedAssetItem = PublishSubject<AssetItem>()
    
    var outputs: PhotoPickerActionViewControllerOutputs { return self }
    var clickVideo = PublishSubject<AVAssetExportSession>()
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var albumTitleLbl: UILabel!
    
    @IBOutlet weak var assetListContainerView: UIView!
    @IBOutlet weak var albumListContainerView: UIView!
    
    private let library = PhotoLibrary()

    /// 整体的数据源
    private let albumItems = BehaviorRelay<[AlbumItem]>(value: [])
    
    /// 当前选择的相册下标
    private var currentSelectedAlbumIndex = 0
    
    private var albumListVC: PhotoPickerAlbumListViewController!
    private var assetListVC: PhotoPickerAssetListViewController!

    /// 这俩是个过渡值, 用来倒传的.
    let selectedAssetItems = BehaviorRelay<[AssetItem]>(value: [])
    let currentSelectedAssetItem = PublishSubject<AssetItem>()

    private var isFirstDisplay = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureContainerView()
        configureAlbumVC()
        configureAssetVC()
        configureLibrary()
        configureAlbumItems()
        configureEditedAssetItem()
        configureLayer()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PhotoPickerAlbumListViewController {
            albumListVC = vc
        }
        if let vc = segue.destination as? PhotoPickerAssetListViewController {
            assetListVC = vc
        }
    }
}

extension PhotoPickerActionViewController: PhotoPickerActionViewControllerInputs {}
extension PhotoPickerActionViewController: PhotoPickerActionViewControllerOutputs {}

private extension PhotoPickerActionViewController {
    
    /// 选中第一个图片, 并且把第一张图片传到最外层控制器展示图片
    func defaultSelectedAssetItem(albumItem: AlbumItem) {
        
        albumTitleLbl.text = albumItem.title
        
        /// 判断是否有预览选中的, 如果有, 则不进行设置, 没有则进行设置
        let previewSelectedAssetItem = albumItem.assetItems.filter { item -> Bool in
            return item.isCurrentSeleted == true
        }
        var tAlbumItem = albumItem
        if previewSelectedAssetItem.count == 0 {
            var assetItems = tAlbumItem.assetItems
            for i in 0 ..< assetItems.count {
                let item = assetItems[i]
                if item.type != .video {
                    assetItems[i].isCurrentSeleted = true
                    currentSelectedAssetItem.onNext(item)
                    break
                }
            }
            tAlbumItem.assetItems = assetItems
        } else {
            let assetItems = tAlbumItem.assetItems
            if let index = assetItems.firstIndex(where: { item -> Bool in
                return item.isCurrentSeleted == true
            }) {
                currentSelectedAssetItem.onNext(assetItems[index])
            }
        }

        var tAlbumItems = albumItems.value
        tAlbumItems[currentSelectedAlbumIndex] = tAlbumItem
        albumItems.accept(tAlbumItems)
    }
    
    func selected(index: Int) {
        
        var albumItems = self.albumItems.value
        var assetItems = albumItems[currentSelectedAlbumIndex].assetItems
        
        /// 先获取到所有 albumItems 选中的总个数
        let sum = albumItems.map { item -> Int in
            return item.selectedAssetItems.count
        }.reduce(0, +)
        
        if sum >= 9 {
            PhotoPickerConfigManager.shared.fail?("最多可选择9张图")
            return
        }
        
        /// 取消所有当前选中状态
        assetItems = assetItems.map({ item -> AssetItem in
            var tItem = item
            tItem.isCurrentSeleted = false
            return tItem
        })

        /// 只要有一张图片选中后, 所有相册视频都不能选中
        albumItems = albumItems.map({ item -> AlbumItem in
            var tItem = item
            tItem.isSelectVideo = false
            return tItem
        })
        
        assetItems[index].selectedIndex = sum + 1
        assetItems[index].isCurrentSeleted = true
        albumItems[self.currentSelectedAlbumIndex].assetItems = assetItems
        self.albumItems.accept(albumItems)
        
        self.currentSelectedAssetItem.onNext(assetItems[index])
    }
    
    func cancelSelected(index: Int) {
        
        var albumItems = self.albumItems.value
        var assetItems = albumItems[self.currentSelectedAlbumIndex].assetItems
        
        let selectedIndex = assetItems[index].selectedIndex
        
        assetItems[index].selectedIndex = 0
        albumItems[self.currentSelectedAlbumIndex].assetItems = assetItems

        albumItems = albumItems.map({ item -> AlbumItem in
            var tItem = item
            tItem.assetItems = tItem.assetItems.map({ aItem -> AssetItem in
                var tempAssetItem = aItem
                if tempAssetItem.selectedIndex > selectedIndex {
                    tempAssetItem.selectedIndex = tempAssetItem.selectedIndex - 1
                }
                
                /// 如果取消的是第一个, 则把除了当前第一个的所有 editInfo 重置为空
                if selectedIndex == 1 && tempAssetItem.selectedIndex != 1 {
                    tempAssetItem.editInfo = nil
                }
                
                return tempAssetItem
            })
            return tItem
        })

        let sum = albumItems.map { item -> Int in
            return item.selectedAssetItems.count
        }.reduce(0, +)
        if sum == 0 {
            albumItems = albumItems.map({ item -> AlbumItem in
                var tItem = item
                tItem.isSelectVideo = true
                return tItem
            })
        }

        self.albumItems.accept(albumItems)
        
        if selectedIndex == 1 {
            /// 刷新当前选中的 assetItem
            albumItems.forEach { albumItem in
                albumItem.assetItems.forEach({ assetItem in
                    if assetItem.isCurrentSeleted {
                        currentSelectedAssetItem.onNext(assetItem)
                    }
                })
            }
        }
    }
}

private extension PhotoPickerActionViewController {
    
    func configureContainerView() {
        albumListContainerView.alpha = 0
    }

    func configureAlbumItems() {
        albumItems
            .subscribe(onNext: { [unowned self] items in
                if items.count == 0 {
                    return
                }
                self.albumListVC.albumItems.accept(items)
                self.assetListVC.albumItem.onNext(items[self.currentSelectedAlbumIndex])
                
                var selItems = items.flatMap({ item -> [AssetItem] in
                    return item.selectedAssetItems
                })
                selItems.sort{ $0.selectedIndex < $1.selectedIndex }
                self.selectedAssetItems.accept(selItems)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func configureAlbumVC() {
        
        albumListVC.outputs.selectedAlbumIndex
            .subscribe(onNext: { [unowned self] index in
                
                self.currentSelectedAlbumIndex = index
                let selectedAlbumItem = self.albumItems.value[index]
                self.defaultSelectedAssetItem(albumItem: selectedAlbumItem)
                UIView.animate(withDuration: 0.25, animations: {
                    self.albumListContainerView.alpha = 0
                })
            })
            .disposed(by: rx.disposeBag)
    }
    
    func configureAssetVC() {
        
        assetListVC.outpus.clickCell
            .subscribe(onNext: { [unowned self] index in
                /// 先获取到点击当前相册
                var albumItems = self.albumItems.value
                var albumItem = albumItems[self.currentSelectedAlbumIndex]
                var assetItems = albumItem.assetItems
                let assetItem = assetItems[index]
                
                if assetItem.fullResolutionImage == nil {
                    PhotoPickerConfigManager.shared.fail?("iCloud未同步")
                    return
                }
                
                if assetItem.type == .video {
                    assetItem.getVideoFileUrl(completionHandler: { [unowned self] session in
                        if let ses = session {
                            self.clickVideo.onNext(ses)
                        } else {
                            PhotoPickerConfigManager.shared.fail?("iCloud未同步")
                        }
                    })
                    return
                }
                
                assetItems = assetItems.map({ item -> AssetItem in
                    var tItem = item
                    tItem.isCurrentSeleted = false
                    return tItem
                })
                assetItems[index].isCurrentSeleted = true
                albumItem.assetItems = assetItems
                albumItems[self.currentSelectedAlbumIndex] = albumItem
                self.albumItems.accept(albumItems)
                self.currentSelectedAssetItem.onNext(assetItem)
            })
            .disposed(by: rx.disposeBag)
        
        assetListVC.outpus.clickCellIndexLbl
            .subscribe(onNext: { [unowned self] index in
                var albumItems = self.albumItems.value
                let albumItem = albumItems[self.currentSelectedAlbumIndex]
                var assetItems = albumItem.assetItems
                let assetItem = assetItems[index]
                if assetItem.fullResolutionImage == nil {
                    PhotoPickerConfigManager.shared.fail?("iCloud未同步")
                    return
                }
                if assetItem.selectedIndex == 0 {
                    self.selected(index: index)
                } else {
                    self.cancelSelected(index: index)
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    func configureEditedAssetItem() {
        editedAssetItem
            .subscribe(onNext: { [unowned self] item in
                var albumItems = self.albumItems.value
                var assetItems = albumItems[self.currentSelectedAlbumIndex].assetItems
                guard let index = assetItems.firstIndex(where: { tItem -> Bool in
                    return tItem.id == item.id
                }) else {
                        return
                }
                
                assetItems[index].editInfo = item.editInfo
                albumItems[self.currentSelectedAlbumIndex].assetItems = assetItems
                
                if item.selectedIndex == 1 && self.selectedAssetItems.value.first?.editInfo?.scale != item.editInfo?.scale {
                    /// 修改了第一张图的比例, 把所有 selectedIndex != 1 的 editInfo 都给重置
                    albumItems = albumItems.map({ albumItem -> AlbumItem in
                        var tAlbumItem = albumItem
                        tAlbumItem.assetItems = tAlbumItem.assetItems.map({ assetItem -> AssetItem in
                            var tAssetItem = assetItem
                            if tAssetItem.selectedIndex != 1 {
                                tAssetItem.editInfo = nil
                            }
                            return tAssetItem
                        })
                        return tAlbumItem
                    })
                }
                
                self.albumItems.accept(albumItems)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func configureLibrary() {
        
        library.outputs.albumList
            .subscribe(onNext: { [unowned self] albumItems in
                self.albumItems.accept(albumItems)
                if self.isFirstDisplay {
                    self.isFirstDisplay = false
                    guard let allPhotoAlbumItem = albumItems.first else { return }
                    self.defaultSelectedAssetItem(albumItem: allPhotoAlbumItem)
                }
            })
            .disposed(by: rx.disposeBag)
        
        library.checkAuthorization()
    }
    
    func configureLayer() {
        let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topRight, .topLeft], cornerRadii: CGSize(width: 8, height: 8))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.path = maskPath.cgPath
        view.layer.mask = maskLayer
    }
}
