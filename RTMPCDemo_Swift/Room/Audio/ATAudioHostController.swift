//
//  ATAudioHostController.swift
//  RTMPCDemo_Swift
//
//  Created by jh on 2018/3/8.
//  Copyright © 2018年 jh. All rights reserved.
//

import UIKit
import BarrageRenderer

class ATAudioHostController: ATBarrageViewController,RTMPCHosterRtcDelegate,RTMPCHosterRtmpDelegate,HangUpDelegate{
    
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
    //自己头像
    @IBOutlet weak var localButton: ATAudioButton!
    
    fileprivate var mHosterAudioKit: RTMPCHosterAudioKit!
    
    var liveInfo: LiveInfo!
    //连麦请求
    var micArr = NSMutableArray()
    //直播时长
    var liveTime: NSInteger = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topicLabel.text = liveInfo.liveTopic
        roomIdLabel.text = "房间id：" + liveInfo.anyrtcId
        
        //获取在线人员列表
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(getMemberList))
        listView.addGestureRecognizer(tap)
        barrageView.addSubview(renderer.view)
        
        localButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(120)
            make.center.equalTo(view)
        }
        
        setUpInitialization()
        if liveInfo.isLiveLandscape == 1 {
            orientationRotating(direction: UIInterfaceOrientation.landscapeLeft)
            backImageView.image = UIImage(named: "voice_background_lan")
        }
    }
    
    //初始化RTMPC信息
    func setUpInitialization(){
        mHosterAudioKit = RTMPCHosterAudioKit(delegate: self, withAudioDetect: true)
        //开始推流
        mHosterAudioKit.startPushRtmpStream(liveInfo.push_url)
        
        mHosterAudioKit.rtc_delegate = self
        
        //用户信息
        let userDic : NSDictionary = ["isHost": NSNumber(value:1),"userId": randomCharacter(length: 6),"nickName": liveInfo.userName]
        //直播信息
        let livingInfo : NSDictionary = ["rtmpUrl": liveInfo.pull_url,"hlsUrl": liveInfo.hls_url,"anyrtcId": liveInfo.anyrtcId,"liveTopic": liveInfo.anyrtcId,"isLiveLandscape": NSNumber(value: liveInfo.isLiveLandscape),"isAudioLive": NSNumber(value: 1),"hosterName": liveInfo.userName]
        
        //创建RTC链接
        mHosterAudioKit.createRTCLine(liveInfo.anyrtcId, andUserId: "hosterUserId", andUserData: getJSONStringFromDictionary(dictionary: userDic), andLiveInfo: getJSONStringFromDictionary(dictionary: livingInfo))
        
        self.liveTime = NSInteger(NSDate().timeIntervalSince1970)
    }
    
    // MARK: - event
    
    @IBAction func doSomethingEvent(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        switch sender.tag {
        case 100:
            //消息
            messageTextField.becomeFirstResponder()
            break
        case 101:
            //连麦列表
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RTMPC_RealTimeMic") as! ATRealTimeMicController
            vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            vc.micArr = micArr
            vc.mHosterAudioKit = mHosterAudioKit
            self.present(vc, animated: true, completion: nil)
            break
        case 102:
            //音频
            mHosterAudioKit.setLocalAudioEnable(!sender.isSelected)
            break
        case 103:
            //退出
            mHosterAudioKit.clear()
            orientationRotating(direction: UIInterfaceOrientation.portrait)
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RTMPC_Video_End") as! ATLivingEndController
            vc.userName = self.liveInfo.userName
            vc.liveTime = NSInteger(NSDate().timeIntervalSince1970) - self.liveTime
            self.navigationController!.pushViewController(vc, animated: true)
            
            break
        case 104:
            //弹幕
            barrageView.isHidden = sender.isSelected
            break
        default:
            break
        }
    }
    
    // MARK: - HangUpDelegate
    func hangUpOperation(peerId: String) {//挂断连麦
        mHosterAudioKit.hangupRTCLine(peerId)
        audioArr.enumerateObjects { (object, index, stop) in
            if object is ATAudioView {
                let audio: ATAudioView = object as! ATAudioView
                if audio.strPeerId == peerId {
                    audioArr.removeObject(at: index)
                    audio.removeFromSuperview()
                    layoutAudioView(hosterButton: localButton, containerView: containerView, landscape: Int32(liveInfo.isLiveLandscape))
                }
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != nil {
            renderer.receive(produceTextBarrage(message:textField.text!, direction: BarrageWalkDirection.L2R.rawValue))
            //主播自己发送弹幕，打开弹幕显示
            barrageView.isHidden = false
            barrageButton.isSelected = false
            
            //发送弹幕
            mHosterAudioKit.sendUserMessage(Int32(RTMPCMessageType(rawValue: 1).rawValue), withUserName: liveInfo.userName, andUserHeader: "", andContent: textField.text)
            
            textField.resignFirstResponder()
            textField.text = ""
        }
        return true
    }
    
    //MARK: - RTMPCHosterRtmpDelegate
    
    func onRtmpStreamOk() {
        //RTMP 服务连接成功
        rtmpLabel.text = "RTMP服务连接成功"
    }
    
    func onRtmpStreamReconnecting(_ nTimes: Int32) {
        //RTMP服务重连
        rtmpLabel.text = "RTMP服务第\(nTimes)次重连中..."
    }
    
    func onRtmpStreamStatus(_ nDelayTime: Int32, withNetBand nNetBand: Int32) {
        //RTMP 推流状态
        rtmpLabel.text = "RTMP延迟:\(String(format: "%.2f", Double(nDelayTime)/1000.00)) fs 当前上传网速:\(String(format: "%.2f", Double(nNetBand)/1024.00/8.00)) fkb/s"
    }
    
    func onRtmpStreamFailed(_ nCode: Int32) {
        //RTMP 服务连接失败
        rtmpLabel.text = "RTMP服务连接失败"
    }
    
    func onRtmpStreamClosed() {
        //RTMP 服务关闭
        rtmpLabel.text = "RTMP服务关闭"
    }
    
    func cameraSourceDidGetPixelBuffer(_ sampleBuffer: CMSampleBuffer!) {
        //获取视频的原始采集数据
    }
    
    //MARK: - RTMPCHosterRtcDelegate
    
    func onRTCCreateLineResult(_ nCode: Int32) {
        //创建RTC服务连接结果
        nCode == 0 ? (rtcLabel.text = "RTC服务链接成功") : (rtcLabel.text = "RTC服务链接失败")
    }
    
    func onRTCApply(toLine strLivePeerId: String!, withUserId strUserId: String!, withUserData strUserData: String!) {
        //主播收到游客连麦请求
        let micModel: ATRealMicModel = ATRealMicModel()
        micModel.peerId = strLivePeerId
        micModel.userId = strUserId
        micModel.userData = strUserData
        micArr.add(micModel)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LineNumChangeNotification"), object: micArr)
    }
    
    func onRTCCancelLine(_ nCode: Int32, withLivePeerId strLivePeerId: String!) {
        //游客取消连麦申请，或者连麦已满
        if nCode == 0 {
            micArr.enumerateObjects({ (object, index, stop) in
                let micModel = object as! ATRealMicModel
                if micModel.peerId == strLivePeerId {
                    micArr.removeObject(at: index)
                }
            })
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LineNumChangeNotification"), object: micArr)
        }
    }
    
    func onRTCLineClosed(_ nCode: Int32) {
        //RTC 服务关闭
    }
    
    func onRTCOpenVideoRender(_ strLivePeerId: String!, withRTCPubId strRTCPubId: String!, withUserId strUserId: String!, withUserData strUserData: String!) {
        //游客视频连麦接通
    }
    
    func onRTCCloseVideoRender(_ strLivePeerId: String!, withRTCPubId strRTCPubId: String!, withUserId strUserId: String!) {
        //游客视频连麦挂断
    }
    
    func onRTCOpenAudioLine(_ strLivePeerId: String!, withUserId strUserId: String!, withUserData strUserData: String!) {
        //游客音频连麦接通
        let dic = getDictionaryFromJSONString(jsonString: strUserData.removingPercentEncoding!)
        
        let aduioView: ATAudioView = ATAudioView.audioView()
        aduioView.initialize(name: dic["nickName"] as! String, peerId: strLivePeerId, isDisplay: true)
        aduioView.delegate = self
        
        audioArr.add(aduioView)
        layoutAudioView(hosterButton: localButton, containerView: containerView, landscape: Int32(liveInfo.isLiveLandscape))
    }
    
    func onRTCCloseAudioLine(_ strLivePeerId: String!, withUserId strUserId: String!) {
        //游客音频连麦挂断
        audioArr.enumerateObjects { (object, index, stop) in
            if object is ATAudioView {
                let audio : ATAudioView = object as! ATAudioView
                if audio.strPeerId == strLivePeerId {
                    audio.removeFromSuperview()
                    audioArr.removeObject(at: index)
                    layoutAudioView(hosterButton: localButton, containerView: containerView, landscape: Int32(liveInfo.isLiveLandscape))
                }
            }
        }
    }
    
    func onRTCAVStatus(_ strRTCPeerId: String!, withAudio bAudio: Bool, withVideo bVideo: Bool) {
        // 其他连麦者视频窗口的对音视频的操作
    }
    
    func onRTCViewChanged(_ videoView: UIView!, didChangeVideoSize size: CGSize) {
        //视频窗口大小改变
    }
    
    func onRTCAudioActive(_ strLivePeerId: String!, withUserId strUserId: String!, withShowTime nTime: Int32) {
        //RTC音频检测（自己没有回调）
        audioArr.enumerateObjects { (object, index, stop) in
            if object is ATAudioView {
                let audio : ATAudioView = object as! ATAudioView
                if audio.strPeerId == strLivePeerId {
                    audio.headButton.startAudioAnimation()
                }
            }
        }
    }
    
    func onRTCUserMessage(_ nType: Int32, withUserId strUserId: String!, withUserName strUserName: String!, withUserHeader strUserHeaderUrl: String!, withContent strContent: String!) {
        //收到消息回调
        renderer.receive(produceTextBarrage(message:strContent, direction: BarrageWalkDirection.L2R.rawValue))
    }
    
    func onRTCMemberListNotify(_ strServerId: String!, withRoomId strRoomId: String!, withAllMember nTotalMember: Int32) {
        //直播间实时在线人数变化通知
        onlineLabel.text = String(nTotalMember)
        
        listVc.anyrtcId = liveInfo.anyrtcId
        listVc.serverId = strServerId
        listVc.roomId = strRoomId
    }
}

