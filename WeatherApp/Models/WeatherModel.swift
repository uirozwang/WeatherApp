//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by Wang Uiroz on 2023/2/24.
//

import Foundation
/*
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
    case overcastWithBriefShowersOrThunderstorms = "陰短暫陣雨或雷雨"
    case overcastPartlyCloudyWithShowersOrThunderstorms = "陰時多雲短暫陣雨或雷雨"
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
        case .thunderstorms, .cloudyWithOccasionalShowersOrThunderstorms, .overcastWithBriefShowersOrThunderstorms:
            return "cloud.bolt.rain.fill"
        default:
            return "questionmark.square.fill"
        }
    }
}
*/
enum SevenDaysWeatherType: String {
    case clear = "01"
    case mostlyClear = "02"
    case partlyClear = "03"
    case partlyCloudy = "04"
    case mostlyCloudy = "05"
    case mostlyCloudy2 = "06"
    case cloudy = "07"
    case partlyCloudyWithRain = "08"
    case mostlyCloudyWithOccasionalRain = "09"
    case mostlyCloudyWithOccasionalShower = "10"
    case rainy = "11"
    case mostlyCloudyWithRain = "12"
    case mostlyCloudyWithRain2 = "13"
    case rainy2 = "14"
    case thunderstorms = "15"
    case partlyCloudyWithShowersOrThunderstorms = "16"
    case mostyCloudyWithThundershowers = "17"
    case cloudyWithShowersOrThunderstorms = "18"
    case clearBecomingPartlyCloudyWithLocalRainInTheAfternoon = "19"
    case partlyCloudyWithLocalAfternoonRain = "20"
    case clearBecomingPartlyCloudyWithShowersOrThunderstormsInTheAfternoon = "21"
    case partlyCloudyWithLocalAfternoonShowersOrThunderstorms = "22"
    case partlyCloudyWithLocalShowersOrSnow = "23"
    case clearWithFog = "24"
    case mostlyClearWithFog = "25"
    case partlyClearWithFog = "26"
    case partlyCloudyWithFog = "27"
    case cloudyWithFog = "28"
    case partlyCloudyWithLocalRain = "29"
    case mostlyCloudyWithLocalRain = "30"
    case partlyCloudyWithFogAndLocalRain = "31"
    case mostlyCloudyWithFogAndLocalRain = "32"
    case partlyCloudyWithLocalShowersOrThundershowers = "33"
    case partlyCloudyWithLocalShowersOrThundershowers2 = "34"
    case partlyCloudyWithShowersOrThunderstormsAndFog = "35"
    case mostlyCloudyWithShowersOrThunderstormsAndFog = "36"
    case partlyCloudyWithLocalRainOrSnowAndFog = "37"
    case occasionalShowersWithFog = "38"
    case rainWithFog = "39"
    case occasionalShowersOrThunderstormsWithFog = "41"
    case snow = "42"
    case undefined = ""
    
    var iconName: String {
        switch self {
        case .clear:
            return "sun.fill"
        case .mostlyClear, .partlyClear, .partlyCloudy, .clearWithFog, .mostlyClearWithFog, .partlyClearWithFog, .partlyCloudyWithFog:
            return "cloud.sun.fill"
        case .mostlyCloudy, .mostlyCloudy2, .cloudy, .cloudyWithFog:
            return "cloud.fill"
        case .partlyCloudyWithRain, .mostlyCloudyWithOccasionalRain, .mostlyCloudyWithOccasionalShower, .rainy, .mostlyCloudyWithRain, .mostlyCloudyWithRain2, .rainy2, .partlyCloudyWithLocalShowersOrSnow, .mostlyCloudyWithLocalRain, .mostlyCloudyWithFogAndLocalRain, .partlyCloudyWithLocalRainOrSnowAndFog, .occasionalShowersWithFog, .rainWithFog:
            return "cloud.rain.fill"
        case .thunderstorms, .partlyCloudyWithShowersOrThunderstorms, .mostyCloudyWithThundershowers, .cloudyWithShowersOrThunderstorms, .partlyCloudyWithLocalShowersOrThundershowers, .partlyCloudyWithLocalShowersOrThundershowers2, .partlyCloudyWithShowersOrThunderstormsAndFog, .mostlyCloudyWithShowersOrThunderstormsAndFog, .occasionalShowersOrThunderstormsWithFog:
            return "cloud.bolt.rain.fill"
        case .clearBecomingPartlyCloudyWithLocalRainInTheAfternoon, .partlyCloudyWithLocalAfternoonRain, .clearBecomingPartlyCloudyWithShowersOrThunderstormsInTheAfternoon, .partlyCloudyWithLocalAfternoonShowersOrThunderstorms, .partlyCloudyWithLocalRain, .partlyCloudyWithFogAndLocalRain:
            return "cloud.sun.rain.fill"
        case .snow:
            return "cloud.snow.fill"
        default:
            return "questionmark.square.fill"
        }
    }
}
