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
    
    /// 配置信息
    var config: BehaviorRelay<PhotoPickerConfig?> { get }
}

protocol PhotoPickerActionViewControllerOutputs {
    
    var clickVideo: PublishSubject<PHAsset> { get }
    
    /// 这个方法就是为了实现点击图片后, actionVC 要回到原始位置
    var selectedImage: PublishSubject<Any?> { get }
}

class PhotoPickerActionViewController: UIViewController {

    deinit {
        debugPrint("deinit \(self)")
    }

    var inputs: PhotoPickerActionViewControllerInputs { return self }
    let editedAssetItem = PublishSubject<AssetItem>()
    let config = BehaviorRelay<PhotoPickerConfig?>(value: nil)

    var outputs: PhotoPickerActionViewControllerOutputs { return self }
    let clickVideo = PublishSubject<PHAsset>()
    let selectedImage = PublishSubject<Any?>()

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewHeightCos: NSLayoutConstraint!
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var albumTitleView: AlbumTitleView!
    
    @IBOutlet weak var assetListContainerView: UIView!
    @IBOutlet weak var albumListContainerView: UIView!
    
    private let library = PhotoLibrary()

    /// 整体的数据源
    let albumItems = BehaviorRelay<[AlbumItem]>(value: [])
    
    /// 当前选择的相册下标
    private var currentSelectedAlbumIndex = 0
    
    var albumListVC: PhotoPickerAlbumListViewController!
    var assetListVC: PhotoPickerAssetListViewController!

    /// 这俩是个过渡值, 用来倒传的.
    let selectedAssetItems = BehaviorRelay<[AssetItem]>(value: [])
    let currentSelectedAssetItem = PublishSubject<AssetItem>()

    private var isFirstDisplay = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTopView()
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
        
        albumTitleView.inputs.text.onNext(albumItem.title)
        
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
        
        let maxSlt = config.value?.maxSelectCount ?? 9
        if sum >= maxSlt {
            PhotoPickerConfigManager.shared.message?(.fail, "最多可选择 \(maxSlt) 张图")
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
                
                /// 如果取消的是第一个, 则重置所有 editInfo
                if selectedIndex == 1 {
                    if tempAssetItem.selectedIndex == 1 {
                        tempAssetItem.editInfo = EditInfo(zoomScale: 1, contentOffset: CGPoint(x: 0, y: 0), scale: .oneToOne, mode: .fill)
                    } else {
                        tempAssetItem.editInfo = nil
                    }
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
                self.assetListVC.indexPath = IndexPath(row: 0, section: 0)
                self.currentSelectedAlbumIndex = index
                let selectedAlbumItem = self.albumItems.value[index]
                self.defaultSelectedAssetItem(albumItem: selectedAlbumItem)
                UIView.animate(withDuration: 0.25, animations: {
                    self.albumListContainerView.alpha = 0
                    self.albumTitleView.imgView.image = UIImage.loadLocalImagePDF(name: "ic_arrow_up.pdf")
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
                
                if assetItem.type == .video {
                    
                    if assetItem.phAsset.duration > 300 {
                        PhotoPickerConfigManager.shared.message?(.fail, "暂不支持 5 分钟以上视频")
                        return
                    }
                    
                    if assetItem.phAsset.duration < 3 {
                        PhotoPickerConfigManager.shared.message?(.fail, "暂不支持 3 秒以下视频")
                        return
                    }
                    
                    if let asset = assetItem.getVideoPHAsset() {
                        self.clickVideo.onNext(asset)
                    } else {
                    }
                    return
                }

                if assetItem.fullResolutionImage == nil {
                    return
                }
                
                self.selectedImage.onNext(nil)
                
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
                    return
                }
                
                self.selectedImage.onNext(nil)

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
        
        library.outputs.albumPermissions
            .subscribe(onNext: { isok in
                if !isok {
                    PhotoPickerConfigManager.shared.message?(.fail, "请打开相册权限")
                }
            })
            .disposed(by: rx.disposeBag)
        
        library.outputs.albumList
            .subscribe(onNext: { [unowned self] albumItems in
                self.albumItems.accept(self.albumItems.value + albumItems)
            })
            .disposed(by: rx.disposeBag)
        
        library.outputs.preloadAlbumList
            .subscribe(onNext: { [unowned self] albumItems in
                self.albumItems.accept(albumItems)
//                if self.isFirstDisplay {
                    self.isFirstDisplay = false
                    guard let allPhotoAlbumItem = albumItems.first else { return }
                    self.defaultSelectedAssetItem(albumItem: allPhotoAlbumItem)
//                }
            })
            .disposed(by: rx.disposeBag)
        
        library.outputs.insertedAssetItems
            .subscribe(onNext: { [weak self] assetItems in
                guard let `self` = self else { return }
                self.insertAssetItems(items: assetItems)
            })
            .disposed(by: rx.disposeBag)
        
        library.outputs.removedAssetItems
            .subscribe(onNext: { [weak self] assetItems in
                guard let `self` = self else { return }
                self.removeAssetItems(items: assetItems)
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
    
    func configureTopView() {
        albumTitleView.inputs.text.onNext("所有照片")
        if !Runtime.isiPhoneX {
            topViewHeightCos.constant = 25
            view.layoutIfNeeded()
        }
    }
}
