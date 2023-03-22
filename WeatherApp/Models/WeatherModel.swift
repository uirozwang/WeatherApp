//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by Wang Uiroz on 2023/2/24.
//

import Foundation

struct WeatherResult: Codable {
    
    let success: String?
    let result: WeatherResultData?
    let records: WeatherRecords?
    
}

struct WeatherResultData: Codable {
    let resource_id: String?
    let fields: [WeatherField]?
    
}

struct WeatherField: Codable {
    let id: String?
    let type: String?
}

struct WeatherRecords: Codable {
    
    enum CodingKeys: String, CodingKey {
        case datasetDescription, locationName, locationsName, dataid, location, locations
    }
    
    let datasetDescription: String?
    let locationName: String?
    let locationsName: String?
    let dataid: String?
    let location: [WeatherLocation]?
    let locations: [WeatherLocations]?
}

struct WeatherLocations: Codable {
    let datasetDescription: String?
    let locationName: String?
    let locationsName: String?
    let dataid: String?
    let location: [WeatherLocation]?
}

struct WeatherLocation: Codable {
    let datasetDescription: String?
    let locationName: String?
    let geocode: String?
    let lat: String?
    let lon: String?
    let weatherElement: [WeatherElement]?
}

struct WeatherElement: Codable {
    let elementName: String?
    let description: String?
    let time: [WeatherTime]?
}

struct WeatherTime: Codable {
    let startTime: String?
    let endTime: String?
    let dataTime: String?
    let parameter: WeatherParameter?
    let elementValue: [WeatherElementValue]?
}

struct WeatherParameter: Codable {
    let parameterName: String?
    let parameterValue: String?
    let parameterUnit: String?
}

struct WeatherElementValue: Codable {
    let value: String?
    let measures: String?
}

struct OrganizedElementValue {
    var value: String
    var measures: String
}

struct OrganizedElement {
    var startTime: String?
    var endTime: String?
    var dataTime: String?
    var elementValue: [OrganizedElementValue]
}

struct CityThreeDaysWeatherData {
    var probabilityofPrecipitation12h: [OrganizedElement]
    var weatherPhenomenon: [OrganizedElement]
    var apparentTemperature: [OrganizedElement]
    var temperature: [OrganizedElement]
    var relativeHumidity: [OrganizedElement]
    var comfortIndex: [OrganizedElement]
    var weatherDescription: [OrganizedElement]
    var probabilityofPrecipitation6h: [OrganizedElement]
    var windSpeed: [OrganizedElement]
    var windDirection: [OrganizedElement]
    var dewPointTemperature: [OrganizedElement]
}

struct CitySevenDaysWeatherData {
    var probabilityofPrecipitation12h: [OrganizedElement]
    var averageTemperature: [OrganizedElement]
    var averageRelativeHumidity: [OrganizedElement]
    var minComfortIndex: [OrganizedElement]
    var windSpeed: [OrganizedElement]
    var maxApparentTemperature: [OrganizedElement]
    var weatherPhenomenon: [OrganizedElement]
    var maxComfortIndex: [OrganizedElement]
    var minTemperature: [OrganizedElement]
    var ultravioletIndex: [OrganizedElement]
    var weatherDescription: [OrganizedElement]
    var minApparentTemperature: [OrganizedElement]
    var maxTemperature: [OrganizedElement]
    var windDirection: [OrganizedElement]
    var averageDewPointTemperature: [OrganizedElement]
}

enum WeatherType: String {
    case sunny = "晴天"
    case partlyCloudy = "晴時多雲"
    case partlyCloudy2 = "多雲時晴"
    case mostlyCloudy = "多雲時陰"
    case cloudy = "陰天"
    case mostlyCloudy2 = "多雲"
    case cloudyWithRain = "多雲短暫雨"
    case cloudyWithRain2 = "陰時多雲短暫雨"
    case partlyCloudyWithRain = "多雲時晴短暫雨"
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
        default:
            return "questionmark.square.fill"
        }
    }
}
