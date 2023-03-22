//
//  CityModel.swift
//  WeatherApp
//
//  Created by Wang Uiroz on 2023/2/24.
//

import Foundation

struct County {
    var chineseName: String
    var englishName: String
    var dayDomain: String
    var weekDomain: String
}

struct City: Codable {
    var countyName: String
    var cityName: String
    var count: Int?
}
    