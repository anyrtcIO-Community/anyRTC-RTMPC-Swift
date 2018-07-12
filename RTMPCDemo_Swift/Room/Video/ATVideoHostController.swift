//
//  ATVideoHostController.swift
//  RTMPCDemo_Swift
//
//  Created by jh on 2018/3/8.
//  Copyright © 2018年 jh. All rights reserved.
//

import UIKit
import BarrageRenderer

class ATVideoHostController: ATBarrageViewController,RTMPCHosterRtmpDelegate,RTMPCHosterRtcDelegate,HangUpDelegate{
    
    //rtc状态
    @IBOutlet weak var rtcLabel: UILabel!
    //rtmp状态
    @IBOutlet weak var rtmpLabel: UILabel!
    //横竖var间距
    @IBOutlet weak var padding: NSLayoutConstraint!
    //房间名
    @IBOutlet weak var topicLabel: UILabel!
    //房间号
    @IBOutlet weak var roomIdLabel: UILabel!
    //在线人员
    @IBOutlet weak var onlineLabel: UILabel!
    //功能
    @IBOutlet weak var functionButton: UIButton!
    //在线人员
    @IBOutlet weak var listView: UIView!
    //显示弹幕
    @IBOutlet weak var barrageView: UIView!
    //容器
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var localView: UIView!
    //弹幕控制器
    @IBOutlet weak var barrageButton: UIButton!
    
    fileprivate var mHosterKit: RTMPCHosterKit!
    
    var liveInfo: LiveInfo!
    
    //菜单（竖屏）
    var menuVc: ATMenuViewController!
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

        setUpInitialization()
        if liveInfo.isLiveLandscape == 1 {
            orientationRotating(direction: UIInterfaceOrientation.landscapeLeft)
            functionButton.isHidden = true
        } else {
            padding.constant = -CGFloat(MAXFLOAT)
            functionButton.isHidden = false
            
            menuVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RTMPC_Video_Menu") as! ATMenuViewController
            menuVc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            menuVc.mHosterKit = mHosterKit
        }
    }
    
    //初始化RTMPC信息
    func setUpInitialization() {
        let option : RTMPCHosterOption = RTMPCHosterOption.default()
        option.cameraType = RTMPCCameraType.beauty
        
        if liveInfo.videoMode != "标清" {
            (liveInfo.videoMode == "顺畅") ? (option.videoMode = AnyRTCVideoQuality_Medium1) : (option.videoMode = AnyRTCVideoQuality_Height1)
        }
        
        let beautyButton : UIButton = view.viewWithTag(105) as! UIButton
        beautyButton.isSelected = true
        
        (liveInfo.isLiveLandscape == 1) ? (option.videoScreenOrientation = RTMPCScreenOrientationType.landscapeRightType):nil
        
        mHosterKit = RTMPCHosterKit(delegate:self, andOption: option)
        mHosterKit.rtc_delegate = self
        
        mHosterKit.setLocalVideoCapturer(localView)
        mHosterKit.startPushRtmpStream(liveInfo.push_url)
        
        videoArr.add(localView)
        
        //用户信息
        let userDic : NSDictionary = ["isHost": NSNumber(value:1),"userId": randomCharacter(length: 6),"nickName": liveInfo.userName]
        
        //直播信息
        let livingInfo : NSDictionary = ["rtmpUrl": liveInfo.pull_url,"hlsUrl": liveInfo.hls_url,"anyrtcId": liveInfo.anyrtcId,"liveTopic": liveInfo.anyrtcId,"isLiveLandscape": NSNumber(value: liveInfo.isLiveLandscape),"isAudioLive": NSNumber(value: 0),"hosterName": liveInfo.userName]
        
        //创建RTC连接
        mHosterKit .createRTCLine(liveInfo.anyrtcId, andUserId: "hosterUserId", andUserData: getJSONStringFromDictionary(dictionary: userDic), andLiveInfo: getJSONStringFromDictionary(dictionary: livingInfo))
        
        self.liveTime = NSInteger(NSDate().timeIntervalSince1970)
    }
    
    // MARK: - event  默认使用模板二
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
            vc.mHosterKit = mHosterKit
            self.present(vc, animated: true, completion: nil)
            
            break
        case 104:
            //镜像
            mHosterKit.setFontCameraMirrorEnable(!sender.isSelected)
            break
        case 105:
            //美颜
            sender.isSelected ? (mHosterKit.setCameraFilter(AnyCameraDeviceFilter_Beautiful)):(mHosterKit.setCameraFilter(AnyCameraDeviceFilter_Original))
            break
        case 106:
            //翻转摄像头
            mHosterKit.switchCamera()
            break
        case 107:
            //视频开关
            mHosterKit.setLocalVideoEnable(!sender.isSelected)
            break
        case 108:
            //音频开关
            mHosterKit.setLocalAudioEnable(!sender.isSelected)
            break
        case 109:
            //退出
            mHosterKit.clear()
            orientationRotating(direction: UIInterfaceOrientation.portrait)
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RTMPC_Video_End") as! ATLivingEndController
            vc.userName = self.liveInfo.userName
            vc.liveTime = NSInteger(NSDate().timeIntervalSince1970) - self.liveTime
            self.navigationController!.pushViewController(vc, animated: true)
            break
        case 110:
            //功能（竖屏）
            sender.isSelected = false
            self.present(self.menuVc, animated: true, completion: nil)
            break
        case 111:
            //弹幕
            barrageView.isHidden = sender.isSelected
            break
        default:
            print("error")
        }
    }
    
    // MARK: - HangUpDelegate
    func hangUpOperation(peerId: String) {//挂断连麦
        mHosterKit.hangupRTCLine(peerId)
        videoArr.enumerateObjects { (object, index, stop) in
            if object is ATVideoView {
                let video: ATVideoView = object as! ATVideoView
                if video.strPeerId == peerId {
                    videoArr.removeObject(at: index)
                    video.removeFromSuperview()
                    layoutVideoView(localView: localView, containerView: containerView, landscape: Int32(liveInfo.isLiveLandscape))
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
            mHosterKit.sendUserMessage(RTMPCMessageType(rawValue: 1), withUserName: liveInfo.userName, andUserHeader: "", andContent: textField.text)
            textField.resignFirstResponder()
            textField.text = ""
        }
        return true
    }
    
    // MARK: - RTMPCHosterRtmpDelegate
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
    
    // MARK: - RTMPCHosterRtcDelegate
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
        let dic = getDictionaryFromJSONString(jsonString: strUserData.removingPercentEncoding!)
        
        let videoView = ATVideoView.videoView()
        videoView.initialize(name: dic["nickName"] as! String, peerId: strLivePeerId, pubId: strRTCPubId, videoSize: CGSize.zero, isDisplay: true)
        videoView.delegate = self
        
        videoArr.add(videoView)
        layoutVideoView(localView: localView, containerView: containerView, landscape: Int32(liveInfo.isLiveLandscape))
        //设置连麦者视频窗口
        mHosterKit.setRTCVideoRender(strRTCPubId, andRender: videoView)
    }
    
    func onRTCCloseVideoRender(_ strLivePeerId: String!, withRTCPubId strRTCPubId: String!, withUserId strUserId: String!) {
        //游客视频连麦挂断
        videoArr.enumerateObjects { (object, index, stop) in
            if object is ATVideoView {
                let video : ATVideoView = object as! ATVideoView
                if video.strPubId == strRTCPubId {
                    video.removeFromSuperview()
                    videoArr.removeObject(at: index)
                    layoutVideoView(localView: localView, containerView: containerView, landscape: Int32(liveInfo.isLiveLandscape))
                }
            }
        }
    }
    
    func onRTCOpenAudioLine(_ strLivePeerId: String!, withUserId strUserId: String!, withUserData strUserData: String!) {
        //游客音频连麦接通
    }
    
    func onRTCCloseAudioLine(_ strLivePeerId: String!, withUserId strUserId: String!) {
        //游客音频连麦挂断
    }
    
    func onRTCAVStatus(_ strRTCPeerId: String!, withAudio bAudio: Bool, withVideo bVideo: Bool) {
        //其他连麦者视频窗口的对音视频的操作
    }
    
    func onRTCViewChanged(_ videoView: UIView!, didChangeVideoSize size: CGSize) {
        //视频窗口大小改变
        videoArr.enumerateObjects { (object, index, stop) in
            if object is ATVideoView {
                let video: ATVideoView = videoArr[index] as! ATVideoView
                if video == videoView.superview {
                    //刷新布局
                    video.videoSize = size
                    layoutVideoView(localView: localView, containerView: containerView, landscape: Int32(liveInfo.isLiveLandscape))
                }
            }
        }
    }
    
    func onRTCAudioActive(_ strLivePeerId: String!, withUserId strUserId: String!, withShowTime nTime: Int32) {
        // RTC音频检测
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
