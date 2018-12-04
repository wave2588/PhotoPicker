//
//  TwoViewController.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/26.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PhotoPicker
import AVFoundation
import Photos

class TwoViewController: UIViewController {

    let vc = UIStoryboard(name: "PhotoPicker", bundle: nil).instantiateViewController(withIdentifier: "PhotoPickerViewController") as! PhotoPickerViewController

//    let vc = PhotoPickerViewController.fromStoryboard

    override func viewDidLoad() {
        super.viewDidLoad()

        PhotoPickerConfigManager.shared.fail = { str in
            debugPrint("fail:  \(str)")
        }
        
        view.backgroundColor = .white
        
        view.addSubview(vc.view)
        
        vc.view.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height - 78)
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vc.didMove(toParent: self)
        
        vc.outputs.clickClose.subscribe(onNext: { [unowned self] _ in
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
        
        vc.outputs.clickNextStep.subscribe(onNext: { [unowned self] item in
            
            let vc = ThreeViewController()
            vc.item = item
            self.present(vc, animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
        
        vc.outputs.clickVideo.subscribe(onNext: { asset in
            debugPrint("开始导出")
            Export.video(asset: asset, completionHandler: { path in
                if let pathStr = path {
                    debugPrint("导出成功------->:  \(pathStr)")
                } else {
                    debugPrint("导出失败")
                }
            })
        }).disposed(by: rx.disposeBag)
    }
}

func getOutputFilePath() -> String {
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
