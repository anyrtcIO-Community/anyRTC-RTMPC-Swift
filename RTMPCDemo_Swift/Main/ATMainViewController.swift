//
//  ATMainViewController.swift
//  RTMPCDemo_Swift
//
//  Created by jh on 2018/1/23.
//  Copyright © 2018年 jh. All rights reserved.
//首页

import UIKit

class ATMainViewController: UIViewController {
    
    @IBOutlet weak var audienceButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.audienceButton.layer.borderColor = THEME_COLOR.cgColor
    }
    
    @IBAction func doSomethingEvent(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        UIApplication.shared.openURL(URL(string: "telprompt://021-65650071")!)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            sender.isUserInteractionEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
