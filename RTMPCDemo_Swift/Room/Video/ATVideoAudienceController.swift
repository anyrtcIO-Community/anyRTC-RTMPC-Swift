//
//  ATVideoAudienceController.swift
//  RTMPCDemo_Swift
//
//  Created by jh on 2018/3/8.
//  Copyright © 2018年 jh. All rights reserved.
//
 
import UIKit
import BarrageRenderer
import XHToastSwift

class ATVideoAudienceController: ATBarrageViewController,RTMPCGuestRtmpDelegate,RTMPCGuestRtcDelegate,HangUpDelegate{
    
    //rtc状态
    @IBOutlet weak var rtcLabel: UILabel!
    //rtmp状态
    @IBOutlet weak var rtmpLabel: UILabel!
    //容器
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var localView: UIView!
    //在线人员
    @IBOutlet weak var listView: UIView!
    //弹幕渲染
    @IBOutlet weak var barrageView: UIView!
    //房间名
    @IBOutlet weak var topicLabel: UILabel!
    //房间号
    @IBOutlet weak var roomIdLabel: UILabel!
    //在线人员
    @IBOutlet weak var onlineLabel: UILabel!
    //连麦
    @IBOutlet weak var applyButton: UIButton!
    //弹幕控制器
    @IBOutlet weak var barrageButton: UIButton!
    //连麦显示音视频
    @IBOutlet weak var padding: NSLayoutConstraint!
    
    fileprivate var gestKit: RTMPCGuestKit!
    
    var userName: String!
    
    var hallModel: ATHallModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        topicLabel.text = hallModel.liveTopic
        roomIdLabel.text = "房间id：" + hallModel.anyrtcId
        
        padding.constant = -CGFloat(MAXFLOAT)
        
        //获取在线人员列表
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(getMemberList))
        listView.addGestureRecognizer(tap)
        barrageView.addSubview(renderer.view)

        itializationGuestKit()
        if hallModel.isLiveLandscape == 1{
            // 强制横屏
            orientationRotating(direction: UIInterfaceOrientation.landscapeLeft)
        }
    }
    
    func itializationGuestKit() {
        //配置信息
        let option : RTMPCGuestOption = RTMPCGuestOption.default()
        if hallModel.isLiveLandscape == 1 {
            //与主播端保持一致
            option.videoScreenOrientation = .landscapeRightType;
        }
        
        //实例化游客端对象
        gestKit = RTMPCGuestKit(delegate: self as RTMPCGuestRtmpDelegate, andOption: option)
        //rtc代理
        gestKit.rtc_delegate = self
        
        //拉流地址
        let pullStr : String = hallModel.rtmpUrl
        
        //开始拉流
        gestKit.startRtmpPlay(pullStr, andRender: localView)
        videoArr.add(localView)
        
        gestKit.rtc_delegate = self
        //用户信息
        let userDic : NSDictionary = ["nickName": userName,"headUrl": ""]
        
        gestKit.joinRTCLine(hallModel.anyrtcId, andUserID:randomCharacter(length: 6), andUserData: getJSONStringFromDictionary(dictionary: userDic))
    }
    
    @IBAction func doSomethingEvent(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        switch sender.tag {
        case 100:
            //申请连麦
            if sender.isSelected {
                gestKit.applyRTCLine() ? (sender.backgroundColor = UIColor.red): (sender.isSelected = false)
            } else {
                gestKit.hangupRTCLine()
                sender.backgroundColor = UIColor.blue
                applyButton.setTitle("申请连麦", for: UIControlState.normal)
                videoArr.enumerateObjects({ (object, index, stop) in
                    if object is ATVideoView {
                        let localVideo: ATVideoView = object as! ATVideoView
                        videoArr.removeObject(at: index)
                        localVideo.removeFromSuperview()
                        padding.constant = -CGFloat(MAXFLOAT)
                    }
                })
                layoutVideoView(localView: localView, containerView: containerView, landscape: Int32(hallModel.isLiveLandscape))
            }
            break
        case 101:
            //消息
            messageTextField.becomeFirstResponder()
            break
        case 102:
            //切换摄像头
            gestKit.switchCamera()
            break
        case 103:
            //视频
            gestKit.setLocalVideoEnable(!sender.isSelected)
            break
        case 104:
            //音频
            gestKit.setLocalAudioEnable(!sender.isSelected)
            break
        case 105:
            //退出
            gestKit.clear()
            orientationRotating(direction: UIInterfaceOrientation.portrait)
            
            navigationController?.popViewController(animated: true)
            break
        case 106:
            //弹幕
            barrageView.isHidden = sender.isSelected
            break
        default:
            break
        }
    }
    
    // MARK: - HangUpDelegate
    func hangUpOperation(peerId: String) {//挂断连麦
        gestKit.hangupRTCLine()
        videoArr.enumerateObjects { (object, index, stop) in
            if object is ATVideoView {
                let video: ATVideoView = object as! ATVideoView
                videoArr.removeObject(at: index)
                video.removeFromSuperview()
            }
        }
        layoutVideoView(localView: localView, containerView: containerView, landscape: Int32(hallModel.isLiveLandscape))
        applyButton.isSelected = false
        applyButton.setTitle("申请连麦", for: UIControlState.normal)
        applyButton.backgroundColor = UIColor.blue
        padding.constant = -CGFloat(MAXFLOAT)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != nil {
            renderer.receive(produceTextBarrage(message:textField.text!, direction: BarrageWalkDirection.L2R.rawValue))
            //主播自己发送弹幕，打开弹幕显示
            barrageView.isHidden = false
            //barrageButton.isSelected = false
            
            //发送弹幕
            gestKit.sendUserMessage(RTMPCMessageType(rawValue: 1), withUserName: userName, andUserHeader: "", andContent: textField.text)
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
            padding.constant = 10
            applyButton.setTitle("挂断", for: UIControlState.normal)
            applyButton.backgroundColor = UIColor.red
            
            let video: ATVideoView = ATVideoView.videoView()
            video.initialize(name: userName, peerId: video_MySelf, pubId: video_MySelf, videoSize: CGSize(width: 4.0, height: 3.0), isDisplay: true)
            video.delegate = self
            view.addSubview(video)
            videoArr.add(video)
            gestKit.setLocalVideoCapturer(video.localView)
            layoutVideoView(localView: localView, containerView: containerView, landscape: Int32(hallModel.isLiveLandscape))
        } else {
            applyButton.isSelected = false
            applyButton.backgroundColor = UIColor.blue
            applyButton.setTitle("申请连麦", for: UIControlState.normal)
        }
    }
    
    func onRTCHangupLine() {
        //主播挂断游客连麦
        videoArr.enumerateObjects { (object, index, stop) in
            if object is ATVideoView {
                let myVideo: ATVideoView = object as! ATVideoView
                videoArr.removeObject(at: index)
                myVideo.removeFromSuperview()
            }
        }
        applyButton.isSelected = false
        applyButton.setTitle("申请连麦", for: UIControlState.normal)
        applyButton.backgroundColor = UIColor.blue
        padding.constant = -CGFloat(MAXFLOAT)
        layoutVideoView(localView: localView, containerView: containerView, landscape: Int32(hallModel.isLiveLandscape))
    }
    
    func onRTCLineLeave(_ nCode: Int32) {
        //断开RTC服务连接
        if nCode == 0 {
            XHToast.showCenterWithText("直播已结束")
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
                self.gestKit.clear()
                //销毁
                self.orientationRotating(direction: UIInterfaceOrientation.portrait)
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    func onRTCOpenVideoRender(_ strLivePeerId: String!, withRTCPubId strRTCPubId: String!, withUserId strUserId: String!, withUserData strUserData: String!) {
        //其他游客视频连麦接通
        let dic = getDictionaryFromJSONString(jsonString: strUserData.removingPercentEncoding!)
        
        let videoView = ATVideoView.videoView()
        videoView.initialize(name: dic["nickName"] as! String, peerId: strLivePeerId, pubId: strRTCPubId, videoSize: CGSize.zero, isDisplay: false)
        videoView.delegate = self
        
        videoArr.add(videoView)
        //设置连麦者视频窗口
        gestKit.setRTCVideoRender(strRTCPubId, andRender: videoView.localView)
    }
    
    func onRTCCloseVideoRender(_ strLivePeerId: String!, withRTCPubId strRTCPubId: String!, withUserId strUserId: String!) {
        //其他游客视频连麦挂断
        videoArr.enumerateObjects { (object, index, stop) in
            if object is ATVideoView {
                let video : ATVideoView = object as! ATVideoView
                if video.strPubId == strRTCPubId {
                    video.removeFromSuperview()
                    videoArr.removeObject(at: index)
                    layoutVideoView(localView: localView, containerView: containerView, landscape: Int32(hallModel.isLiveLandscape))
                }
            }
        }
    }
    
    func onRTCOpenAudioLine(_ strLivePeerId: String!, withUserId strUserId: String!, withUserData strUserData: String!) {
        //其他游客音频连麦接通
    }
    
    func onRTCCloseAudioLine(_ strLivePeerId: String!, withUserId strUserId: String!) {
        //其他游客连麦音频挂断
    }
    
    func onRTCAudioActive(_ strLivePeerId: String!, withUserId strUserId: String!, withShowTime nTime: Int32) {
        // RTC音频检测
    }
    
    func onRTCAVStatus(_ strRTCPeerId: String!, withAudio bAudio: Bool, withVideo bVideo: Bool) {
        //其他连麦者或主播视频窗口的对音视频的操作
    }
    
    func onRTCViewChanged(_ videoView: UIView!, didChangeVideoSize size: CGSize) {
        //视频窗口大小改变
        videoArr.enumerateObjects { (object, index, stop) in
            if object is ATVideoView {
                let video: ATVideoView = videoArr[index] as! ATVideoView
                if video == videoView.superview {
                    //刷新布局
                    video.videoSize = size
                }
            }
        }
        layoutVideoView(localView: localView, containerView: containerView, landscape: Int32(hallModel.isLiveLandscape))
    }
    
    func onRTCUserMessage(_ nType: Int32, withUserId strUserId: String!, withUserName strUserName: String!, withUserHeader strUserHeaderUrl: String!, withContent strContent: String!) {
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

