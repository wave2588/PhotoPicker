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

class TwoViewController: UIViewController {

    let vc = UIStoryboard(name: "PhotoPicker", bundle: nil).instantiateViewController(withIdentifier: "PhotoPickerViewController") as! PhotoPickerViewController

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
        vc.closeBtn.setTitle("关闭", for: .normal)
        
        vc.outputs.clickVideo
            .subscribe(onNext: { session in
                
            })
            .disposed(by: rx.disposeBag)
        
        vc.closeBtn.rx.tap
            .bind { [unowned self] in
                debugPrint("closeBtn")
                self.dismiss(animated: true, completion: nil)
            }
            .disposed(by: rx.disposeBag)
        
        vc.nextStepBtn.rx.tap
            .bind { [unowned self] in
                debugPrint("start loading, \(NSDate())")
                let _ = self.vc.getSelectedImages()
                debugPrint("end loading, \(NSDate())")
            }
            .disposed(by: rx.disposeBag)
    }
}
