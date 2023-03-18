//
//  WeatherDayClimateTableViewCell.swift
//  WeatherApp
//
//  Created by Wang Uiroz on 2023/3/7.
//

import UIKit

class WeatherDayClimateTableViewCell: UITableViewCell {
    
    @IBOutlet var weekLabel: UILabel!
    @IBOutlet var weatherImageView: UIImageView!
    @IBOutlet var lowTemperatureLabel: UILabel!
    @IBOutlet var highTemperatureLabel: UILabel!
    @IBOutlet var lineView: TemperatureLineView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
            super.prepareForReuse()
            // 移除 lineView 上的所有 sublayer，避免繪圖異常
            lineView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        }

}
