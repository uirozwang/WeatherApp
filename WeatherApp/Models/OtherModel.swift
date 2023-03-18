//
//  OtherModel.swift
//  WeatherApp
//
//  Created by Wang Uiroz on 2023/3/12.
//

import Foundation

struct CurrentTime {
    var year: Int
    var month: Int
    var day: Int
    var hour: Int
    var min: Int
}

class AllWeekday {
    static let shared = AllWeekday()
    var allWeekday = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    private init() {}
}
