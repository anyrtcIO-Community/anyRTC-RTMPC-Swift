//
//  ATWavesView.swift
//  RTMPCDemo_Swift
//
//  Created by jh on 2018/4/9.
//  Copyright © 2018年 jh. All rights reserved.
//

import UIKit

class ATWavesView: UIView {

    override func draw(_ rect: CGRect) {
        let radius: CGFloat = 30
        let startAngle: CGFloat = 0
        //中心点
        let center = self.center
        let endAngle: CGFloat = 2 * CGFloat(Double.pi)
        
        // center: 弧线中心点的坐标  radius: 弧线所在圆的半径 startAngle: 弧线开始的角度值  endAngle: 弧线结束的角度值clockwise: 是否顺时针画弧线
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.strokeColor = UIColor.blue.cgColor
        layer.fillColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(layer)
    }
}
