//
//  ATStartViewController.swift
//  RTMPCDemo_Swift
//
//  Created by jh on 2018/1/24.
//  Copyright © 2018年 jh. All rights reserved.
//我是主播

import UIKit
import XHToastSwift

class ATStartViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource{
    
    @IBOutlet weak var headImageView: UIImageView!   //头像

    @IBOutlet weak var nameLabel: UILabel!         //随机名字

    @IBOutlet weak var topicTextField: UITextField! //直播间名

    @IBOutlet weak var goBackButton: UIButton!     //返回
 
    @IBOutlet weak var typeButton: UIButton!       //直播类型

    @IBOutlet weak var modeButton: UIButton!       //直播质量

    @IBOutlet weak var directionButton: UIButton!  //直播方向

    @IBOutlet weak var pickerView: UIPickerView!    //选择器
    
    @IBOutlet weak var bottomY: NSLayoutConstraint!
    
    var pickArr: NSArray!
    
    var seletedIndex: NSInteger!
    
    var liveInfo : LiveInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        goBackButton.layer.borderColor = UIColor.lightGray.cgColor
        nameLabel.text = randomCharacter(length: 3)
        topicTextField.text = randomCharacter(length: 6)
        seletedIndex = 0
        pickerView.delegate = self
        pickerView.dataSource = self
        pickArr = [];
        liveInfo = LiveInfo()
        liveInfo.userName = nameLabel.text!
        //随机6位数字
        liveInfo.anyrtcId = String((arc4random() % 1000000))
        //默认横屏
        liveInfo.isLiveLandscape = 1
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideControl))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func hideControl() -> Void {
        self.bottomY.constant = -200
    }
    
    // MARK: - UIPickerViewDataSource
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickArr.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickArr.object(at: row) as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedStr: String  = pickArr.object(at: row) as! String
        
        switch seletedIndex {
        case 100:
            typeButton.setTitle(selectedStr, for: UIControlState.normal)
            if selectedStr == "音频直播" {
                modeButton.setTitle("48K", for: UIControlState.normal)
            }
            
            if selectedStr == "视频直播" && modeButton.titleLabel?.text == "48K"{
                modeButton.setTitle("顺畅", for: UIControlState.normal)
                liveInfo.videoMode = "顺畅"
            }
            break
        case 101:
            modeButton.setTitle(selectedStr, for: UIControlState.normal)
            liveInfo.videoMode = selectedStr
            break
        case 102:
            directionButton.setTitle(selectedStr, for: UIControlState.normal)
            break
        default:
            break
        }
    }
    
    @IBAction func doSomethingEvents(_ sender: UIButton) {
        if seletedIndex == sender.tag {
            bottomY.constant = -200.0
            seletedIndex = 0
            return;
        }
        bottomY.constant = 0.0;
        seletedIndex = sender.tag
        
        switch sender.tag {
        case 100:
            pickArr = ["视频直播","音频直播"]
            pickerView.reloadAllComponents()
            break
        case 101:
            
            if typeButton.titleLabel?.text == "音频直播"{
                pickArr = ["48K"]
                pickerView.reloadAllComponents()
                return
            }
            
            pickArr = ["顺畅","标清","高清"]
            pickerView.reloadAllComponents()
            break
        case 102:
            pickArr = ["横屏直播","竖屏直播"]
            pickerView.reloadAllComponents()
            break
        case 103:
            bottomY.constant = -200
            liveInfo.liveTopic = topicTextField.text!
            getAppVdnUrl()
            break
        case 104:
            self.navigationController?.popToRootViewController(animated: true)
            break
        default:
            break
        }
        
        pickArr.enumerateObjects { (object, index, stop) in
            let title: String = object as! String
            if sender.titleLabel?.text == title {
                pickerView.selectRow(index, inComponent: 0, animated: true)
            }
        }
    }
    
    // MARK: - 获取推拉流地址
    func getAppVdnUrl() {
        
        let random : String = String((arc4random() % 1000000))
        let signature : String = appID + String(format: "%.f", NSDate().timeIntervalSince1970) + "000" + appvtoken + random
        
        let parameters : NSDictionary = ["appid" : appID, "stream" : liveInfo.anyrtcId, "random" : random, "signature" : md5String(str: signature), "timestamp" : String(format: "%.f", NSDate().timeIntervalSince1970) + "000", "appBundleIdPkgName" : "com.dync.rtmpc.anyrtc"]
        
        ATNetWorkHepler.getResponseData(App_VdnUrl, parameters: parameters as? [String : AnyObject], success: { (result) in
            if result["code"] == 200 {
                self.liveInfo.push_url = result["push_url"].string!
                self.liveInfo.pull_url = result["pull_url"].string!
                self.liveInfo.hls_url = result["hls_url"].string!
                self.startLiving()
            } else {
               XHToast.showCenterWithText("配置开发者信息错误")
            }
        }) { (error) in
            print(error)
        }
    }
    
    //开始直播
    func startLiving() {
        
        (directionButton.titleLabel?.text == "横屏直播") ? (self.liveInfo.isLiveLandscape = 1) : (self.liveInfo.isLiveLandscape = 0)
        if typeButton.titleLabel?.text == "视频直播" {
            
            let vc : ATVideoHostController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RTMPC_Video_Host") as! ATVideoHostController
            vc.liveInfo = liveInfo
            self.navigationController!.pushViewController(vc, animated: true)
        } else {
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RTMPC_Audio_Host") as! ATAudioHostController
            vc.liveInfo = liveInfo
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
