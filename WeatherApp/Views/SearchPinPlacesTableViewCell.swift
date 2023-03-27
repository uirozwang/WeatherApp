//
//  SearchPinPlacesTableViewCell.swift
//  WeatherApp
//
//  Created by Wang Uiroz on 2023/3/6.
//

import UIKit

class SearchPinPlacesTableViewCell: UITableViewCell {
    
    @IBOutlet var cityNameLabel: UILabel!
    @IBOutlet var secondLabel: UILabel!
    @IBOutlet var climateLabel: UILabel!
    @IBOutlet var currentTemperatureLabel: UILabel!
    @IBOutlet var minAndMaxTemperatureLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = UIColor(red: 78/255, green: 98/255, blue: 120/255, alpha: 1)
        cityNameLabel.textColor = UIColor.white
        secondLabel.textColor = UIColor.white
        climateLabel.textColor = UIColor.white
        currentTemperatureLabel.textColor = UIColor.white
        minAndMaxTemperatureLabel.textColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
