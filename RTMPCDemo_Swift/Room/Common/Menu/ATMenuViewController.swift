//
//  ATMenuViewController.swift
//  RTMPCDemo_Swift
//
//  Created by jh on 2018/4/3.
//  Copyright © 2018年 jh. All rights reserved.
//

import UIKit

class ATMenuViewController: UIViewController {
    
    var mHosterKit: RTMPCHosterKit!

    @IBOutlet weak var menuView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for object in menuView.subviews {
            if object is UIButton {
                let button: UIButton = object as! UIButton
                if button.tag == 101 {
                    button.isSelected = true
                }
                button.layoutButtonWithEdgeInsetsStyle(style: EdgeInsetsStyle.Top, space: 10)
            }
        }
    }
    
    @IBAction func doSomethingEvent(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        switch sender.tag {
        case 100:
            mHosterKit.switchCamera()
            break
        case 101:
            sender.isSelected ? (mHosterKit.setCameraFilter(AnyCameraDeviceFilter_Beautiful)):(mHosterKit.setCameraFilter(AnyCameraDeviceFilter_Original))
            break
        case 102:
            mHosterKit.setLocalVideoEnable(!sender.isSelected)
            break
        case 103:
            mHosterKit.setLocalAudioEnable(!sender.isSelected)
            break
        default: break
        }
    }
    
    // MARK: - Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.dismiss(animated: true, completion: nil)
    }
    
}
