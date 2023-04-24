//
//  WeatherDetailGeneralView.swift
//  WeatherApp
//
//  Created by Wang Uiroz on 2023/4/10.
//

import UIKit

class WeatherDetailGeneralView: UIView {
    
    var textColor: UIColor? {
        didSet {
            titleLabel.textColor = textColor
            textLabel.textColor = textColor
            detailLabel.textColor = textColor
            imageView.tintColor = textColor
        }
    }
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
    }

}
