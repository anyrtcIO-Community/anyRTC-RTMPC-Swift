//
//  ATLivingEndController.swift
//  RTMPCDemo_Swift
//
//  Created by jh on 2018/4/16.
//  Copyright © 2018年 jh. All rights reserved.
//

import UIKit

class ATLivingEndController: UIViewController {

    @IBOutlet weak var headImageView: UIImageView!
    
    @IBOutlet weak var containerView: UIView!   //容器
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var liveTimeButton: UIButton!
    
    var userName: String!   //主播昵称
    
    var liveTime: NSInteger! //直播时长
    
    override func viewDidLoad() {
        super.viewDidLoad()
        liveTimeButton.titleLabel?.numberOfLines = 2
        liveTimeButton.titleLabel?.textAlignment = NSTextAlignment.center
        
        let minutes = String(format: "%02zd", liveTime/60)
        let seconds = String(format: "%02zd", liveTime%60)
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 15
        paragraph.alignment = NSTextAlignment.center
        let liveStr = minutes + " : " + seconds + "\n直播时长"
        
        let dic: NSDictionary = [NSAttributedStringKey.paragraphStyle:paragraph]
        let attributes:NSMutableAttributedString = NSMutableAttributedString(string: liveStr, attributes: dic as? [NSAttributedStringKey : Any])
        attributes.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.red], range: NSMakeRange(0, 7))
        liveTimeButton.setAttributedTitle(attributes, for: UIControlState.normal)
        
        for object in containerView.subviews {
            if object is UIButton {
                let button: UIButton = object as! UIButton
                button.layoutButtonWithEdgeInsetsStyle(style: EdgeInsetsStyle.Top, space: 10)
            }
        }
    }

    @IBAction func doSomethingEvents(_ sender: UIButton) {
        switch sender.tag {
        case 100:
            //QQ咨询
            let url = "mqqapi://card/show_pslcard?src_type=internal&version=1&uin=580477436&card_type=group&source=external"
            if UIApplication.shared.canOpenURL(NSURL(string: url)! as URL) {
                UIApplication.shared.openURL(NSURL(string: url)! as URL)
            }
            break
        case 101:
            self.navigationController?.popToRootViewController(animated: true)
            break
        case 102:
            //电话咨询
            UIApplication.shared.openURL(URL(string: "telprompt://021-65650071")!)
            break
        default:
            break
        }
    }
}
