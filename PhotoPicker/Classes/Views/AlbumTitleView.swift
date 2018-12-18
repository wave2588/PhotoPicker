//
//  AlbumTitleView.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/27.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol AlbumTitleViewInputs {
    var text: PublishSubject<String> { get }
}

class AlbumTitleView: UIView {
    
    var inputs: AlbumTitleViewInputs { return self }
    let text = PublishSubject<String>()
    
    let lbl = UILabel()
    let imgView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isUserInteractionEnabled = true
        
        lbl.font = UIFont(name: "PingFangSC-Medium", size: 16)
        lbl.textColor = UIColor(red: 74, green: 74, blue: 74)
        lbl.isUserInteractionEnabled = true
        addSubview(lbl)

        imgView.size = CGSize(width: 18, height: 17)
        imgView.image = UIImage.loadLocalImagePDF(name: "ic_arrow_up.pdf")
        imgView.isUserInteractionEnabled = true
        addSubview(imgView)

        configureText()
    }
}

extension AlbumTitleView: AlbumTitleViewInputs {}

private extension AlbumTitleView {
    
    func configureText() {
        text
            .subscribe(onNext: { [unowned self] text in
                self.lbl.text = text
                self.lbl.sizeToFit()
                let kWidth = UIScreen.main.bounds.width
                self.lbl.x = (kWidth - self.lbl.width) * 0.5 - 10
                self.lbl.y = 0
                self.imgView.x = self.lbl.right + 4
                self.imgView.centerY = self.lbl.centerY
            })
            .disposed(by: rx.disposeBag)
    }
}
