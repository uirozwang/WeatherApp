//
//  TemperatureLineView.swift
//  WeatherApp
//
//  Created by Wang Uiroz on 2023/3/17.
//

import UIKit

class TemperatureLineView: UIView {
    
    var widthLeft: Double = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    var widthRight: Double = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        let lowColor = UIColor(red: 98/255, green: 210/255, blue: 215/255, alpha: 1).cgColor
        let highColor = UIColor(red: 255/255, green: 120/255, blue: 29/255, alpha: 1).cgColor
        gradientLayer.colors = [lowColor, highColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 10
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.path = UIBezierPath(rect: bounds).cgPath
        
//        print(widthLeft, widthRight)
//        print(bounds.width)
        
        // 創建遮罩層來裁剪漸層層
        let maskLayer = CAShapeLayer()
        let maskRect = CGRect(x: bounds.width * widthLeft, y: 0, width: bounds.width * widthRight, height: bounds.height)
        maskLayer.path = UIBezierPath(roundedRect: maskRect, cornerRadius: bounds.height/2).cgPath
        maskLayer.fillColor = UIColor.white.cgColor
        
        gradientLayer.mask = maskLayer
        
        layer.addSublayer(gradientLayer)
    }
    
}
