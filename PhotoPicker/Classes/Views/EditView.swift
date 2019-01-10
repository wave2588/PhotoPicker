//
//  EditView.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/15.
//  Copyright © 2018 wave. All rights reserved.
//


import UIKit
import RxSwift
import RxCocoa
import SwifterSwift

protocol EditViewInputs {
    
    /// 第一个是当前选中的 assetItem,  第二个是 已经选中的第一个, 可能为空, 就是没有...
    var data: PublishSubject<(AssetItem, AssetItem?, PhotoPickerConfig?)> { get }
}

protocol EditViewOutputs {
    
    var editedAssetItem: PublishSubject<AssetItem> { get }
}

class EditView: UIView {

    var inputs: EditViewInputs { return self }
    let data = PublishSubject<(AssetItem, AssetItem?, PhotoPickerConfig?)>()
    
    var outputs: EditViewOutputs { return self }
    var editedAssetItem = PublishSubject<AssetItem>()
    
    var assetItem: AssetItem?
    var firstItem: AssetItem?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    let imageView = UIImageView()
    
    /// 分割线 view
    var dividerView: DividerView!

    /// 切换比例
    @IBOutlet weak var switchScaleBtn: UIButton!
    /// 留白
    @IBOutlet weak var switchRemainWhiteBtn: UIButton!
    /// 充满
    @IBOutlet weak var switchFillBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureImageView()
        configureScrollView()
        configureDividerView()
        configureImage()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    @IBAction func clickSwitchScaleAction(_ sender: UIButton) {
        
        impactFeedback(style: .light)
        PhotoPickerConfigManager.shared.statistics?("PO-ACTION-03")
        
        guard let _ = imageView.image else { return }
        
        if scrollView.height == scrollView.width {
            self.switchScaleBtn.setImage(UIImage.loadLocalImagePDF(name: "ic_proportion_post.pdf"), for: .normal)
            let scale:Scale = imageView.width > imageView.height ? .fourToThreeHorizontal : .fourToThreeVertical
            scrollView.frame = getScrollViewFrame(scale: scale)
        } else {
            self.switchScaleBtn.setImage(UIImage.loadLocalImagePDF(name: "ic_restore_post.pdf"), for: .normal)
            scrollView.top = 0
            scrollView.left = 0
            scrollView.width = width
            scrollView.height = height
        }
        
        scrollView.zoomScale = 1
        imageView.size = getImageSize(containerW: scrollView.width, containerH: scrollView.height, image: imageView.image ?? UIImage())
        scrollView.contentSize = imageView.size
        scrollView.contentOffset = CGPoint(
            x: (imageView.size.width - scrollView.width) * 0.5,
            y: (imageView.size.height - scrollView.height) * 0.5
        )
        
        updateEditedAssetItem()
        
        dividerView.frame = scrollView.frame
    }
    
    /// 留白
    @IBAction func clickSwitchRemainWhiteAction(_ sender: UIButton) {
        
        impactFeedback(style: .light)
        PhotoPickerConfigManager.shared.statistics?("PO-ACTION-05")

        guard let image = imageView.image else { return }

        scrollView.zoomScale = 1
        imageView.frame = getRemainRect(image: image)
        scrollView.contentSize = imageView.size
        scrollView.contentOffset = CGPoint(
            x: 0,
            y: 0
        )
        
        switchRemainWhiteBtn.isHidden = true
        switchFillBtn.isHidden = false
        
        updateEditedAssetItem()
    }
    
    /// 充满
    @IBAction func clickSwitchFillAction(_ sender: UIButton) {
        
        impactFeedback(style: .light)
        PhotoPickerConfigManager.shared.statistics?("PO-ACTION-06")

        guard  let image = imageView.image else {
                return
        }
        
        scrollView.zoomScale = 1
        imageView.frame = getFillRect(image: image)
        scrollView.contentSize = imageView.size
        scrollView.contentOffset = CGPoint(
            x: 0,
            y: 0
        )

        switchRemainWhiteBtn.isHidden = false
        switchFillBtn.isHidden = true
        
        updateEditedAssetItem()
    }
}

extension EditView: EditViewInputs {}
extension EditView: EditViewOutputs {}

/// 预览模式
private extension EditView {
    
    func preview(item: AssetItem) {
        
        guard let image = item.fullResolutionImage else {
                return
        }
        
        if image.size.width != image.size.height {
            switchScaleBtn.isHidden = false
        }

        imageView.size = getImageSize(containerW: scrollView.width, containerH: scrollView.height, image: image)
        scrollView.zoomScale = 1
        scrollView.contentSize = imageView.size
        scrollView.contentOffset = CGPoint(
            x: (imageView.size.width - width) * 0.5,
            y: (imageView.size.height - height) * 0.5
        )
    }
}

/// 选中了第一张后, 选择其他图片, 会存在有缓存和没有缓存的情况  只有在 1:1 并且还是选中了长图的情况下, 才显示留白 or 充满
private extension EditView {

    func selectedOther(item: AssetItem, firstScale: Scale?) {
        
        guard let scale = firstScale,
            let image = item.fullResolutionImage else {
                return
        }
        
        scrollView.frame = getScrollViewFrame(scale: scale)

        if let editInfo = item.editInfo {
            updateImageViewHaveEditInfo(editInfo: editInfo, firstScale: scale, image: image)
        } else {
            updateImageViewNotEditInfo(firstScale: scale, image: image)
        }
    }
}

/// 选中了已经被选中的第一个 item == firstItem
private extension EditView {
    
    func selectedFirst(item: AssetItem, firstScale: Scale?) {
        if firstScale == nil {                                          /// 直接选中了第一张图会走到这里
            self.preview(item: item)
        } else {                                                                /// 有缓存的情况
            self.selectedFirstHaveEditInfo(item: item)
        }
    }
    
    func selectedFirstHaveEditInfo(item: AssetItem) {
        
        guard let image = item.fullResolutionImage,
              let editInfo = item.editInfo else {
                return
        }
        
        let imageW = image.size.width
        let imageH = image.size.height
        
        if imageW != imageH {
            switchScaleBtn.isHidden = false
        }

        scrollView.frame = getScrollViewFrame(scale: editInfo.scale)
        updateImageViewToFirst(editInfo: editInfo, image: image)
    }
}

/// update
private extension EditView {
    
    /// 在有选中第一张的情况下, 又选中了其他, 并且有缓存
    func updateImageViewHaveEditInfo(editInfo: EditInfo, firstScale: Scale, image: UIImage) {
        
        if firstScale == .oneToOne &&  image.size.width != image.size.height {
            if editInfo.mode == .remain {
                switchFillBtn.isHidden = false
                imageView.frame = getRemainRect(image: image)
            } else if editInfo.mode == .fill {
                switchRemainWhiteBtn.isHidden = false
                imageView.frame = getFillRect(image: image)
            }
        } else {
            imageView.frame.origin = CGPoint(x: 0, y: 0)
            imageView.size = getImageSize(containerW: scrollView.width, containerH: scrollView.height, image: image)
        }
        scrollView.zoomScale = editInfo.zoomScale
        scrollView.contentSize = imageView.size
        scrollView.contentOffset = editInfo.contentOffset
    }
    
    /// 在有选中第一张的情况下, 又选中了其他, 并且没有缓存
    func updateImageViewNotEditInfo(firstScale: Scale, image: UIImage) {

        let imageW = image.size.width
        let imageH = image.size.height
        
        if firstScale == .oneToOne && imageW != imageH {
            switchRemainWhiteBtn.isHidden = false
        }
        
        imageView.frame.origin = CGPoint(x: 0, y: 0)
        imageView.size = getImageSize(containerW: scrollView.width, containerH: scrollView.height, image: image)
        scrollView.zoomScale = 1
        scrollView.contentSize = imageView.size
        scrollView.contentOffset = CGPoint(
            x: (imageView.size.width - scrollView.width) * 0.5,
            y: (imageView.size.height - scrollView.height) * 0.5
        )
    }
    
    /// 只在重复选中第一个的时候调用
    func updateImageViewToFirst(editInfo: EditInfo, image: UIImage) {
        
        self.imageView.size = getImageSize(containerW: scrollView.width, containerH: scrollView.height, image: image)
        self.scrollView.zoomScale = editInfo.zoomScale
        self.scrollView.contentSize = imageView.size
        self.scrollView.contentOffset = editInfo.contentOffset
    }
}

extension EditView {
    
    func updateEditedAssetItem() {
        
        var mode: Mode = .fill
        if imageView.left != 0 || imageView.top != 0 {
            mode = .remain
        }
        
        var scale: Scale = .oneToOne
        if scrollView.width == scrollView.height {
            scale = .oneToOne
        } else if scrollView.width > scrollView.height {
            scale = .fourToThreeHorizontal
        } else if scrollView.width < scrollView.height {
            scale = .fourToThreeVertical
        }
        
        let editInfo = EditInfo(
            zoomScale: scrollView.zoomScale,
            contentOffset: scrollView.contentOffset,
            scale: scale,
            mode: mode
        )
        guard let item = self.assetItem else { return }
        var tItem = item
        tItem.editInfo = editInfo
        editedAssetItem.onNext(tItem)
    }
}

private extension EditView {
    
    func configureImage() {
        data
            .subscribe(onNext: { [unowned self] datas in
                
                self.assetItem = datas.0
                self.firstItem = datas.1
                
                guard let item = self.assetItem,
                    let image = item.fullResolutionImage else {
                        return
                }
                
                let imageW = image.size.width
                let imageH = image.size.height
                
                self.imageView.size = CGSize(width: imageW, height: imageH)
                self.imageView.frame.origin = CGPoint(x: 0, y: 0)
                
                self.scrollView.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height)
                self.scrollView.zoomScale = 1
                self.scrollView.contentSize = self.imageView.size
                self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
                
                self.switchScaleBtn.isHidden = true
                self.switchRemainWhiteBtn.isHidden = true
                self.switchFillBtn.isHidden = true
                
                if let config = datas.2 {
                    self.selectedOther(item: item, firstScale: config.scale)
                } else {
                    if let firstItem = self.firstItem {
                        if item.id == firstItem.id {                                /// 选中了第一张图的情况下又选中了第一张图
                            self.selectedFirst(item: item, firstScale: firstItem.editInfo?.scale)
                        } else {                                                    /// 选中了第一张, 再点击其他图片预览
                            self.selectedOther(item: item, firstScale: firstItem.editInfo?.scale)
                        }
                    } else {                                                        /// 预览模式, 随便点着看
                        self.preview(item: item)
                    }
                }
                
                self.dividerView.frame = self.scrollView.frame
                self.imageView.image = image
                self.updateEditedAssetItem()
                
                let imageName = self.scrollView.width == self.scrollView.height ? "ic_restore_post.pdf" : "ic_proportion_post.pdf"
                self.switchScaleBtn.setImage(UIImage.loadLocalImagePDF(name: imageName), for: .normal)
                
                PhotoPickerConfigManager.shared.statistics?("PO-EVENT-01")
            })
            .disposed(by: rx.disposeBag)
    }
    
    func configureImageView() {
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: width)
        scrollView.addSubview(imageView)
    }
    
    func configureScrollView() {
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        scrollView.delegate = self
        scrollView.bouncesZoom = true
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .white
    }
    
    func configureDividerView() {
        dividerView = DividerView(frame: scrollView.bounds)
        dividerView.alpha = 0
        addSubview(dividerView)
    }
}
