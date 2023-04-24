//
//  WindDirectionView.swift
//  WeatherApp
//
//  Created by Wang Uiroz on 2023/4/10.
//

import UIKit

class WindDirectionView: UIView {
    
    var textColor: UIColor? {
        didSet {
            titleLabel.textColor = textColor
            imageView.tintColor = textColor
            windDirectionLabel.textColor = textColor
        }
    }
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var windDrawView: WindDirectionDrawView!
    @IBOutlet var windDirectionLabel: UILabel!

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
