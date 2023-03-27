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



class City: Codable {
    var countyName: String
    var cityName: String
    var count: Int?
    
    init(countyName: String, cityName: String, count: Int? = nil) {
        self.countyName = countyName
        self.cityName = cityName
        self.count = count
    }
}

class CityDetail: City {
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
    
    var currentTemperature = ""
    var currentClimate = ""
    var currentMaxTemperature = ""
    var currentMinTemperature = ""
    
    let opendataAuth = "CWB-77C0E18C-8CFF-40CB-9335-BCB226CFF4DE"
    
    var threeDaysWeatherData = CityThreeDaysWeatherData(probabilityofPrecipitation12h: [], weatherPhenomenon: [], apparentTemperature: [], temperature: [], relativeHumidity: [], comfortIndex: [], weatherDescription: [], probabilityofPrecipitation6h: [], windSpeed: [], windDirection: [], dewPointTemperature: [])
    var sevenDaysWeatherData = CitySevenDaysWeatherData(probabilityofPrecipitation12h: [], averageTemperature: [], averageRelativeHumidity: [], minComfortIndex: [], windSpeed: [], maxApparentTemperature: [], weatherPhenomenon: [], maxComfortIndex: [], minTemperature: [], ultravioletIndex: [], weatherDescription: [], minApparentTemperature: [], maxTemperature: [], windDirection: [], averageDewPointTemperature: [])
    
    func getThreeDaysCityWeatherData(completed: @escaping () -> ()) {
        var dayDomain = ""
        let countiesDomain = AllCountyDomain.shared.allCityDomain
        for county in countiesDomain {
            if county.chineseName == countyName {
                dayDomain = county.dayDomain
            }
        }
        
        var dayRequest = URLRequest(url: URL(string: "https://opendata.cwb.gov.tw/api/v1/rest/datastore/\(dayDomain)?Authorization=\(opendataAuth)")!,timeoutInterval: Double.infinity)
        dayRequest.addValue("TS01a5ae52=0107dddfefa99779413a2b3bda072beac3f035ffa20639b0e7758f3923825255ae45862654dd0722657e7154c272801968bba8bc9f", forHTTPHeaderField: "Cookie")
        
        dayRequest.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: dayRequest) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                completed()
                return
            }
            do {
                let result = try JSONDecoder().decode(WeatherResult.self, from: data)
                
                if let record = result.records,
                   let county = record.locations,
                   let cities = county[0].location {
                    var citiesIndex = 999
                    for i in 0..<cities.count {
                        if cities[i].locationName == self.cityName {
                            citiesIndex = i
                        }
                    }
                    if citiesIndex == 999 {
                        print("no city to organize.")
                        return
                    }
                    let elements = cities[citiesIndex].weatherElement!
                    self.threeDaysWeatherData = CityThreeDaysWeatherData(probabilityofPrecipitation12h: [], weatherPhenomenon: [], apparentTemperature: [], temperature: [], relativeHumidity: [], comfortIndex: [], weatherDescription: [], probabilityofPrecipitation6h: [], windSpeed: [], windDirection: [], dewPointTemperature: [])
                    for i in 0..<elements.count {
                        var elementValues: [OrganizedElement] = []
                        if let time = elements[i].time {
                            for i in 0..<time.count {
                                var elementValueTemp: OrganizedElement?
                                
                                // 區分成startTime dataTime兩種，並盡量簡化它
                                
                                if let elementValue = time[i].elementValue,
                                   let value = elementValue[0].value,
                                   let measures = elementValue[0].measures {
                                    
                                    if let startTime = time[i].startTime,
                                       let endTime = time[i].endTime {
                                        
                                        // 回傳的json會包含先前的時間，因此要篩選掉過時的資訊，但好像json來的時間不太一定
                                        //                            if let date1 = dateFormatter.date(from: startTime),
                                        //                               let date2 = dateFormatter.date(from: currentTimeString) {
                                        //
                                        //                                let result = date1.compare(date2)
                                        //                                if result == .orderedAscending {
                                        //                                    print("date2 is earlier than date1")
                                        //                                } else {
                                        elementValueTemp = OrganizedElement(startTime: startTime,
                                                                            endTime: endTime,
                                                                            elementValue: [OrganizedElementValue(value: value, measures: measures)])
                                        //                                    print(elementValueTemp)
                                        if time[i].elementValue!.count > 1 {
                                            if let elementValue = time[i].elementValue,
                                               let value = elementValue[1].value,
                                               let measures = elementValue[1].measures {
                                                elementValueTemp?.elementValue.append(OrganizedElementValue(value: value, measures: measures))
                                            }
                                        }
                                        //                                    }
                                        //                                }
                                    }
                                    
                                    if let dataTime = time[i].dataTime {
                                        
                                        // 回傳的json會包含先前的時間，因此要篩選掉過時的資訊
                                        //                                if let date1 = dateFormatter.date(from: dataTime),
                                        //                                   let date2 = dateFormatter.date(from: currentTimeString) {
                                        //
                                        //                                    let result = date1.compare(date2)
                                        //                                    if result == .orderedAscending {
                                        //                                        print("date2 is earlier than date1")
                                        //                                    } else {
                                        elementValueTemp = OrganizedElement(dataTime: dataTime,
                                                                            elementValue: [OrganizedElementValue(value: value, measures: measures)])
                                        //                                    print(elementValueTemp)
                                        if time[i].elementValue!.count > 1 {
                                            if let elementValue = time[i].elementValue,
                                               let value = elementValue[1].value,
                                               let measures = elementValue[1].measures {
                                                elementValueTemp?.elementValue.append(OrganizedElementValue(value: value, measures: measures))
                                            }
                                        }
                                        //                                    }
                                        //                                }
                                        
                                    }
                                }
                                if let temp = elementValueTemp {
                                    elementValues.append(temp)
                                }
                            }
                        }
                        
                        switch elements[i].elementName {
                        case "PoP12h":
                            self.threeDaysWeatherData.probabilityofPrecipitation12h = elementValues
                        case "Wx":
                            self.threeDaysWeatherData.weatherPhenomenon = elementValues
                        case "AT":
                            self.threeDaysWeatherData.apparentTemperature = elementValues
                        case "T":
                            self.threeDaysWeatherData.temperature = elementValues
                        case "RH":
                            self.threeDaysWeatherData.relativeHumidity = elementValues
                        case "CI":
                            self.threeDaysWeatherData.comfortIndex = elementValues
                        case "WeatherDescription":
                            self.threeDaysWeatherData.weatherDescription = elementValues
                        case "PoP6h":
                            self.threeDaysWeatherData.probabilityofPrecipitation6h = elementValues
                        case "WS":
                            self.threeDaysWeatherData.windSpeed = elementValues
                        case "WD":
                            self.threeDaysWeatherData.windDirection = elementValues
                        case "Td":
                            self.threeDaysWeatherData.dewPointTemperature = elementValues
                        default:
                            if let elementName = elements[i].elementName {
                                print("Organize data error, element name:", elementName)
                            } else {
                                print("Organize error, unknown data")
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let currentTime = Date()
                        
                        var key = false
                        for i in 0..<self.threeDaysWeatherData.temperature.count {
                            if i < self.threeDaysWeatherData.temperature.count-1,
                               let timeString1 = self.threeDaysWeatherData.temperature[i].dataTime,
                               let timeString2 = self.threeDaysWeatherData.temperature[i+1].dataTime,
                               let time1 = dateFormatter.date(from: timeString1),
                               let time2 = dateFormatter.date(from: timeString2),
                               key == false {
                                let result1 = currentTime.compare(time1)
                                let result2 = currentTime.compare(time2)
                                if result1 == .orderedDescending && result2 == .orderedAscending {
                                    key = true
                                    let currentTemperature = self.threeDaysWeatherData.temperature[i].elementValue[0].value
                                    self.currentTemperature = currentTemperature+"°"
                                    let currentClimate = self.threeDaysWeatherData.weatherPhenomenon[i].elementValue[0].value
                                    self.currentClimate = currentClimate
                                    var maxTemperature = -999
                                    var minTemperature = 999
                                    for i in 0..<8 {
                                        if let currentTemperature = Int(self.threeDaysWeatherData.temperature[i].elementValue[0].value) {
                                            if currentTemperature > maxTemperature {
                                                maxTemperature = currentTemperature
                                            }
                                            if currentTemperature < minTemperature {
                                                minTemperature = currentTemperature
                                            }
                                            self.currentMinTemperature = "\(minTemperature)"
                                            self.currentMaxTemperature = "\(maxTemperature)"
                                        }
                                    }
                                }
                            }
                            
                        }
                        // 當第一筆資料已經不包含當前天氣時才會啟用
                        if key == false {
                            let currentTemperature = self.threeDaysWeatherData.temperature[0].elementValue[0].value
                            self.currentTemperature = currentTemperature+"°"
                            let currentClimate = self.threeDaysWeatherData.weatherPhenomenon[0].elementValue[0].value
                            self.currentClimate = currentClimate
                            var maxTemperature = -999
                            var minTemperature = 999
                            for i in 0..<8 {
                                if let currentTemperature = Int(self.threeDaysWeatherData.temperature[i].elementValue[0].value) {
                                    if currentTemperature > maxTemperature {
                                        maxTemperature = currentTemperature
                                    }
                                    if currentTemperature < minTemperature {
                                        minTemperature = currentTemperature
                                    }
                                    self.currentMinTemperature = "\(minTemperature)"
                                    self.currentMaxTemperature = "\(maxTemperature)"
                                }
                            }
                        }
                        
                    }
                    
                }
            } catch {
                print(error)
            }
            completed()
        }
        task.resume()
    }
    
    func getSevenDaysCityWeatherData(completed: @escaping () -> ()) {
        var weekDomain = ""
        let countiesDomain = AllCountyDomain.shared.allCityDomain
        for county in countiesDomain {
            if county.chineseName == countyName {
                weekDomain = county.weekDomain
            }
        }
        
        var weekRequest = URLRequest(url: URL(string: "https://opendata.cwb.gov.tw/api/v1/rest/datastore/\(weekDomain)?Authorization=\(opendataAuth)")!,timeoutInterval: Double.infinity)
        weekRequest.addValue("TS01a5ae52=0107dddfefa99779413a2b3bda072beac3f035ffa20639b0e7758f3923825255ae45862654dd0722657e7154c272801968bba8bc9f", forHTTPHeaderField: "Cookie")
        
        weekRequest.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: weekRequest) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                completed()
                return
            }
            do {
                let result = try JSONDecoder().decode(WeatherResult.self, from: data)
                
                if let record = result.records,
                   let county = record.locations,
                   let cities = county[0].location {
                    var citiesIndex = 999
                    for i in 0..<cities.count {
                        if cities[i].locationName == self.cityName {
                            citiesIndex = i
                        }
                    }
                    if citiesIndex == 999 {
                        print("no city to organize.")
                        completed()
                        return
                    }
                    let elements = cities[citiesIndex].weatherElement!
                    self.sevenDaysWeatherData = CitySevenDaysWeatherData(probabilityofPrecipitation12h: [], averageTemperature: [], averageRelativeHumidity: [], minComfortIndex: [], windSpeed: [], maxApparentTemperature: [], weatherPhenomenon: [], maxComfortIndex: [], minTemperature: [], ultravioletIndex: [], weatherDescription: [], minApparentTemperature: [], maxTemperature: [], windDirection: [], averageDewPointTemperature: [])
                    for i in 0..<elements.count {
                        var elementValues: [OrganizedElement] = []
                        if let time = elements[i].time {
                            for i in 0..<time.count {
                                var elementValueTemp: OrganizedElement?
                                
                                // 區分成startTime dataTime兩種，並盡量簡化它
                                
                                if let elementValue = time[i].elementValue,
                                   let value = elementValue[0].value,
                                   let measures = elementValue[0].measures {
                                    
                                    if let startTime = time[i].startTime,
                                       let endTime = time[i].endTime {
                                        
                                        // 回傳的json會包含先前的時間，因此要篩選掉過時的資訊，但好像json來的時間不太一定
                                        //                            if let date1 = dateFormatter.date(from: startTime),
                                        //                               let date2 = dateFormatter.date(from: currentTimeString) {
                                        //
                                        //                                let result = date1.compare(date2)
                                        //                                if result == .orderedAscending {
                                        //                                    print("date2 is earlier than date1")
                                        //                                } else {
                                        elementValueTemp = OrganizedElement(startTime: startTime,
                                                                            endTime: endTime,
                                                                            elementValue: [OrganizedElementValue(value: value, measures: measures)])
                                        //                                    print(elementValueTemp)
                                        if time[i].elementValue!.count > 1 {
                                            if let elementValue = time[i].elementValue,
                                               let value = elementValue[1].value,
                                               let measures = elementValue[1].measures {
                                                elementValueTemp?.elementValue.append(OrganizedElementValue(value: value, measures: measures))
                                            }
                                        }
                                        //                                    }
                                        //                                }
                                    }
                                    
                                    if let dataTime = time[i].dataTime {
                                        
                                        // 回傳的json會包含先前的時間，因此要篩選掉過時的資訊
                                        //                                if let date1 = dateFormatter.date(from: dataTime),
                                        //                                   let date2 = dateFormatter.date(from: currentTimeString) {
                                        //
                                        //                                    let result = date1.compare(date2)
                                        //                                    if result == .orderedAscending {
                                        //                                        print("date2 is earlier than date1")
                                        //                                    } else {
                                        elementValueTemp = OrganizedElement(dataTime: dataTime,
                                                                            elementValue: [OrganizedElementValue(value: value, measures: measures)])
                                        //                                    print(elementValueTemp)
                                        if time[i].elementValue!.count > 1 {
                                            if let elementValue = time[i].elementValue,
                                               let value = elementValue[1].value,
                                               let measures = elementValue[1].measures {
                                                elementValueTemp?.elementValue.append(OrganizedElementValue(value: value, measures: measures))
                                            }
                                        }
                                        //                                    }
                                        //                                }
                                        
                                    }
                                }
                                
                                
                                
                                if let temp = elementValueTemp {
                                    elementValues.append(temp)
                                }
                            }
                        }
                        if elementValues.count == 0 {
                            if let elementName = elements[i].elementName {
                                print(elementName)
                            }
                        }
                        switch elements[i].elementName {
                        case "PoP12h":
                            self.sevenDaysWeatherData.probabilityofPrecipitation12h = elementValues
                        case "T":
                            self.sevenDaysWeatherData.averageTemperature = elementValues
                        case "RH":
                            self.sevenDaysWeatherData.averageRelativeHumidity = elementValues
                        case "MinCI":
                            self.sevenDaysWeatherData.minComfortIndex = elementValues
                        case "WS":
                            self.sevenDaysWeatherData.windSpeed = elementValues
                        case "MaxAT":
                            self.sevenDaysWeatherData.maxApparentTemperature = elementValues
                        case "Wx":
                            self.sevenDaysWeatherData.weatherPhenomenon = elementValues
                        case "MaxCI":
                            self.sevenDaysWeatherData.maxComfortIndex = elementValues
                        case "MinT":
                            self.sevenDaysWeatherData.minTemperature = elementValues
                        case "UVI":
                            self.sevenDaysWeatherData.ultravioletIndex = elementValues
                        case "WeatherDescription":
                            self.sevenDaysWeatherData.weatherDescription = elementValues
                        case "MinAT":
                            self.sevenDaysWeatherData.minApparentTemperature = elementValues
                        case "MaxT":
                            self.sevenDaysWeatherData.maxTemperature = elementValues
                        case "WD":
                            self.sevenDaysWeatherData.windDirection = elementValues
                        case "Td":
                            self.sevenDaysWeatherData.averageDewPointTemperature = elementValues
                        default:
                            if let elementName = elements[i].elementName {
                                print("Organize data error, element name:", elementName)
                            } else {
                                print("Organize error, unknown data")
                            }
                        }
                    }
                }
            } catch {
                print(error)
            }
            completed()
        }
        task.resume()
    }
    
    func getMinAndMaxTemperature(date: Date) -> (Int, Int) {
        
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var minTemperatureArray: [Int] = []
        var maxTemperatureArray: [Int] = []
        
        for i in 0..<self.sevenDaysWeatherData.minTemperature.count {
            if let timeString = self.sevenDaysWeatherData.minTemperature[i].startTime,
               let minTemperature = Int(self.sevenDaysWeatherData.minTemperature[i].elementValue[0].value),
               let maxTemperature = Int(self.sevenDaysWeatherData.maxTemperature[i].elementValue[0].value),
               let date = dateFormatter.date(from: timeString) {
                let dataYear = calendar.component(.year, from: date)
                let dataMonth = calendar.component(.month, from: date)
                let dataDay = calendar.component(.day, from: date)
                if dataYear == year && dataMonth == month && dataDay == day {
                    minTemperatureArray.append(minTemperature)
                    maxTemperatureArray.append(maxTemperature)
                }
            }
        }
        var min = 999
        var max = -999
        for i in 0..<minTemperatureArray.count {
            if minTemperatureArray[i] < min {
                min = minTemperatureArray[i]
            }
            if maxTemperatureArray[i] > max {
                max = maxTemperatureArray[i]
            }
        }
        
        return (min, max)
    }
    
    func getSevenDayMinAndMaxTemperature() -> (Int, Int) {
        
        let todayDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var min = 999
        var max = -999
        
        for i in 0..<self.sevenDaysWeatherData.minTemperature.count {
            if let timeString = self.sevenDaysWeatherData.minTemperature[i].startTime,
               let minTemperature = Int(self.sevenDaysWeatherData.minTemperature[i].elementValue[0].value),
               let maxTemperature = Int(self.sevenDaysWeatherData.maxTemperature[i].elementValue[0].value),
               let date = dateFormatter.date(from: timeString) {
                
                // 計算 date 與 todayDate 的時間差
                let interval = date.timeIntervalSince(todayDate)
                let days = Int(interval / (24 * 60 * 60))
                
                // 判斷 date 是否在七天之內
                if days >= 0 && days <= 6 {
                    if minTemperature < min {
                        min = minTemperature
                    }
                    if maxTemperature > max {
                        max = maxTemperature
                    }
                }
            }
        }
        return (min, max)
    }
    
    func getWeatherPhenomenonForDate(date: Date) -> String {
        
        let todayDate = Date()
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let todayYear = calendar.component(.year, from: todayDate)
        let todayMonth = calendar.component(.month, from: todayDate)
        let todayDay = calendar.component(.day, from: todayDate)
        
        for i in 0..<self.sevenDaysWeatherData.weatherPhenomenon.count {
            if let timeString = self.sevenDaysWeatherData.weatherPhenomenon[i].startTime,
               let dataDate = dateFormatter.date(from: timeString) {
                let dataYear = calendar.component(.year, from: dataDate)
                let dataMonth = calendar.component(.month, from: dataDate)
                let dataDay = calendar.component(.day, from: dataDate)
                let dataHour = calendar.component(.hour, from: dataDate)
                var wx = SevenDaysWeatherType.undefined
                
                if dataYear == todayYear && dataMonth == todayMonth && dataDay == todayDay && dataHour == 6 {
                    if let weatherType = SevenDaysWeatherType(rawValue: self.sevenDaysWeatherData.weatherPhenomenon[i].elementValue[1].value) {
                        wx = weatherType
                    }
                } else {
                    // 沒資料，顯示第一筆
                    if let weatherType = SevenDaysWeatherType(rawValue: self.sevenDaysWeatherData.weatherPhenomenon[0].elementValue[1].value) {
                        wx = weatherType
                    }
                }
                if wx == .undefined {
                    print(self.sevenDaysWeatherData.weatherPhenomenon[i].elementValue[1].value)
                }
                return wx.iconName
            }
        }
        print("something error getWeatherPhenomenonForDate(date: Date)")
        return "questionmark.square.fill"
    }
    
}
