//
//  ATBarrageViewController.swift
//  RTMPCDemo_Swift
//
//  Created by jh on 2018/4/10.
//  Copyright © 2018年 jh. All rights reserved.
//

import UIKit
import BarrageRenderer

class ATBarrageViewController: UIViewController,UITextFieldDelegate{
    
    var messageTextField: UITextField!
    //视频窗口
    var videoArr = NSMutableArray()
    //音频窗口
    var audioArr = NSMutableArray()
    //在线人员列表
    var listVc: ATListViewController!
    //弹幕渲染器
    var renderer : BarrageRenderer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listVc = ATListViewController()
        
        renderer = BarrageRenderer.init()
        renderer.canvasMargin = UIEdgeInsetsMake(30, 30, 30, 30)
        renderer.start()
        
        observeKeyBoard()
    }
    
    //监听键盘
    func observeKeyBoard() {
        
        //隐藏键盘
        let hideKeyBoardTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoardTapClick))
        view.addGestureRecognizer(hideKeyBoardTap)
        
        
        messageTextField = UITextField(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 49))
        messageTextField.borderStyle = UITextBorderStyle.none
        messageTextField.backgroundColor = UIColor.white
        messageTextField.placeholder = "说点什么..."
        messageTextField.returnKeyType = UIReturnKeyType.send
        messageTextField.delegate = self
        view.addSubview(messageTextField)
        NotificationCenter.default.addObserver(self,selector:#selector(keyboardChange(notify:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,selector:#selector(keyboardChange(notify:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func hideKeyBoardTapClick() {
        messageTextField.resignFirstResponder()
    }
    
    @objc func keyboardChange(notify:NSNotification){
        //时间
        let duration : Double = notify.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        if notify.name == NSNotification.Name.UIKeyboardWillShow {
            //键盘高度
            let keyboardY : CGFloat = (notify.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size.height
            let high = UIScreen.main.bounds.size.height - keyboardY - 44
            
            UIView.animate(withDuration: duration) {
                self.messageTextField.frame = CGRect(x: 0, y: high, width: UIScreen.main.bounds.size.width, height: 44)
                self.view.layoutIfNeeded()
            }
        } else if notify.name == NSNotification.Name.UIKeyboardWillHide {
            
            UIView.animate(withDuration: duration, animations: {
                self.messageTextField.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 44)
                self.view.layoutIfNeeded()
            })
        }
    }
    
    deinit {
        if renderer != nil {
            renderer.stop()
            renderer.view.removeFromSuperview()
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    //在线人员
    @objc func getMemberList() {
        if listVc.anyrtcId != nil && listVc.serverId != nil && listVc.roomId != nil{
            self.present(listVc, animated: true, completion: nil)
        }
    }
    
    //MARK: - 视频布局刷新
    
    func layoutVideoView(localView: UIView, containerView: UIView, landscape: Int32) {
        //当前video的宽高
        var itemWidth: CGFloat = 0
        var itemHeight: CGFloat = 0
        
        containerView.snp.remakeConstraints({ (make) in
            make.edges.equalTo(view)
        })
        
        switch videoArr.count {
        case 1:
            localView.snp.remakeConstraints({ (make) in
                make.edges.equalTo(containerView)
            })
            break
        case 2:
            
            if landscape == 0 {//竖屏
                
                itemWidth = UIScreen.main.bounds.size.width/2
                itemHeight = itemWidth * 16/9
                
            } else { //横屏
                itemWidth = UIScreen.main.bounds.size.width/2
                itemHeight = itemWidth * 3/4
            }
            
            containerView.snp.remakeConstraints({ (make) in
                make.width.equalTo(view)
                make.height.equalTo(itemHeight)
                make.center.equalTo(view)
            })
            
            makeVideoEqualWidthViews(views: videoArr, containerView: containerView, spacing: 0, padding: 0)
            
            break
        case 3,4:
            itemWidth = UIScreen.main.bounds.size.width/2
            itemHeight = UIScreen.main.bounds.size.height/2
            
            makeVideoViews(views: videoArr, containerView: containerView, itemWidth:itemWidth, itemHeight:itemHeight , warpCount: 2)
            break
        default: break
        }
        
        //根据分辨率显示,无压缩填充
        makeResolution(videoArr: videoArr, itemWidth: itemWidth, itemHeight: itemHeight)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            for subView: UIView in localView.subviews {
                subView.frame = localView.frame;
            }
        }
    }
    
    
    //MARK: - 音频布局刷新
    
    func layoutAudioView(hosterButton: UIButton, containerView: UIView, landscape: Int32) {
        
        if audioArr.count == 0 {
            hosterButton.snp.remakeConstraints { (make) in
                make.width.height.equalTo(90)
                make.center.equalTo(view)
            }
            return
        }
        
        //子视图
        var itemWidth: CGFloat!
        var itemHeight: CGFloat!
        
        if landscape == 0 {
            //竖屏
            itemWidth = UIScreen.main.bounds.width/3
            itemHeight = itemWidth * 16/9
            containerView.snp.remakeConstraints({ (make) in
                make.width.equalTo(CGFloat(audioArr.count) * itemWidth)
                make.height.equalTo(itemHeight)
                make.centerX.equalTo(view.snp.centerX)
                make.centerY.equalTo(view.snp.centerY).offset(100)
            })
            
            hosterButton.snp.remakeConstraints { (make) in
                make.width.height.equalTo(90)
                make.centerX.equalTo(view.snp.centerX)
                make.bottom.equalTo(containerView.snp.top).offset(-80)
            }
            
        } else {
            //横屏
            itemWidth = UIScreen.main.bounds.height/3
            itemHeight = itemWidth * 16/9
            
            containerView.snp.remakeConstraints({ (make) in
                make.width.equalTo(CGFloat(audioArr.count) * itemWidth)
                make.height.equalTo(itemHeight)
                make.centerY.equalTo(view.snp.centerY)
                make.centerX.equalTo(view.snp.centerX).offset(80)
            })
            
            hosterButton.snp.remakeConstraints { (make) in
                make.width.height.equalTo(90)
                make.centerY.equalTo(view.snp.centerY)
                make.right.equalTo(containerView.snp.left).offset(-60)
            }
        }
        makeVideoEqualWidthViews(views: audioArr, containerView: containerView, spacing: 0, padding: 0)
    }
}

