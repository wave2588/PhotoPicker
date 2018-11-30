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
    var assetItems: PublishSubject<(AssetItem, AssetItem?)> { get }
}

protocol EditViewOutputs {
    
    var editedAssetItem: PublishSubject<AssetItem> { get }
}

class EditView: UIView {

    var inputs: EditViewInputs { return self }
    let assetItems = PublishSubject<(AssetItem, AssetItem?)>()
    
    var outputs: EditViewOutputs { return self }
    var editedAssetItem = PublishSubject<AssetItem>()
    
    private var assetItem: AssetItem?
    private var firstItem: AssetItem?
    
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
    
    let scale: CGFloat = 3 / 4
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureImageView()
        configureScrollView()
        configureDividerView()
        configureImage()
        backgroundColor = UIColor(red: 243/255.0, green: 248/255.0, blue: 248/255.0, alpha: 1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    @IBAction func clickSwitchScaleAction(_ sender: UIButton) {
        
        if scrollView.height == scrollView.width {
            
            let oldScrollViewH = scrollView.height
            let oldScrollViewW = scrollView.width
            
            if imageView.width > imageView.height {                         /// 横图
                let newScrollViewH = oldScrollViewH * scale
                let space = (oldScrollViewH - newScrollViewH) * 0.5
                scrollView.top = space
                scrollView.height = height - space * 2
            } else {                                                        /// 竖图
                let newScrollViewW = oldScrollViewW * scale
                let space = (oldScrollViewW - newScrollViewW) * 0.5
                scrollView.left = space
                scrollView.width = width - space * 2
            }
            
//            imageView.size = CGSize(
//                width: imageView.width * scale,
//                height: imageView.height * scale
//            )
            
            imageView.size = getSwitchScaleImageSize(containerSize: scrollView.size, image: imageView.image ?? UIImage())
            
            scrollView.contentSize = imageView.size
            scrollView.contentOffset = CGPoint(
                x: scrollView.contentOffset.x * scale,
                y: scrollView.contentOffset.y * scale
            )

        } else {
            scrollView.top = 0
            scrollView.left = 0
            scrollView.width = width
            scrollView.height = height

//            imageView.size = CGSize(
//                width: imageView.width / scale,
//                height: imageView.height / scale
//            )
            imageView.size = getSwitchScaleImageSize(containerSize: scrollView.size, image: imageView.image ?? UIImage())
            scrollView.contentSize = imageView.size
            scrollView.contentOffset = CGPoint(
                x: scrollView.contentOffset.x / scale,
                y: scrollView.contentOffset.y / scale
            )
        }
        
        updateEditedAssetItem()
        
        dividerView.frame = scrollView.frame
    }
    
    /// 留白 也是用 4:3 的比例
    @IBAction func clickSwitchRemainWhiteAction(_ sender: UIButton) {
        
        guard let image = imageView.image else { return }

        imageView.frame = getRemainRect(image: image)
        
        scrollView.contentSize = imageView.size
        scrollView.contentOffset = CGPoint(x: 0, y: 0)

        switchRemainWhiteBtn.isHidden = true
        switchFillBtn.isHidden = false
        
        updateEditedAssetItem()
    }
    
    /// 充满
    @IBAction func clickSwitchFillAction(_ sender: UIButton) {
        guard  let image = imageView.image else {
                return
        }
        
        imageView.size = getFillSize(image: image)
        
        imageView.top = 0
        imageView.left = 0
        scrollView.contentSize = imageView.size
        scrollView.contentOffset = CGPoint(x: 0, y: 0)

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

        imageView.size = getPreviewImageSize(image: image)
        scrollView.zoomScale = 1
        scrollView.contentSize = imageView.size
        scrollView.contentOffset = CGPoint(
            x: (imageView.size.width - width) * 0.5,
            y: (imageView.size.height - height) * 0.5
        )
    }
}

/// 选中了第一张后, 选择其他图片, 会存在有缓存和没有缓存的情况
private extension EditView {
    
    func selectedOther(item: AssetItem, firstItem: AssetItem) {
        
        if item.editInfo == nil {
            selectedOtherNotEditInfo(item: item, firstItem: firstItem)
        } else {
            selectedOtherHaveEditInfo(item: item, firstItem: firstItem)
        }
    }
    
    /// 只有在 1:1 并且还是选中了长图的情况下, 才显示留白 or 充满
    func selectedOtherNotEditInfo(item: AssetItem, firstItem: AssetItem) {
        
        guard let firstEditInfo = firstItem.editInfo,
              let image = item.fullResolutionImage else {
                return
        }
        
        scrollView.frame = getScrollViewFrame(editInfo: firstEditInfo)
        updateImageViewNotEditInfo(firstEditInfo: firstEditInfo, image: image)
    }
    
    func selectedOtherHaveEditInfo(item: AssetItem, firstItem: AssetItem) {
        
        guard let editInfo = item.editInfo,
              let firstEditInfo = firstItem.editInfo,
              let image = item.fullResolutionImage else {
                return
        }
        
        scrollView.frame = getScrollViewFrame(editInfo: firstEditInfo)
        updateImageViewHaveEditInfo(editInfo: editInfo, firstEditInfo: firstEditInfo, image: image)
    }
    
}

/// 选中了已经被选中的第一个 item == firstItem
private extension EditView {
    
    func selectedFirst(item: AssetItem, firstItem: AssetItem) {
        if firstItem.editInfo == nil {                                          /// 直接选中了第一张图会走到这里
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

        scrollView.frame = getScrollViewFrame(editInfo: editInfo)
        updateImageViewToFirst(editInfo: editInfo, image: image)
    }
}

/// update
private extension EditView {
    
    /// 在有选中第一张的情况下, 又选中了其他, 并且有缓存
    func updateImageViewHaveEditInfo(editInfo: EditInfo, firstEditInfo: EditInfo, image: UIImage) {
        
        let imageW = image.size.width
        let imageH = image.size.height
        
        var newImageW: CGFloat = width
        var newImageH: CGFloat = height

        if editInfo.scale == .oneToOne {
            if imageW == imageH {
            } else {
                if firstEditInfo.scale == .oneToOne {
                    if editInfo.mode == .remain {
                        switchFillBtn.isHidden = false
                    } else {
                        switchRemainWhiteBtn.isHidden = false
                    }
                }

                if imageW > imageH {
                    if editInfo.mode == .remain {
                        newImageH = height * scale
                        let ratio = newImageH / imageH
                        newImageW = imageW * ratio
                        imageView.top = (height - newImageH) * 0.5
                        imageView.left = 0
                    } else {
                        let ratio = height / imageH
                        newImageW = imageW * ratio
                        newImageH = imageH * ratio
                    }
                } else if imageW < imageH {
                    if editInfo.mode == .remain {
                        newImageW = width * scale
                        let ratio = newImageW / imageW
                        newImageH = imageH * ratio
                        imageView.top = 0
                        imageView.left = (width - newImageW) * 0.5
                    } else {
                        let ratio = width / imageW
                        newImageW = imageW * ratio
                        newImageH = imageH * ratio
                    }
                }
            }
        } else {
            let size = getImageViewSize(scale: editInfo.scale, image: image)
            newImageW = size.width
            newImageH = size.height
        }
        
        imageView.size = CGSize(width: newImageW, height: newImageH)
        scrollView.zoomScale = editInfo.zoomScale
        scrollView.contentSize = imageView.size
        scrollView.contentOffset = editInfo.contentOffset
    }
    
    /// 在有选中第一张的情况下, 又选中了其他, 并且没有缓存
    func updateImageViewNotEditInfo(firstEditInfo: EditInfo, image: UIImage) {

        let imageW = image.size.width
        let imageH = image.size.height
        
        if firstEditInfo.scale == .oneToOne {
            if imageW == imageH {
            } else if imageW > imageH {
                switchRemainWhiteBtn.isHidden = false
            } else if imageW < imageH {
                switchRemainWhiteBtn.isHidden = false
            }
        }
        
        let size = getImageViewSize(scale: firstEditInfo.scale, image: image)
        
        imageView.size = CGSize(width: size.width, height: size.height)
        scrollView.zoomScale = 1
        scrollView.contentSize = imageView.size
        scrollView.contentOffset = CGPoint(
            x: (size.width - scrollView.width) * 0.5,
            y: (size.height - scrollView.height) * 0.5
        )
    }
    
    /// 只在重复选中第一个的时候调用
    func updateImageViewToFirst(editInfo: EditInfo, image: UIImage) {
        
        let size = getImageViewSize(scale: editInfo.scale, image: image)
        
        self.imageView.size = CGSize(width: size.width, height: size.height)
        self.scrollView.zoomScale = editInfo.zoomScale
        self.scrollView.contentSize = imageView.size
        self.scrollView.contentOffset = editInfo.contentOffset
    }
}

private extension EditView {
    
    func configureImage() {
        assetItems
            .subscribe(onNext: { [unowned self] items in
                
                self.assetItem = items.0
                self.firstItem = items.1
                
                guard let item = self.assetItem,
                    let image = item.fullResolutionImage else {
                        return
                }
                
                let imageW = image.size.width
                let imageH = image.size.height
                
                self.imageView.size = CGSize(width: imageW, height: imageH)
                self.imageView.frame.origin = CGPoint(x: 0, y: 0)
                
                self.scrollView.top = 0
                self.scrollView.left = 0
                self.scrollView.height = self.height
                self.scrollView.width = self.width
                self.scrollView.zoomScale = 1
                self.scrollView.contentSize = self.imageView.size
                self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
                
                self.switchScaleBtn.isHidden = true
                self.switchRemainWhiteBtn.isHidden = true
                self.switchFillBtn.isHidden = true
                
                if let firstItem = self.firstItem {
                    if item.id == firstItem.id {                                /// 选中了第一张图的情况下又选中了第一张图
                        self.selectedFirst(item: item, firstItem: firstItem)
                    } else {                                                    /// 选中了第一张, 再点击其他图片预览
                        self.selectedOther(item: item, firstItem: firstItem)
                    }
                } else {                                                        /// 预览模式, 随便点着看
                    self.preview(item: item)
                }
                
                self.imageView.image = image
                
                self.updateEditedAssetItem()
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
        dividerView = DividerView(frame: imageView.bounds)
        dividerView.alpha = 0
//        addSubview(dividerView)
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
