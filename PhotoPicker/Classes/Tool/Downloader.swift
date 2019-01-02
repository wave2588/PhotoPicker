//
//  Downloader.swift
//  PhotoPicker
//
//  Created by wave on 2019/1/2.
//  Copyright © 2019 wave. All rights reserved.
//

import Foundation
import Photos

struct Downloader {
    
    static let shared = Downloader()

    func downloadImage(asset: PHAsset, progressHandler: @escaping (_ progress: CGFloat) -> (), completeHandler: @escaping (_ image: UIImage?) -> ()) {
        let options = PHImageRequestOptions()
        options.progressHandler = { progress, _, _, _ in
            progressHandler(progress.cgFloat)
        }
        options.isNetworkAccessAllowed = true
        options.resizeMode = .none
        PHImageManager.default().requestImageData(for: asset, options: options) { (data, daataUTI, orientation, info) in
            let image = UIImage(data: data ?? Data(), scale: UIScreen.main.scale)
            completeHandler(image)
        }
    }
    
    func downloadVideo(asset: PHAsset, progressHandler: @escaping (_ progress: CGFloat) -> (), completeHandler: @escaping (_ path: String?) -> ()) {
        let options = PHVideoRequestOptions()
        options.progressHandler = { progress, error, stop, info in
            progressHandler(progress.cgFloat)
        }
        options.isNetworkAccessAllowed = true
        options.version = .current
        options.deliveryMode = .highQualityFormat
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (avAsset, avAudio, info) in
            let asset = avAsset as? AVURLAsset
            completeHandler(asset?.url.path)
        }
    }
}
