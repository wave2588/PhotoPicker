//
//  PhotoLibrary+Extension.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/12.
//  Copyright © 2018 wave. All rights reserved.
//

import Foundation

//"Recently Added"
//"Selfies"
//"Screenshots"
//"Recently Deleted"
//"Portrait"
//"Panoramas"
//"Time-lapse"
//"Slo-mo"
//"Bursts"
//"Camera Roll"
//"Favorites"
//"Videos"
//"Animated"
//"Hidden"
//"Long Exposure"
//"Live Photos"

extension PhotoLibrary {
    
    //由于系统返回的相册集名称为英文，我们需要转换为中文
    func titleOfAlbumForChinse(title:String) -> String {
        if title == "Slo-mo" {
            return "慢动作"
        } else if title == "Recently Added" {
            return "最近添加"
        } else if title == "Favorites" {
            return "个人收藏"
        } else if title == "Recently Deleted" {
            return "最近删除"
        } else if title == "Videos" {
            return "视频"
        } else if title == "All Photos" {
            return "所有照片"
        } else if title == "Selfies" {
            return "自拍"
        } else if title == "Screenshots" {
            return "屏幕快照"
        } else if title == "Camera Roll" {
            return "相机胶卷"
        }
        return title
    }
}

extension PhotoLibrary {
    
    class func timeFormatted(timeInterval: TimeInterval) -> String {
        let seconds: Int = lround(timeInterval)
        var hour: Int = 0
        var minute: Int = Int(seconds/60)
        let second: Int = seconds % 60
        if minute > 59 {
            hour = minute / 60
            minute = minute % 60
            return String(format: "%d:%d:%02d", hour, minute, second)
        } else {
            return String(format: "%d:%02d", minute, second)
        }
    }
}
