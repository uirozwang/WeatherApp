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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
