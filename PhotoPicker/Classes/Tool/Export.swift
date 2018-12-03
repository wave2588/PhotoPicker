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
    
    public static func video(asset: PHAsset, completionHandler:@escaping (_ videoPath: String?) -> ()) {
        let options = PHVideoRequestOptions()
        options.version = .current
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true
        PHCachingImageManager.default().requestAVAsset(forVideo: asset, options: options) { (avAsset, _, _) in
            guard let avUrlAsset = avAsset as? AVURLAsset else {
                completionHandler(nil)
                return
            }
            
            let data = FileManager.default.contents(atPath: avUrlAsset.url.path)
            do {
                let outputPath = getOutputFilePath()
                try data?.write(to: URL(fileURLWithPath: outputPath))
                completionHandler(outputPath)
            } catch {
                completionHandler(nil)
            }
        }
    }
}

extension Export {
    
    static func getOutputFilePath() -> String {
        let documnetPath = NSTemporaryDirectory()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let fileName = formatter.string(from: Date())
        let filePath = documnetPath.appendingPathComponent(fileName) + ".MP4"
        if FileManager.default.fileExists(atPath: filePath) {
            do{
                try FileManager.default.removeItem(atPath: filePath)
            } catch {
                print("文件存在，删除失败")
            }
        }
        return filePath
    }
}
