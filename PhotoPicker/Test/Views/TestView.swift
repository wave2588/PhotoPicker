//
//  TestView.swift
//  TEST
//
//  Created by wave on 2018/11/23.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class TestView: UIView {

    private var collectionView: UICollectionView?
    
    let assetItems = BehaviorRelay<[UIImage]>(value: [])
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let layout = UICollectionViewFlowLayout()
        let itemW = width
        layout.itemSize = CGSize(width: itemW, height: itemW)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: width, height: width), collectionViewLayout: layout)
        collectionView!.register(nibWithCellClass: CollectionViewCell.self)
        collectionView?.isPagingEnabled = true
        addSubview(collectionView!)
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, UIImage>>(
            configureCell: { ds, cv, ip, item in
                let cell = cv.dequeueReusableCell(withClass: CollectionViewCell.self, for: ip)
                cell.imageView.image = item
                return cell
            }
        )
        
        assetItems
            .map { [SectionModel(model: "", items: $0)] }
            .bind(to: collectionView!.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        
//        let btn = UIButton(frame: CGRect(x: 0, y: height - 150, width: 100, height: 100))
//        btn.backgroundColor = .red
//        addSubview(btn)
//        btn.rx.tap.subscribe { [weak self] _ in
//            }.disposed(by: rx.disposeBag)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
