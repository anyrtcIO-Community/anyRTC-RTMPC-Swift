//
//  ATExtension.swift
//  RTMPCDemo_Swift
//
//  Created by jh on 2018/3/29.
//  Copyright © 2018年 jh. All rights reserved.
//

import UIKit
import SnapKit
import BarrageRenderer

/*********账号信息***********/

public let developerID = "XXX"
public let token = "XXX"
public let key = "XXX"
public let appID = "XXX"
public let appvtoken = "XXX"

//主题色
public let THEME_COLOR=UIColor(red: 20/255.0, green: 91/255.0, blue: 238/255.0, alpha: 1.0)

public let video_MySelf = "Video_MySelf"


extension NSObject {
    
    //RGB转换
    func RGB(r:CGFloat,g:CGFloat,b:CGFloat) ->UIColor{
        //
        return UIColor(red: r/225.0, green: g/225.0, blue: b/225.0, alpha: 1.0)
    }
    
    func randomCharacter(length : NSInteger) ->String {
        var randomStr = ""
        for _ in 1 ... length{
            let num = 65 + arc4random()%25 //随机6位大写字母
            let randomCharacter = Character(UnicodeScalar(num)!)
            randomStr.append(randomCharacter)
        }
        return randomStr
    }
    
    //md5加密
    func md5String(str:String) -> String{
        let cStr = str.cString(using: String.Encoding.utf8);
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(cStr!,(CC_LONG)(strlen(cStr!)), buffer)
        let md5String = NSMutableString();
        for i in 0 ..< 16{
            md5String.appendFormat("%02x", buffer[i])
        }
        free(buffer)
        return md5String as String
    }
    
    //json转字典
    func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        
        let jsonData:Data = jsonString.data(using: .utf8)!
        
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }
    
    //字典转json
    func getJSONStringFromDictionary(dictionary:NSDictionary) -> String {
        if (!JSONSerialization.isValidJSONObject(dictionary)) {
            print("无法解析出JSONString")
            return ""
        }
        let data : NSData! = try? JSONSerialization.data(withJSONObject: dictionary, options: []) as NSData!
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
    }
    
    //富文本
    func getAttributedString(text: String, image: UIImage, index: NSInteger) -> NSMutableAttributedString {
        
        if text.isEmpty {
            return NSMutableAttributedString()
        }
        
        let attri: NSMutableAttributedString = NSMutableAttributedString(string: text)
        
        let attch: NSTextAttachment = NSTextAttachment()
        attch.image = image
        attch.bounds = CGRect(x: 0, y: -5, width: 15, height: 15)
        
        let attrString: NSAttributedString = NSAttributedString(attachment: attch)
        attri.insert(attrString, at: index)
        return attri
    }
    
    //MARK: - 弹幕转换
    func produceTextBarrage(message: String,direction: UInt) -> BarrageDescriptor {
        let descriptor:BarrageDescriptor = BarrageDescriptor()
        descriptor.spriteName = NSStringFromClass(BarrageWalkTextSprite.self)
        descriptor.params["text"] = message
        descriptor.params["textColor"] = UIColor(red: CGFloat(arc4random()%255) / 255, green: CGFloat(arc4random()%255) / 255, blue: CGFloat(arc4random()%255) / 255, alpha: 1)
        descriptor.params["speed"] = Int(arc4random()%100) + 80
        descriptor.params["direction"] = direction
        return descriptor
    }
}

extension UIViewController {
    
    //MARK: - 自定义bar
    func customNavigationBar(title: String) {
        let navBar: UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 64))
        navBar.backgroundColor = RGB(r: 220, g: 220, b: 220)
        
        let lable: UILabel = UILabel()
        lable.text = title
        lable.tintColor = UIColor.black
        lable.sizeToFit()
        lable.center = navBar.center
        navBar.addSubview(lable)
        self.view.addSubview(navBar)
        
        let backButton = UIButton (type: UIButtonType.custom)
        backButton.frame = CGRect(x: 10, y: 20, width: 44, height: 30)
        backButton.setImage(UIImage(named:"return_image"), for: UIControlState.normal)
        backButton.addTarget(self, action: #selector(backButtonClick), for: UIControlEvents.touchUpInside)
        self.view.addSubview(backButton)
    }
    
    @objc func backButtonClick(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - 横屏  UIInterfaceOrientation.landscapeLeft    竖屏：UIInterfaceOrientation.portrait
    func orientationRotating(direction: UIInterfaceOrientation) {
        
        UIDevice.current.setValue(UIInterfaceOrientation.unknown.rawValue, forKey: "orientation")
        
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        (direction == UIInterfaceOrientation.landscapeLeft) ? (appDelegate.allowRotation = true) : (appDelegate.allowRotation = false)
        UIDevice.current.setValue(direction.rawValue, forKey: "orientation")
    }
    
    //MARK: - 布局
    
    /**
     将若干view等宽布局于容器containerView中(横向排列)
     @param views 子视图数组
     @param containerView 容器
     @param spacing 两边间距
     @param padding 相邻两个间距
     */
    func makeVideoEqualWidthViews(views: NSArray, containerView: UIView ,spacing: CGFloat, padding: CGFloat) {
        var lastView: UIView!
        views.enumerateObjects { (object, index, stop) in
            let video = object as! UIView
            containerView.insertSubview(video, at: 0)
            makeAllControlTop(video: video)
            
            if index == 0 {//第一个
                video.snp.remakeConstraints({ (make) in
                    make.left.equalTo(containerView).offset(spacing);
                    make.top.bottom.equalTo(containerView);
                })
            } else {//中间若干
                video.snp.remakeConstraints({ (make) in
                    make.top.bottom.equalTo(containerView);
                    make.left.equalTo(lastView.snp.right).offset(padding);
                    make.width.equalTo(lastView);
                })
            }
            lastView = video
        }
        
        //最后一个
        lastView.snp.makeConstraints { (make) in
            make.right.equalTo(containerView).offset(-spacing);
        }
    }
    
    /**
     将若干view等高布局于容器containerView中(纵向排列)
     @param views 子视图数组
     @param containerView 容器
     @param spacing 上下间距
     @param padding 相邻两个间距
     */
    func makeVideoHeightViews(views: NSArray, containerView: UIView ,spacing: CGFloat, padding: CGFloat) {
        var lastView: UIView!
        views.enumerateObjects { (object, index, stop) in
            let video = object as! UIView
            containerView.insertSubview(video, at: 0)
            makeAllControlTop(video: video)
            
            if index == 0 {//第一个
                video.snp.remakeConstraints({ (make) in
                    make.top.equalTo(containerView).offset(padding);
                    make.left.right.equalTo(containerView);
                })
            } else {//中间若干
                video.snp.remakeConstraints({ (make) in
                    make.left.right.equalTo(containerView);
                    make.top.equalTo(lastView.snp.bottom).offset(padding);
                    make.height.equalTo(lastView);
                })
            }
            lastView = video
        }
        
        //最后一个
        lastView.snp.makeConstraints { (make) in
            make.bottom.equalTo(containerView).offset(-padding);
        }
    }
    
    
    /**
     等分布局
     @param views 数组
     @param containerView 容器
     @param itemWidth  子视图宽
     @param itemHeight  子视图高
     @param warpCount  折行点
     */
    func makeVideoViews(views: NSArray, containerView: UIView ,itemWidth: CGFloat, itemHeight: CGFloat, warpCount : NSInteger) {
        var lastView: UIView!
        views.enumerateObjects { (object, index, stop) in
            let video = object as! UIView
            
            containerView.insertSubview(video, at: 0)
            makeAllControlTop(video: video)
            
            let rowCount: NSInteger = views.count % NSInteger(warpCount) == 0 ? views.count / NSInteger(warpCount) : views.count / NSInteger(warpCount) + 1
            
            // 当前行
            let currentRow: NSInteger = index / NSInteger(warpCount);
            // 当前列
            let currentColumn: NSInteger = index % NSInteger(warpCount);
            
            video.snp.remakeConstraints({ (make) in
                make.width.equalTo(itemWidth)
                
                make.height.equalTo(itemHeight)
                
                // 第一行
                if (currentRow == 0) {
                    make.top.equalTo(containerView)
                }
                
                // 最后一行
                if (currentRow == rowCount - 1) {
                    make.bottom.equalTo(containerView);
                }
                
                // 中间的若干行
                if currentRow != 0 && (currentRow != rowCount - 1) {
                    make.bottom.equalTo(lastView.snp.bottom)
                }
                
                // 第一列
                if (currentColumn == 0) {
                    make.left.equalTo(containerView);
                }
                // 最后一列
                if (currentColumn == warpCount - 1) {
                    make.right.equalTo(containerView);
                }
                // 中间若干列
                if currentColumn != 0 && (currentColumn != warpCount - 1) {
                    make.left.equalTo(lastView.snp.right);
                }
            })
            
            lastView = video
        }
    }
    
    //确保控件在最上层，如无可不调用
    func makeAllControlTop(video: UIView) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            for object in video.subviews {
                if (object is UILabel) || (object is UIButton) {
                    video.bringSubview(toFront: object)
                }
            }
        }
    }
}

//MARK:- 按钮扩展

enum EdgeInsetsStyle: Int {
    case Top, Left, Bottom, Right
}

extension UIButton {
    //按钮文字图片显示
    func layoutButtonWithEdgeInsetsStyle(style: EdgeInsetsStyle, space: CGFloat) {
        let imageWith: CGFloat = self.imageView!.frame.size.width;
        let imageHeight: CGFloat = self.imageView!.frame.size.height;
        
        var labelWidth: CGFloat = 0.0;
        var labelHeight: CGFloat = 0.0;
        if #available(iOS 8.0, *) {
            // 由于iOS8中titleLabel的size为0，用下面的这种设置
            labelWidth = self.titleLabel!.intrinsicContentSize.width
            labelHeight = self.titleLabel!.intrinsicContentSize.height
        } else {
            labelWidth = self.titleLabel!.frame.size.width
            labelHeight = self.titleLabel!.frame.size.height
        }
        
        var imageEdgeInsets: UIEdgeInsets = UIEdgeInsets.zero;
        var labelEdgeInsets: UIEdgeInsets = UIEdgeInsets.zero;
        
        switch (style) {
        case .Top:
            imageEdgeInsets = UIEdgeInsetsMake(-labelHeight-space/2.0, 0, 0, -labelWidth)
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight-space/2.0, 0)
            break
        case .Left:
            imageEdgeInsets = UIEdgeInsetsMake(0, -space/2.0, 0, space/2.0)
            labelEdgeInsets = UIEdgeInsetsMake(0, space/2.0, 0, -space/2.0)
            break
            
        case .Bottom:
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight-space/2.0, -labelWidth)
            labelEdgeInsets = UIEdgeInsetsMake(-imageHeight-space/2.0, -imageWith, 0, 0)
            break
            
        case .Right:
            imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth+space/2.0, 0, -labelWidth-space/2.0)
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith-space/2.0, 0, imageWith+space/2.0)
            break
        }
        
        self.titleEdgeInsets = labelEdgeInsets;
        self.imageEdgeInsets = imageEdgeInsets;
    }
}

