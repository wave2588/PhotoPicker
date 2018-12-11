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



extension UIViewController {
    func addT(asChildViewController viewController: UIViewController, frame: CGRect? = nil) {
        
        addChild(viewController)
        
        view.addSubview(viewController.view)
        
        viewController.view.frame = frame ?? view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        viewController.didMove(toParent: self)
    }
}

class TwoViewController: UIViewController {

    let vc: PhotoPickerViewController = .fromStoryboard()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
        
        PhotoPickerConfigManager.shared.message = { type, str in
            if type == .success {
                debugPrint("成功提示---->: \(str)")
            } else {
                debugPrint("失败提示---->: \(str)")
            }
        }
        
        view.backgroundColor = .red
        
        let config = PhotoPickerConfig()
        config.maxSelectCount = 2
        config.scale = .fourToThreeHorizontal
//        vc.inputs.config.accept(config)

        let frame = CGRect(x: 0, y: 0, width: view.width, height: view.height - 40 - bottomSafe)
        addT(asChildViewController: vc, frame: frame)

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
