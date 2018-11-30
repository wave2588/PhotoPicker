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
import BonMot

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
        tableView.rowHeight = 102

        /// **
//        tableView.registerCell(nibWithCellClass: AlbumListCell.self)
        tableView.register(nibWithCellClass: AlbumListCell.self)
        
        albumItems
            .bind(to: tableView.rx.items(cellType: AlbumListCell.self)) { [unowned self] _, item, cell in
                let str = "\(item.title) \(item.assetItems.count)"
                let highlightStr = "\(item.title) <em>\(item.assetItems.count)</em>"
                cell.titleLbl.text = str
                cell.titleLbl.attributedText = self.getHighlightAttributedStr(highlightName: highlightStr)
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

private extension PhotoPickerAlbumListViewController {
    
    func getHighlightAttributedStr(highlightName: String?) -> NSAttributedString {
        
        var body = NSAttributedString()
        
        guard let highlightName = highlightName else { return body }
        
        let style = StringStyle(.color(.black),
                                .font(UIFont(name: "PingFangSC-Medium", size: 14) ?? .systemFont(ofSize: 14)),
                                .xmlStyler(BodyStyler()))
        body = highlightName.styled(with: style)
        
        return body
    }
}

extension PhotoPickerAlbumListViewController {
    
    struct BodyStyler: XMLStyler {
        
        func prefix(forElement name: String, attributes: [String : String]) -> Composable? { return nil }
        
        func suffix(forElement name: String) -> Composable? { return nil }
        
        func style(forElement name: String, attributes: [String: String], currentStyle: StringStyle) -> StringStyle? {

            let style = StringStyle(
                .color(UIColor(red: 0, green: 0, blue: 0)?.withAlphaComponent(0.4) ?? .white),
                .font(UIFont(name: "PingFangSC-Medium", size: 13) ?? .systemFont(ofSize: 13))
            )
            let styleMap: [String: StringStyle] = [
                "em": style
            ]
            
            let highlightedStyle = styleMap[name] ?? StringStyle()
            
            return highlightedStyle
        }
    }
}
