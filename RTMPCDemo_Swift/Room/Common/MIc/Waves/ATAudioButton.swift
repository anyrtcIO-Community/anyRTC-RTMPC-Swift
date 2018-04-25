//
//  ATAudioButton.swift
//  RTMPCDemo_Swift
//
//  Created by jh on 2018/4/9.
//  Copyright © 2018年 jh. All rights reserved.
//

import UIKit

class ATAudioButton: UIButton {

    var timer: Timer!

    //音频检测
    public func startAudioAnimation() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(wavesRippleAnimation), userInfo: nil, repeats: true)
        }
    }
    
    //水波动画
    @objc func wavesRippleAnimation() {
        let wavesView = ATWavesView(frame:self.bounds)
        wavesView.backgroundColor = UIColor.clear
        self.addSubview(wavesView)
        
        UIView.animate(withDuration: 2, animations: {
            wavesView.transform = wavesView.transform.scaledBy(x: 2, y: 2)
            wavesView.alpha = 0
        }) { (true) in
            wavesView.removeFromSuperview()
            if self.timer != nil {
                self.timer.invalidate()
                self.timer = nil
            }
        }
    }
}
