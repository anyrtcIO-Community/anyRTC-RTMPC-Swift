//
//  ATAudioView.swift
//  RTMPCDemo_Swift
//
//  Created by jh on 2018/4/4.
//  Copyright © 2018年 jh. All rights reserved.
//

import UIKit

class ATAudioView: UIView {
    
    @IBOutlet weak var headButton: ATAudioButton!
    //昵称
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hangUpButton: UIButton!
    
    var delegate: HangUpDelegate?
    
    var strPeerId = ""
    
    var isDisplay: Bool = false {
        didSet {
            //默认不显示（主播全部显示、游客端只显示自己）
            isDisplay ? (hangUpButton.isHidden = false) : (hangUpButton.isHidden = true)
        }
    }
    
    class func audioView() -> ATAudioView {
        return Bundle.main.loadNibNamed("ATAudioView", owner: nil, options: nil)![0] as! ATAudioView
    }
    
    func initialize(name: String, peerId: String, isDisplay: Bool) {
        nameLabel.text = name
        self.strPeerId = peerId
        self.isDisplay = isDisplay
    }
    
    @IBAction func hangUpMic(_ sender: Any) {
        self.delegate?.hangUpOperation(peerId: strPeerId)
    }
}
