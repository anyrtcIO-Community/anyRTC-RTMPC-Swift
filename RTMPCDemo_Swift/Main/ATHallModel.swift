//
//  ATHallModel.swift
//  RTMPCDemo_Swift
//
//  Created by jh on 2018/1/24.
//  Copyright © 2018年 jh. All rights reserved.
//

import UIKit

class ATHallModel: NSObject {
    // MARK: - 属性
    //拉流地址
    @objc var rtmpUrl = ""
    //hls地址（分享）
    @objc var hlsUrl = ""
    @objc var liveTopic = ""
    //anyrtcId（唯一）
    @objc var anyrtcId = ""
    //方向  0竖屏 1横屏
    @objc var isLiveLandscape: Int = 0
    //音视频 0视频 1音频
    @objc var isAudioLive: Bool = true
    
    @objc var hosterName = ""
}

class LiveInfo: NSObject {
    //anyrtcId(唯一)
    var anyrtcId = ""
    //房间名
    var liveTopic = ""
    //随机用户名
    var userName = ""
    //方向  0竖屏 1横屏
    var isLiveLandscape: Int = 0
    
    var isAudioLive: Bool = true
    //直播质量
    var videoMode = ""
    //推流地址
    var push_url = ""
    //拉流地址
    var pull_url = ""
    
    var hls_url = ""
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
