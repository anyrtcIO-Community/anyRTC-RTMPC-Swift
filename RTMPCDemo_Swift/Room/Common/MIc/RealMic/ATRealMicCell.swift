//
//  ATRealMicCell.swift
//  RTMPCDemo_Swift
//
//  Created by jh on 2018/3/20.
//  Copyright © 2018年 jh. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol micResultDelegate {
    
    func micResult(isAgree: Bool, peerId: String)
}

class ATRealMicCell: UITableViewCell {

    @IBOutlet weak var rejectButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var delegate: micResultDelegate?
    
    var realMicModel = ATRealMicModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    public func setupData(_ realMicModel: ATRealMicModel){
        
         //- realMicModel.userData "{%22isHost%22:0,%22userId%22:%224753646609%22,%22nickName%22:%22guest_%20Mark%22,%22headUrl%22:%22%22}"
        
        //URL解码-->网页
        let decodedString = realMicModel.userData.removingPercentEncoding
        
        let dic = getDictionaryFromJSONString(jsonString: decodedString!)
        
        nameLabel.text = dic["nickName"] as! String + " 申请连麦"
        
        self.realMicModel = realMicModel
    }
    
    @IBAction func micResultsAction(_ sender: UIButton) {
        var result = false
        (sender.tag == 50) ? (result = true) : nil
        self.delegate!.micResult(isAgree: result, peerId: self.realMicModel.peerId)
    }
    
}
