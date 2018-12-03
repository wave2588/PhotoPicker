//
//  Export.swift
//  PhotoPicker
//
//  Created by wave on 2018/12/3.
//  Copyright © 2018 wave. All rights reserved.
//

import Foundation
import Photos

public struct Export {
    
    public static func video(asset: PHAsset, outPutPath: String, completionHandler:@escaping (_ success: Bool) -> ()) {
        let options = PHVideoRequestOptions()
        options.version = .current
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true
        PHCachingImageManager.default().requestAVAsset(forVideo: asset, options: options) { (avAsset, _, _) in
            guard let avUrlAsset = avAsset as? AVURLAsset else {
                completionHandler(false)
                return
            }
            
            let data = FileManager.default.contents(atPath: avUrlAsset.url.path)
            do {
                try data?.write(to: URL(fileURLWithPath: outPutPath))
                completionHandler(true)
            } catch {
                completionHandler(false)
            }
        }
    }
}
