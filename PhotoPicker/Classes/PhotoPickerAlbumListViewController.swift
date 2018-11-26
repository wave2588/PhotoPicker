//
//  PhotoPickerAlbumListViewController.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/12.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

protocol PhotoPickerAlbumListViewControllerOutputs {

    /// 选中的相簿下标
    var selectedAlbumIndex: PublishSubject<Int> { get }
}

class PhotoPickerAlbumListViewController: UIViewController {

    deinit {
        debugPrint("deinit \(self)")
    }

    @IBOutlet weak var tableView: UITableView!
    
    var outputs: PhotoPickerAlbumListViewControllerOutputs { return self }
    
    /// 选中的下标
    let selectedAlbumIndex = PublishSubject<Int>()
    
    /// 数据源
    let albumItems = BehaviorRelay<[AlbumItem]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
    }
}

extension PhotoPickerAlbumListViewController: PhotoPickerAlbumListViewControllerOutputs { }

private extension PhotoPickerAlbumListViewController {
    
    func configureTableView() {
        
        tableView.separatorStyle = .none
        tableView.rowHeight = 120

        /// **
//        tableView.registerCell(nibWithCellClass: AlbumListCell.self)
        tableView.register(nibWithCellClass: AlbumListCell.self)
        
        albumItems
            .bind(to: tableView.rx.items(cellType: AlbumListCell.self)) { _, item, cell in
                cell.titleLbl.text = "\(item.title) \(item.assetItems.count)"
                cell.selectedCountLbl.isHidden = item.selectedAssetItems.count == 0 ? true : false
                cell.selectedCountLbl.text = "\(item.selectedAssetItems.count)"
                if let firstAssetItem = item.assetItems.first {
                    let scale = UIScreen.main.scale
                    let size = CGSize(width: cell.coverView.width*scale, height: cell.coverView.height*scale)
                    let _ = PhotoLibrary.imageAsset(asset: firstAssetItem.phAsset, size: size, options: nil, completionBlock: { image, _ in
                        cell.coverView.image = image
                    })
                }
            }
            .disposed(by: rx.disposeBag)

        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                self.selectedAlbumIndex.onNext(indexPath.row)
            })
            .disposed(by: rx.disposeBag)
    }
}
