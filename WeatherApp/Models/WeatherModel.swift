//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by Wang Uiroz on 2023/2/24.
//

import Foundation

enum SevenDaysWeatherType: String {
    case sunny = "晴天"
    case partlyCloudy = "晴時多雲"
    case partlyCloudy2 = "多雲時晴"
    case mostlyCloudy = "多雲時陰"
    case cloudy = "陰天"
    case mostlyCloudy2 = "多雲"
    case cloudyWithRain = "多雲短暫雨"
    case cloudyWithRain2 = "陰時多雲短暫雨"
    case partlyCloudyWithRain = "多雲時晴短暫雨"
    case cloudyWithOccasionalShowersOrThunderstorms = "多雲時陰短暫陣雨或雷雨"
    case thunderstorms = "雷雨"
    case undefined = ""
    
    var iconName: String {
        switch self {
        case .sunny:
            return "sun.fill"
        case .partlyCloudy, .partlyCloudy2, .partlyCloudyWithRain:
            return "cloud.sun.fill"
        case .mostlyCloudy, .mostlyCloudy2, .cloudy:
            return "cloud.fill"
        case .cloudyWithRain, .cloudyWithRain2:
            return "cloud.rain.fill"
        case .thunderstorms, .cloudyWithOccasionalShowersOrThunderstorms:
            return "cloud.bolt.rain.fill"
        default:
            return "questionmark.square.fill"
        }
    }
}
