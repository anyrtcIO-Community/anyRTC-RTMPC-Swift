//
//  ATAudioAudienceController.swift
//  RTMPCDemo_Swift
//
//  Created by jh on 2018/3/8.
//  Copyright © 2018年 jh. All rights reserved.
//

import UIKit
import BarrageRenderer
import XHToastSwift

class ATAudioAudienceController: ATBarrageViewController,RTMPCGuestRtcDelegate,RTMPCGuestRtmpDelegate,HangUpDelegate{
    
    //rtc状态
    @IBOutlet weak var rtcLabel: UILabel!
    //rtmp状态
    @IBOutlet weak var rtmpLabel: UILabel!
    //房间名
    @IBOutlet weak var topicLabel: UILabel!
    //房间号
    @IBOutlet weak var roomIdLabel: UILabel!
    //在线人员
    @IBOutlet weak var onlineLabel: UILabel!
    //在线人员
    @IBOutlet weak var listView: UIView!
    
    @IBOutlet weak var backImageView: UIImageView!
    //连麦容器
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var barrageView: UIView!
    //弹幕控制器
    @IBOutlet weak var barrageButton: UIButton!
    //主播头像
    @IBOutlet weak var localButton: ATAudioButton!
    
    @IBOutlet weak var applyButton: UIButton!
    //音频开关（连麦时显示）
    @IBOutlet weak var audioButton: UIButton!
    
    fileprivate var gestAudioKit: RTMPCGuestAudioKit!
    
    var hallModel: ATHallModel!
    
    var userName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topicLabel.text = hallModel.liveTopic
        roomIdLabel.text = "房间id：" + hallModel.anyrtcId
        
        //获取在线人员列表
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(getMemberList))
        listView.addGestureRecognizer(tap)
        barrageView.addSubview(renderer.view)
        
        localButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(120)
            make.center.equalTo(view)
        }
        
        audioButton.isHidden = true
        
        setUpInitialization()
        if hallModel.isLiveLandscape == 1 {
            orientationRotating(direction: UIInterfaceOrientation.landscapeLeft)
            backImageView.image = UIImage(named: "voice_background_lan")
        }
    }
    
    //初始化RTMPC信息
    func setUpInitialization(){
        gestAudioKit = RTMPCGuestAudioKit(delegate:self as RTMPCGuestRtmpDelegate,withAudioDetect:true)
        //开始拉流
        gestAudioKit.startRtmpPlay(hallModel.rtmpUrl)
        
        gestAudioKit.rtc_delegate = self
        
        let userDic : NSDictionary = ["nickName": userName,"headUrl": ""]
        
        let userId = randomCharacter(length: 6)
        //加入RTC
        gestAudioKit.joinRTCLine(hallModel.anyrtcId, andUserID:userId, andUserData: getJSONStringFromDictionary(dictionary: userDic))
    }
    
    @IBAction func doSomethingEvent(_ sender: UIButton){
        
        sender.isSelected = !sender.isSelected
        switch sender.tag {
        case 100:
            //申请连麦
            if sender.isSelected {
                gestAudioKit.applyRTCLine() ? (sender.backgroundColor = UIColor.red): (sender.isSelected = false)
            } else {
                gestAudioKit.hangupRTCLine()
                audioButton.isHidden = true
                sender.backgroundColor = UIColor.blue
                applyButton.setTitle("申请连麦", for: UIControlState.normal)
                audioArr.enumerateObjects({ (object, index, stop) in
                    if object is ATAudioView {
                        let audioView: ATAudioView = object as! ATAudioView
                        audioArr.removeObject(at: index)
                        audioView.removeFromSuperview()
                    }
                })
                layoutAudioView(hosterButton: localButton, containerView: containerView, landscape: Int32(hallModel.isLiveLandscape))
            }
            break
        case 101:
            //消息
            messageTextField.becomeFirstResponder()
            break
        case 102:
            //音频开关
            gestAudioKit.setLocalAudioEnable(!sender.isSelected)
            break
        case 103:
            //退出
            gestAudioKit.clear()
            orientationRotating(direction: UIInterfaceOrientation.portrait)
            
            navigationController?.popViewController(animated: true)
            break
        case 104:
            //弹幕控制器
            barrageView.isHidden = sender.isSelected
            break
        default:
            break
        }
    }
    
    // MARK: - HangUpDelegate
    func hangUpOperation(peerId: String) {//挂断连麦
        gestAudioKit.hangupRTCLine()
        audioArr.enumerateObjects { (object, index, stop) in
            if object is ATAudioView {
                let audio: ATAudioView = object as! ATAudioView
                audioArr.removeObject(at: index)
                audio.removeFromSuperview()
            }
        }
        applyButton.isSelected = false
        applyButton.setTitle("申请连麦", for: UIControlState.normal)
        applyButton.backgroundColor = UIColor.blue
        layoutAudioView(hosterButton: localButton, containerView: containerView, landscape: Int32(hallModel.isLiveLandscape))
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != nil {
            renderer.receive(produceTextBarrage(message:textField.text!, direction: BarrageWalkDirection.L2R.rawValue))
            //主播自己发送弹幕，打开弹幕显示
            barrageView.isHidden = false
            barrageButton.isSelected = false
            
            //发送弹幕
            gestAudioKit.sendUserMessage(RTC_Barrage_Message_Type, withUserName: userName, andUserHeader: "", andContent: textField.text)
            
            textField.resignFirstResponder()
            textField.text = ""
        }
        return true
    }
    
    // MARK: - RTMPCGuestRtmpDelegate
    func onRtmpPlayerOk() {
        //RTMP 连接成功
        rtmpLabel.text = "RTMP服务连接成功"
    }
    
    func onRtmpPlayerStart() {
        //RTMP 开始播放
    }
    
    func onRtmpPlayerStatus(_ nCacheTime: Int32, withBitrate nBitrate: Int32) {
        //RTMP 当前播放状态
        rtmpLabel.text = "RTMP延迟:\(String(format: "%.2f", Double(nCacheTime)/1000.00)) fs 当前上传网速:\(String(format: "%.2f", Double(nBitrate)/1024.00/8.00)) fkb/s"
    }
    
    func onRtmpPlayerLoading(_ nPercent: Int32) {
        //RTMP播放缓冲进度
        rtmpLabel.text = "RTMP服务连接失败"
    }
    
    func onRtmpPlayerClosed(_ nCode: Int32) {
        //RTMP播放器关闭
        rtmpLabel.text = "RTMP服务关闭"
    }
    
    // MARK: - RTMPCGuestRtcDelegate
    func onRTCJoinLineResult(_ nCode: Int32) {
        //RTC服务连接结果
        nCode == 0 ? (rtcLabel.text = "RTC服务链接成功") : (rtcLabel.text = "RTC服务链接失败")
    }
    
    func onRTCApplyLineResult(_ nCode: Int32) {
        //游客申请连麦结果回调
        if nCode == 0 {
            applyButton.setTitle("挂断", for: UIControlState.normal)
            applyButton.backgroundColor = UIColor.red
            
            audioButton.isHidden = false
            
            let audio: ATAudioView = ATAudioView.audioView()
            audio.initialize(name: userName, peerId: video_MySelf, isDisplay: true)
            audio.delegate = self
            view.addSubview(audio)
            audioArr.add(audio)
            layoutAudioView(hosterButton: localButton, containerView: containerView, landscape: Int32(hallModel.isLiveLandscape))
        } else {
            applyButton.isSelected = false
            applyButton.backgroundColor = UIColor.blue
            applyButton.setTitle("申请连麦", for: UIControlState.normal)
        }
    }
    
    func onRTCHangupLine() {
        //主播挂断游客连麦
        audioArr.enumerateObjects { (object, index, stop) in
            if object is ATAudioView {
                let myAudio: ATAudioView = object as! ATAudioView
                audioArr.removeObject(at: index)
                myAudio.removeFromSuperview()
            }
        }
        
        audioButton.isHidden = true
        applyButton.isSelected = false
        applyButton.setTitle("申请连麦", for: UIControlState.normal)
        applyButton.backgroundColor = UIColor.blue
        layoutAudioView(hosterButton: localButton, containerView: containerView, landscape: Int32(hallModel.isLiveLandscape))
    }
    
    func onRTCLineLeave(_ nCode: Int32) {
        //断开RTC服务连接
        if nCode == 0 {
            XHToast.showCenterWithText("直播已结束")
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
                self.gestAudioKit.clear()
                self.orientationRotating(direction: UIInterfaceOrientation.portrait)
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    func onRTCOpenVideoRender(_ strLivePeerId: String!, withRTCPubId strRTCPubId: String!, withUserId strUserId: String!, withUserData strUserData: String!) {
        //其他游客视频连麦接通
    }
    
    func onRTCCloseVideoRender(_ strLivePeerId: String!, withRTCPubId strRTCPubId: String!, withUserId strUserId: String!) {
        //其他游客视频连麦挂断
    }
    
    func onRTCOpenAudioLine(_ strLivePeerId: String!, withUserId strUserId: String!, withUserData strUserData: String!) {
        //其他游客音频连麦接通
        if strLivePeerId != "RTMPC_Line_Hoster" {
            let dic = getDictionaryFromJSONString(jsonString: strUserData.removingPercentEncoding!)
            
            let aduioView: ATAudioView = ATAudioView.audioView()
            aduioView.initialize(name: dic["nickName"] as! String, peerId: strLivePeerId, isDisplay: false)
            aduioView.delegate = self
            audioArr.add(aduioView)
            layoutAudioView(hosterButton: localButton, containerView: containerView, landscape: Int32(hallModel.isLiveLandscape))
        }
    }
    
    func onRTCCloseAudioLine(_ strLivePeerId: String!, withUserId strUserId: String!) {
        //其他游客连麦音频挂断
        audioArr.enumerateObjects { (object, index, stop) in
            if object is ATAudioView {
                let audio : ATAudioView = object as! ATAudioView
                if audio.strPeerId == strLivePeerId {
                    audio.removeFromSuperview()
                    audioArr.removeObject(at: index)
                    layoutAudioView(hosterButton: localButton, containerView: containerView, landscape: Int32(hallModel.isLiveLandscape))
                }
            }
        }
    }
    
    func onRTCAudioActive(_ strLivePeerId: String!, withUserId strUserId: String!, withShowTime nTime: Int32) {
        //RTC音频检测（自己没有回调）
        if strLivePeerId == "RTMPC_Line_Hoster" {
            localButton.startAudioAnimation()
            return
        }
        
        audioArr.enumerateObjects { (object, index, stop) in
            if object is ATAudioView {
                let audio : ATAudioView = object as! ATAudioView
                if audio.strPeerId == strLivePeerId {
                    audio.headButton.startAudioAnimation()
                }
            }
        }
    }
    
    func onRTCViewChanged(_ videoView: UIView!, didChangeVideoSize size: CGSize) {
        //其他连麦者或主播视频窗口的对音视频的操作
    }
    
    func onRTCAVStatus(_ strRTCPeerId: String!, withAudio bAudio: Bool, withVideo bVideo: Bool) {
        //视频窗口大小改变
    }
    
    func onRTCUserMessage(_ nType: RTCMessageType, withUserId strUserId: String!, withUserName strUserName: String!, withUserHeader strUserHeaderUrl: String!, withContent strContent: String!) {
        //收到消息回调
        renderer.receive(produceTextBarrage(message:strContent, direction: BarrageWalkDirection.L2R.rawValue))
    }
    
    func onRTCMemberListNotify(_ strServerId: String!, withRoomId strRoomId: String!, withAllMember nTotalMember: Int32) {
        //直播间实时在线人数变化通知
        onlineLabel.text = String(nTotalMember)
        
        listVc.anyrtcId = hallModel.anyrtcId
        listVc.serverId = strServerId
        listVc.roomId = strRoomId
    }
}

