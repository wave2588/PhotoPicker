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

protocol PhotoPickerAssetListViewControllerOutputs {
    
    var clickCellIndexLbl: PublishSubject<Int> { get }
    var clickCell: PublishSubject<Int> { get }
}

class PhotoPickerAssetListViewController: UIViewController {

    deinit {
        debugPrint("deinit \(self)")
    }

    @IBOutlet weak var collectionView: UICollectionView!
    
    var outpus: PhotoPickerAssetListViewControllerOutputs { return self}
    let clickCellIndexLbl = PublishSubject<Int>()
    let clickCell = PublishSubject<Int>()

    let albumItem = PublishSubject<AlbumItem>()
    
    private var tempAlbumItem: AlbumItem?
    /// 数据源
    private let assetItems = BehaviorRelay<[AssetItem]>(value: [])
    
    private var itemSize = CGSize(width: 0, height: 0)
    
    private var cache = [String: UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureAlbumItem()
        configureCollectionView()
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
        /// **
//        collectionView.registerCell(nibWithCellClass: AssetListCell.self)
        collectionView.register(nibWithCellClass: AssetListCell.self)
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, AssetItem>>(
            configureCell: { [unowned self] ds, cv, ip, item in
                let cell = cv.dequeueReusableCell(withClass: AssetListCell.self, for: ip)
                
                cell.videoInfoView.isHidden = item.type == .video ? false : true
                cell.videoDurationLbl.text = item.duration
                cell.indexLbl.isHidden = item.type == .video ? true : false

                if item.type == .photo {
                    
                    cell.didTapSelectedIndexBtn = { [unowned self] in
                        self.clickCellIndexLbl.onNext(ip.row)
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
                    cell.indexLbl.isHidden = true
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
            .subscribe(onNext: { [unowned self] indexPath in
                self.clickCell.onNext(indexPath.row)
            })
            .disposed(by: rx.disposeBag)
        
        assetItems
            .map { [SectionModel(model: "", items: $0)] }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
    }
}

extension PhotoPickerAssetListViewController: PhotoPickerAssetListViewControllerOutputs {}
