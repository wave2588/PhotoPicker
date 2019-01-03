//
//  PhotoPickerAssetListViewController.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/12.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Photos
import SwifterSwift

protocol PhotoPickerAssetListViewControllerInputs {
    func rollToTop()
}

protocol PhotoPickerAssetListViewControllerOutputs {
    
    var clickCellIndexLbl: PublishSubject<Int> { get }
    var clickCell: PublishSubject<Int> { get }
}

class PhotoPickerAssetListViewController: UIViewController {

    deinit {
        debugPrint("deinit \(self)")
    }

    @IBOutlet weak var collectionView: UICollectionView!
    
    var inputs: PhotoPickerAssetListViewControllerInputs { return self }
    
    var outpus: PhotoPickerAssetListViewControllerOutputs { return self}
    let clickCellIndexLbl = PublishSubject<Int>()
    let clickCell = PublishSubject<Int>()

    let albumItem = PublishSubject<AlbumItem>()
    
    private var tempAlbumItem: AlbumItem?
    /// 数据源
    private let assetItems = BehaviorRelay<[AssetItem]>(value: [])
    
    private var itemSize = CGSize(width: 0, height: 0)
    
    private var cache = [String: UIImage]()
    private var progressCache = [String: CGFloat]()
    
    var indexPath = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureAlbumItem()
        configureCollectionView()
    }
}

private extension PhotoPickerAssetListViewController {
    
    /// 点击完 video item, 返回是否需要进行下载的 bool
    func clickVideo(item: AssetItem) -> Bool {
        
        if item.phAsset.duration > 300 {
            PhotoPickerConfigManager.shared.message?(.fail, "暂不支持 5 分钟以上视频")
            return false
        }
        
        if item.phAsset.duration < 3 {
            PhotoPickerConfigManager.shared.message?(.fail, "暂不支持 3 秒以下视频")
            return false
        }
        
        if let _ = item.getVideoPHAsset() {
            clickCell.onNext(indexPath.row)
            return false
        }
        
        return true
    }
    
    /// 点击完 photo item, 返回是否需要进行下载的 bool
    func clickPhoto(item: AssetItem, isClickCell: Bool) -> Bool {
        
        if let _ = item.fullResolutionImage {
            if isClickCell {
                clickCell.onNext(indexPath.row)
            } else {
                clickCellIndexLbl.onNext(indexPath.row)
            }
            return false
        }
        
        return true
    }
    
    func clickDownload(ip: IndexPath, isClickCell: Bool) {
        
        indexPath = ip
        
        let item = assetItems.value[indexPath.row]

        if item.type == .photo {
            if !clickPhoto(item: item, isClickCell: isClickCell) {
                return
            }
        } else {
            if !clickVideo(item: item) {
                return
            }
        }

        if let _ = progressCache[item.id]  {
            
            PhotoPickerConfigManager.shared.message?(.normal, "已经在下载了")

        } else {
            
            if item.type == .photo {
                
                PhotoPickerConfigManager.shared.message?(.normal, "从 iCloud 下载中...")
                
                Downloader.shared.downloadImage(asset: item.phAsset, progressHandler: { [weak self] progress in
                    self?.progressCache[item.id] = progress
                    guard let cell = self?.collectionView.cellForItem(at: ip) as? AssetListCell else { return }
//                    debugPrint(progress, "progress cell ---->: ", cell)
                    cell.animationView.animationProgress = self?.progressCache[item.id] ?? 0
                    }, completeHandler: { [weak self] image in
                        guard let _ = image else { return }
                        self?.progressCache[item.id] = 1
                        guard let cell = self?.collectionView.cellForItem(at: ip) as? AssetListCell else { return }
                        cell.animationView.isHidden = true
                })
            } else {
                
                PhotoPickerConfigManager.shared.message?(.normal, "从 iCloud 下载中...")

                Downloader.shared.downloadVideo(asset: item.phAsset, progressHandler: { [weak self] progress in
//                    debugPrint(progress)
                    self?.progressCache[item.id] = progress
                    guard let cell = self?.collectionView.cellForItem(at: ip) as? AssetListCell else { return }
                    cell.animationView.animationProgress = self?.progressCache[item.id] ?? 0
                    }, completeHandler: { [weak self] path in
                        guard let _ = path else { return }
                        self?.progressCache[item.id] = 1
                        guard let cell = self?.collectionView.cellForItem(at: ip) as? AssetListCell else { return }
                        cell.animationView.isHidden = true
                })
            }
        }
    }
}

private extension PhotoPickerAssetListViewController {
    
    func configureAlbumItem() {
        albumItem
            .subscribe(onNext: { [unowned self] albumItem in
                self.tempAlbumItem = albumItem
                self.assetItems.accept(albumItem.assetItems)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func configureCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        let itemW = (view.width - 3) / 4
        itemSize = CGSize(width: itemW, height: itemW)
        layout.itemSize = CGSize(width: itemW, height: itemW)
        layout.minimumLineSpacing = 1;
        layout.minimumInteritemSpacing = 1;
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.registerCell(nibWithCellClass: AssetListCell.self)
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, AssetItem>>(
            configureCell: { [weak self] ds, cv, ip, item in
                
                let cell = cv.dequeueReusableCell(withClass: AssetListCell.self, for: ip)
                
                guard let `self` = self else { return cell }
                
                cell.videoInfoView.isHidden = item.type == .video ? false : true
                cell.videoDurationLbl.text = item.duration
                cell.indexLbl.isHidden = item.type == .video ? true : false
                cell.indexLblBackView.isHidden = cell.indexLbl.isHidden
                
                cell.animationView.animationProgress = self.progressCache[item.id] ?? 0

                if item.type == .photo {

                    if item.fullResolutionImage != nil {
                        cell.animationView.isHidden = true
                    } else {
                        cell.animationView.isHidden = false
                    }
                    
                    cell.didTapSelectedIndexBtn = { [unowned self] in
                        self.clickDownload(ip: ip, isClickCell: false)
                    }

                    cell.isUserInteractionEnabled = true
                    
                    /// 根据 item.isCurrentSeleted 来判断是否是当前预览选中的
                    cell.selectedView.isHidden = item.isCurrentSeleted ? false : true
                    cell.selectedView.backgroundColor = UIColor.red.withAlphaComponent(0.2)
                    cell.selectedView.borderWidth = 1
                    cell.selectedView.borderColor = .red
                    
                    /// 根据 item.selectedIndex 来判断是否是选中状态
                    cell.indexLbl.borderWidth = 1
                    cell.indexLbl.borderColor = item.selectedIndex == 0 ? .white : .red
                    cell.indexLbl.backgroundColor = item.selectedIndex == 0 ? UIColor.black.withAlphaComponent(0.2) : .red
                    cell.indexLbl.text = item.selectedIndex == 0 ? "" : "\(item.selectedIndex)"
                    
                } else {

                    if item.getVideoPHAsset() != nil {
                        cell.animationView.isHidden = true
                    } else {
                        cell.animationView.isHidden = false
                    }

                    cell.selectedView.borderWidth = 0
                    
                    /// isSelectVideo = true 能选中视频
                    cell.selectedView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
                    cell.selectedView.isHidden = self.tempAlbumItem?.isSelectVideo == true ? true : false
                    cell.isUserInteractionEnabled = self.tempAlbumItem?.isSelectVideo == true ? true : false
                }
                
                let options = PHImageRequestOptions()
                options.deliveryMode = .opportunistic
                options.resizeMode = .exact
                options.isNetworkAccessAllowed = true

                if let image = self.cache[item.id] {
                    cell.coverImageView.image = image
                } else {
                    let _ = PhotoLibrary.imageAsset(asset: item.phAsset, size: self.itemSize, options: options, completionBlock: { image, complete in
                        if complete == true {
                            cell.coverImageView.image = image
                            self.cache[item.id] = image
                        }
                    })
                }
                return cell
            }
        )
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] ip in
                self.clickDownload(ip: ip, isClickCell: true)
            })
            .disposed(by: rx.disposeBag)
        
        assetItems
            .map { [SectionModel(model: "", items: $0)] }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
    }
}

extension PhotoPickerAssetListViewController: PhotoPickerAssetListViewControllerInputs {
    func rollToTop() {
        self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
}

extension PhotoPickerAssetListViewController: PhotoPickerAssetListViewControllerOutputs {}
