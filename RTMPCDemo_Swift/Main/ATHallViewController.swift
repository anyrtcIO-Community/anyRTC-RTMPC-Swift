//
//  ATHallViewController.swift
//  RTMPCDemo_Swift
//
//  Created by jh on 2018/1/24.
//  Copyright © 2018年 jh. All rights reserved.
//

import UIKit
import SwiftyJSON
import MJExtension
import XHToastSwift

class ATHallCell: UITableViewCell {
    
    @IBOutlet weak var audioImageView: UIImageView! //标识音频、视频
    
    @IBOutlet weak var topicLabel: UILabel!

    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var roomIdLabel: UILabel!
    
    @IBOutlet weak var onlineLabel: UILabel!    //实时在线人数
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func setupData(_ listModel:ATHallModel){
        listModel.isAudioLive ? (audioImageView.image = UIImage(named:"voice_image")) : (audioImageView.image = UIImage(named:"video_image"))
        
        topicLabel.text = listModel.liveTopic
        
        userNameLabel.attributedText = getAttributedString(text: " " + listModel.hosterName, image: UIImage(named: "people")!, index: 0)
        
        roomIdLabel.attributedText = getAttributedString(text: " " + listModel.anyrtcId, image: UIImage(named: "ID")!, index: 0)
    }
}

class ATHallViewController: UITableViewController {

    var refreshControls: UIRefreshControl?
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var dataSource = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = randomCharacter(length: 3)
        
        let footerLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 240))
        footerLabel.textAlignment = NSTextAlignment.center
        footerLabel.text = "————  已经没有其他直播间  ————"
        footerLabel.textColor = UIColor.lightGray
        
        tableView.tableFooterView = footerLabel
        tableView.tableHeaderView = self.topView
        
        let HEADER_HEIGHT = UIScreen.main.bounds.size.width * 9/16
        tableView.tableHeaderView?.frame.size = CGSize(width: tableView.frame.width, height: CGFloat(HEADER_HEIGHT))
        
        let backButton: UIButton = view.viewWithTag(50) as! UIButton
        backButton.addTarget(self, action: #selector(addTargetEvent), for:.touchUpInside)
        
        refreshControls = UIRefreshControl()
        tableView.addSubview(refreshControls!)
        refreshControls?.addTarget(self, action: #selector(getHallData), for: .valueChanged)
        getHallData()
    }
    
    @objc func addTargetEvent() {
        
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0)
    }
    
    @objc func getHallData() {
        RTMPCHttpKit .shead().getLivingList { (responseDict : Any, error, code) in
            let responseDic = responseDict as! [NSObject : AnyObject]
            if JSON(responseDic)["ErrCode"] == 203{
                XHToast.showCenterWithText("配置开发者信息错误")
            } else {
                let dataJson = JSON(responseDic)["LiveList"].rawValue
                let arr = ATHallModel.mj_objectArray(withKeyValuesArray: dataJson) as Array
                let arrs:[ATHallModel] = arr as! [ATHallModel]
                
                self.dataSource.removeAllObjects()
                self.dataSource.addObjects(from: arrs)
                self.tableView.reloadData()
            }
            self.refreshControls?.endRefreshing()
        }
    }
    
    // MARK: - 获取推拉流地址
    func getAppVdnUrl(hallModel : ATHallModel) {
        
        let random : String = String((arc4random() % 1000000))
        let signature : String = appID + String(format: "%.f", NSDate().timeIntervalSince1970) + "000" + appvtoken + random
        
        let parameters : NSDictionary = ["appid" : appID, "stream" : hallModel.anyrtcId, "random" : random, "signature" : md5String(str: signature), "timestamp" : String(format: "%.f", NSDate().timeIntervalSince1970) + "000", "appBundleIdPkgName" : "com.dync.rtmpc.anyrtc"]
        
        ATNetWorkHepler.getResponseData(App_VdnUrl, parameters: parameters as? [String : AnyObject], success: { (result) in
            if result["code"] == 200 {
                hallModel.rtmpUrl = result["pull_url"].string!
                hallModel.hlsUrl = result["hls_url"].string!
                
                if hallModel.isAudioLive {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RTMPC_Audio_Audience") as! ATAudioAudienceController
                    vc.hallModel = hallModel
                    vc.userName = self.nameLabel.text
                    self.navigationController!.pushViewController(vc, animated: true)
                } else {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RTMPC_Video_Audience") as! ATVideoAudienceController
                    vc.hallModel = hallModel
                    vc.userName = self.nameLabel.text
                    self.navigationController!.pushViewController(vc, animated: true)
                }
            }
            
        }) { (error) in
            print(error)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let hallCell:ATHallCell = tableView.dequeueReusableCell(withIdentifier:"RTMPC_HallCellID", for: indexPath) as! ATHallCell
        hallCell.setupData(dataSource[indexPath.row] as! ATHallModel)
        // Configure the cell...

        return hallCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let hallModel : ATHallModel = dataSource[indexPath.row] as! ATHallModel;
        //获取拉流地址
        getAppVdnUrl(hallModel: hallModel)
    }
}
