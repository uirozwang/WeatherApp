//
//  SearchResultTableViewCell.swift
//  WeatherApp
//
//  Created by Wang Uiroz on 2023/3/3.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    
    @IBOutlet var countyNameLabel: UILabel!
    @IBOutlet var cityNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = UIColor(red: 78/255, green: 98/255, blue: 120/255, alpha: 1)
        countyNameLabel.textColor = UIColor.white
        cityNameLabel.textColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
