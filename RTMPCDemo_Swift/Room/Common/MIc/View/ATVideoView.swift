//
//  ATVideoView.swift
//  RTMPCDemo_Swift
//
//  Created by jh on 2018/3/30.
//  Copyright © 2018年 jh. All rights reserved.
//

import UIKit

protocol HangUpDelegate {
    //主播或自己挂断连麦
    func hangUpOperation(peerId: String)
}

class ATVideoView: UIView {
    
    @IBOutlet weak var nameLabel: UILabel!
    //挂断连麦（主播或自己显示，默认不显示）
    @IBOutlet weak var hangUpButton: UIButton!
    //视图的分辨率大小
    var videoSize: CGSize?{
        didSet
        {
            print("--------- 视图大小改变 ----------")
        }
    }
    
    var delegate: HangUpDelegate?
    
    var strPeerId = ""
    //标识流id
    var strPubId = ""
    
    var isDisplay = false
    
    override func awakeFromNib() {
        //默认不显示
        isDisplay ? (hangUpButton.isHidden = false) : (hangUpButton.isHidden = true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
            self.hangUpButton.isHidden = true
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(displayHangUpButton))
        self.addGestureRecognizer(tap)
    }
    
    //点击显示3秒
    @objc func displayHangUpButton(){
        if isDisplay {
            hangUpButton.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0){
                self.hangUpButton.isHidden = true
            }
        }
    }
    
    class func videoView() -> ATVideoView {
        return Bundle.main.loadNibNamed("ATVideoView", owner: nil, options: nil)![0] as! ATVideoView
    }
    
    func initialize(name: String,peerId: String ,pubId: String ,videoSize: CGSize,isDisplay: Bool) {
        nameLabel.text = name
        self.strPeerId = peerId
        self.strPubId = pubId
        self.videoSize = videoSize
        self.isDisplay = isDisplay
    }
    
    //挂断连麦
    @IBAction func hangUpMic(_ sender: Any) {
        self.delegate?.hangUpOperation(peerId: strPeerId)
    }
}
