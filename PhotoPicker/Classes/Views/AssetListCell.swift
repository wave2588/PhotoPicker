//
//  AssetListCell.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/13.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Photos

class AssetListCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var videoInfoView: UIView!
    @IBOutlet weak var videoDurationLbl: UILabel!
    
    @IBOutlet weak var selectedView: UIView!
    
    @IBOutlet weak var indexLbl: UILabel!
    
    var didTapSelectedIndexBtn: (()->())?

    let tapGesture = UITapGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        indexLbl.isUserInteractionEnabled = true
        tapGesture.rx.event
            .bind { [unowned self] _ in
                self.didTapSelectedIndexBtn?()
            }
            .disposed(by: rx.disposeBag)
        
        indexLbl.addGestureRecognizer(tapGesture)
    }
}
