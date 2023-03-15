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
    @IBOutlet var lineView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
