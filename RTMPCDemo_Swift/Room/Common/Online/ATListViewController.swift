//
//  ATListViewController.swift
//  RTMPCDemo_Swift
//
//  Created by jh on 2018/3/14.
//  Copyright © 2018年 jh. All rights reserved.
//

import UIKit
import SwiftyJSON
import MJExtension

class ATListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    var tableView: UITableView!
    
    var serverId: String!
    
    var roomId: String!
    
    var anyrtcId: String!
    //默认1开始
    var page: Int = 1
    
    var listArr = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customNavigationBar(title: "在线人员")
        
        tableView = UITableView(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64), style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.rowHeight = 80.0
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "RTMPC_List_CellID")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getListData()
    }
    
    /*
     获取在线人员列表
     
     responseDict 数据格式：
     {
     CMD = MemberList;
     MemSize = 1;
     NickName =     (
     hosterUserId
     );
     Total = 1;
     UserData =     (
     "{\n  \"headUrl\" : \"http:\\/\\/f.rtmpc.cn\\/p\\/g\\/jmaRia\",\n  \"nickName\" : \"hp\",\n  \"userId\" : \"IFh8fO\",\n  \"isHost\" : 1\n}"
     );
     UserId =     (
     hosterUserId
     );
     }
     */
    func getListData(){
        RTMPCHttpKit.shead().getLiveMemberList(serverId, withRoomId: roomId, withAnyRTCId: anyrtcId, withPage: 0) { (responseDict : Any, error,code) in
            if code == 200 {
                let dataJson = JSON(responseDict)["UserData"].rawValue
                let arr = ATListModel.mj_objectArray(withKeyValuesArray: dataJson) as Array
                
                self.listArr.removeAllObjects()
                self.listArr.addObjects(from: arr)
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func listBack(){
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RTMPC_List_CellID", for: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let listModel : ATListModel = listArr[indexPath.row] as! ATListModel
        cell.imageView?.image = UIImage(named: "headurl_small")
        cell.textLabel?.text = listModel.nickName
        return cell
    }
}

