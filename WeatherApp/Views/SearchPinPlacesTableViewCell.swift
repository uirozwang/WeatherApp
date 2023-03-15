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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
