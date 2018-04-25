//
//  ATRealTimeMicController.swift
//  RTMPCDemo_Swift
//
//  Created by jh on 2018/3/19.
//  Copyright © 2018年 jh. All rights reserved.
//

import UIKit

class ATRealTimeMicController: UIViewController,UITableViewDelegate,UITableViewDataSource,micResultDelegate{

    @IBOutlet weak var micTableView: UITableView!
    //空视图
    @IBOutlet weak var emptyView: UIView!
    
    var micArr: NSMutableArray!
    
    var mHosterKit: RTMPCHosterKit!
    
    var mHosterAudioKit: RTMPCHosterAudioKit!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        micTableView.tableFooterView = UIView()
        
        (micArr.count == 0) ? (emptyView.isHidden = false) : (emptyView.isHidden = true)
        
        //连麦列表
        NotificationCenter.default.addObserver(self, selector: #selector(ATRealTimeMicController.micRefresh(_:)), name: Notification.Name(rawValue: "LineNumChangeNotification"), object: nil)
    }
    
    @objc func micRefresh(_ noti:Notification) {
        micTableView.reloadData()
        (micArr.count == 0) ? (emptyView.isHidden = false) : (emptyView.isHidden = true)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return micArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ATRealMicCell = tableView.dequeueReusableCell(withIdentifier:"RTMPC_Mic_CellID", for: indexPath) as! ATRealMicCell
        cell.delegate = self
        cell.setupData(micArr[indexPath.row]as! ATRealMicModel)
        return cell
    }
    
    // MARK: - micResultDelegate
    func micResult(isAgree: Bool, peerId: String) {
        //移除已处理连麦者
        micArr.enumerateObjects { (object, index, stop) in
            let micModel = object as! ATRealMicModel
            if micModel.peerId == peerId {
                micArr.removeObject(at: index)
                micTableView.reloadData()
            }
        }
        
        if isAgree {//同意
            if mHosterKit != nil {
                mHosterKit.acceptRTCLine(peerId)
            }
            
            if mHosterAudioKit != nil {
                mHosterAudioKit.acceptRTCLine(peerId)
            }
            
        } else {
            if mHosterKit != nil {//拒绝
                mHosterKit.rejectRTCLine(peerId)
            }
            
            if mHosterAudioKit != nil {
                mHosterAudioKit.rejectRTCLine(peerId)
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
     // MARK: - Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let allTouches: NSSet = event!.allTouches! as NSSet
        let touch:UITouch  = allTouches.anyObject() as! UITouch
        let point: CGPoint = touch.location(in: view)
        
        let screenH = UIScreen.main.bounds.height
        
        
        if point.y <  screenH * 4/7 {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
