//
//  WindDirectionDrawView.swift
//  WeatherApp
//
//  Created by Wang Uiroz on 2023/4/11.
//

import UIKit

class WindDirectionDrawView: UIView {
    
    private let circleLayer = CAShapeLayer()
    private let arrowLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    private func setupLayers() {
//        print(#function)
        // 圓形視圖
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.systemGray.cgColor
        circleLayer.lineWidth = 2
        layer.addSublayer(circleLayer)
        
        // 指針視圖
        let arrowPath = UIBezierPath()
        arrowPath.move(to: CGPoint(x: bounds.midX, y: bounds.maxY-10))
        arrowPath.addLine(to: CGPoint(x: bounds.midX, y: 10))
        arrowLayer.path = arrowPath.cgPath
        arrowLayer.strokeColor = UIColor.white.cgColor
        arrowLayer.fillColor = UIColor.clear.cgColor
        arrowLayer.lineWidth = 2
        arrowLayer.lineCap = .round
        let boundingBox = arrowPath.cgPath.boundingBox
        arrowLayer.bounds = boundingBox
        arrowLayer.position = CGPoint(x: boundingBox.midX, y: boundingBox.midY)
        
        // 創建遮罩層來裁剪漸層層
        let maskLayer = CAShapeLayer()
        let maskRect = CGRect(x: bounds.midX-25, y: bounds.midY-25, width: 50, height: 50)
        maskLayer.path = UIBezierPath(roundedRect: maskRect, cornerRadius: bounds.height/2).cgPath
        maskLayer.fillColor = UIColor.white.cgColor
        
//        arrowLayer.mask = maskLayer
        
        layer.addSublayer(arrowLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        print(#function)
        // 調整圓形和箭頭的frame
        let circlePath = UIBezierPath(ovalIn: bounds)
        circleLayer.path = circlePath.cgPath
        
        let arrowPath = UIBezierPath()
        arrowPath.move(to: CGPoint(x: bounds.midX, y: bounds.maxY-20))
        arrowPath.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.maxY-15), radius: 5, startAngle: -CGFloat.pi/2, endAngle: CGFloat(Double.pi * 3/2), clockwise: true)
        arrowPath.addLine(to: CGPoint(x: bounds.midX, y: 10))
        arrowPath.addLine(to: CGPoint(x: bounds.midX-5, y: 15))
        arrowPath.addLine(to: CGPoint(x: bounds.midX, y: 10))
        arrowPath.addLine(to: CGPoint(x: bounds.midX+5, y: 15))
        arrowPath.addLine(to: CGPoint(x: bounds.midX, y: 10))
        arrowLayer.path = arrowPath.cgPath
        let boundingBox = arrowPath.cgPath.boundingBox
        arrowLayer.bounds = boundingBox
        arrowLayer.position = CGPoint(x: boundingBox.midX, y: boundingBox.midY)
        
        // 創建遮罩層來裁剪漸層層
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: (bounds.width/2+20)/2, startAngle: 0, endAngle: CGFloat.pi*2, clockwise: true).cgPath
        maskLayer.fillColor = UIColor.clear.cgColor;
        maskLayer.strokeColor = UIColor.white.cgColor
        maskLayer.lineWidth = 25
        maskLayer.strokeStart = 0
        maskLayer.strokeEnd = 1
//        let maskRect = CGRect(x: bounds.midX-25, y: bounds.midY-25, width: 50, height: 50)
//        maskLayer.path = UIBezierPath(roundedRect: maskRect, cornerRadius: 1).cgPath
//        layer.addSublayer(maskLayer)
        arrowLayer.mask = maskLayer
        
    }
    
    func setDirection(_ direction: Int) {
//        print(#function)
        let degrees = Double(direction) * 30.0
        let radians = degrees * Double.pi / 180.0
//        arrowLayer.transform = CATransform3DMakeRotation(CGFloat(radians), 0, 0, 1)
        arrowLayer.setAffineTransform(CGAffineTransform(rotationAngle: radians))
    }
    
    /*
    func setDirection(_ direction: Int) {
        let degrees = Double(direction) * 30.0
        let radians = degrees * Double.pi / 180.0
        
        // 計算箭頭的中心點
        let arrowCenter = CGPoint(x: bounds.midX, y: bounds.midY - bounds.width / 4)
        
        // 將圖層移動到箭頭的中心點
        let translation = CATransform3DMakeTranslation(arrowCenter.x - arrowLayer.position.x, arrowCenter.y - arrowLayer.position.y, 0)
        
        // 旋轉圖層
        let rotation = CATransform3DMakeRotation(CGFloat(radians), 0, 0, 1)
        
        // 組合變換
        arrowLayer.transform = CATransform3DConcat(translation, rotation)
    }
    */
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        // 將背景顏色設為透明
        backgroundColor = UIColor.clear
    }
}
