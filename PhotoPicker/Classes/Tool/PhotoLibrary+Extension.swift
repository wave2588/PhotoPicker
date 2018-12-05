//
//  PhotoLibrary+Extension.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/12.
//  Copyright © 2018 wave. All rights reserved.
//

import Foundation

//if title == "Slo-mo" {
//    return "慢动作"
//} else if title == "Recently Added" {
//    return "最近添加"
//} else if title == "Favorites" {
//    return "个人收藏"
//} else if title == "Recently Deleted" {
//    return "最近删除"
//} else if title == "Videos" {
//    return "视频"
//} else if title == "All Photos" {
//    return "所有照片"
//} else if title == "Selfies" {
//    return "自拍"
//} else if title == "Screenshots" {
//    return "屏幕快照"
//} else if title == "Camera Roll" {
//    return "相机胶卷"
//} else if title == "Portrait" {
//    return "人像"
//}

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
    
    func titleOfAlbumForChinse(title:String) -> String {
        
        let dict = [
            "Slo-mo"            : "慢动作",
            "Recently Added"    : "最近添加",
            "Favorites"         : "个人收藏",
            "Recently Deleted"  : "最近删除",
            "Videos"            : "视频",
            "All Photos"        : "所有照片",
            "Selfies"           : "自拍",
            "Screenshots"       : "屏幕快照",
            "Camera Roll"       : "相机胶卷",
            "Portrait"          : "人像"
        ]
        
        if let cn = dict[title] {
            return cn
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
