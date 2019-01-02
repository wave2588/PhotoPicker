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
import Lottie

class AssetListCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var videoInfoView: UIView!
    @IBOutlet weak var videoDurationLbl: UILabel!
    
    @IBOutlet weak var selectedView: UIView!
    
    @IBOutlet weak var indexLbl: UILabel!
    @IBOutlet weak var indexLblBackView: UIView!
    
    var animationView: LOTAnimationView!
    
    var didTapSelectedIndexBtn: (()->())?
    
    let tapGesture = UITapGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        if let path = Bundle.resourcePath("cloud.json") {
            animationView = LOTAnimationView(filePath: path)
            addSubview(animationView)
        }

        tapGesture.rx.event
            .bind { [unowned self] _ in
                self.didTapSelectedIndexBtn?()
            }
            .disposed(by: rx.disposeBag)
        
        indexLblBackView.addGestureRecognizer(tapGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        animationView.frame = CGRect(x: 5, y: 5, width: 20, height: 20)
    }
    
}
