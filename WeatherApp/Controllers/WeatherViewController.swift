//
//  ViewController.swift
//  WeatherApp
//
//  Created by Wang Uiroz on 2023/2/23.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var currentTemparatureLabel: UILabel!
    @IBOutlet weak var currentClimateLabel: UILabel!
    @IBOutlet weak var temparatureIntervalLabel: UILabel!
    
    @IBOutlet weak var hourForecastCollectionView: UICollectionView!
    @IBOutlet weak var dayForecastTableView: UITableView!
    
    let opendataAuth = "CWB-77C0E18C-8CFF-40CB-9335-BCB226CFF4DE"
    
    let countiesDomain = AllCountyDomain.shared.allCityDomain
    
    var weatherResultData: [WeatherResult] = []
    
    // 當前顯示的城市，0代表GPS定位
    var currentCityIndex: Int = 0
    
    // default location, NCUE
    var currentLat = 24.081013
    var currentLon = 120.558316
    var currentCounty = "彰化縣"
    var currentCity = "彰化市"
    
    // index 0 is location, other places is set by user
    var pinCities: [City] = [City(countyName: "彰化縣", cityName: "彰化市"),
                             City(countyName: "彰化縣", cityName: "和美鎮")]
    var pinCitiesWeatherData: [CityTwoDayWeatherData] = []
    
    var locationMgr = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hourForecastCollectionView.delegate = self
        hourForecastCollectionView.dataSource = self
        dayForecastTableView.delegate = self
        dayForecastTableView.dataSource = self
        
        // 移動多遠更新座標點
        locationMgr.distanceFilter = kCLLocationAccuracyHundredMeters
        // 定位精準度
        locationMgr.desiredAccuracy = kCLLocationAccuracyKilometer
        locationMgr.delegate = self
        startTimer()
        getPinCitiesWeatherData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuth()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationMgr.stopUpdatingLocation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchVC" {
            let vc = segue.destination as? SearchViewController
            vc?.delegate = self
        }
    }
    
    func getCurrentTime() -> CurrentTime {
        let date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy"
        let year = Int(dateFormatter.string(from: date))
        dateFormatter.dateFormat = "MM"
        let month = Int(dateFormatter.string(from: date))
        dateFormatter.dateFormat = "dd"
        let day = Int(dateFormatter.string(from: date))
        dateFormatter.dateFormat = "HH"
        let hour = Int(dateFormatter.string(from: date))
        dateFormatter.dateFormat = "mm"
        let min = Int(dateFormatter.string(from: date))
        let currentTime = CurrentTime(year: year!, month: month!, day: day!, hour: hour!, min: min!)
        return currentTime
    }
    
    // 考量到有可能只更新一個資料的情況，所做的保留
    func getPinCitiesWeatherData() {
        weatherResultData = []
        pinCitiesWeatherData = []
        for i in 0..<pinCities.count {
            getCityWeatherData(index: i)
        }
    }
    
    func getCityWeatherData(index: Int) {
        var dayDomain = ""
        var weekDomain = ""
        
        for county in countiesDomain {
            if county.chineseName == pinCities[index].countyName {
                dayDomain = county.dayDomain
                weekDomain = county.weekDomain
            }
        }
        
        var dayRequest = URLRequest(url: URL(string: "https://opendata.cwb.gov.tw/api/v1/rest/datastore/\(dayDomain)?Authorization=\(opendataAuth)")!,timeoutInterval: Double.infinity)
        dayRequest.addValue("TS01a5ae52=0107dddfefa99779413a2b3bda072beac3f035ffa20639b0e7758f3923825255ae45862654dd0722657e7154c272801968bba8bc9f", forHTTPHeaderField: "Cookie")
        var weekRequest = URLRequest(url: URL(string: "https://opendata.cwb.gov.tw/api/v1/rest/datastore/\(weekDomain)?Authorization=\(opendataAuth)")!,timeoutInterval: Double.infinity)
        weekRequest.addValue("TS01a5ae52=0107dddfefa99779413a2b3bda072beac3f035ffa20639b0e7758f3923825255ae45862654dd0722657e7154c272801968bba8bc9f", forHTTPHeaderField: "Cookie")
        
        dayRequest.httpMethod = "GET"
        weekRequest.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: dayRequest) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            //            print(String(data: data, encoding: .utf8)!)
            
            do {
                let result = try JSONDecoder().decode(WeatherResult.self, from: data)
                //                print(result)
                self.weatherResultData.append(result)
                self.organizeResultData(index: index)
            } catch {
                print(error)
            }
            
        }
        
        task.resume()
        
    }
    
    func organizeResultData(index: Int) {
        
        if let records = weatherResultData[index].records,
           let county = records.locations,
           let cities = county[0].location {
            let cityName = pinCities[index].cityName
            var citiesIndex = 999
            for i in 0..<cities.count {
//                print(cities[i].locationName)
                if cities[i].locationName == cityName {
                    citiesIndex = i
                }
            }
            
            if citiesIndex == 999 {
                print("no city to origanize")
                return
            }
            let elements = cities[citiesIndex].weatherElement!
            
            var pinCitiesWeatherDataTemp = CityTwoDayWeatherData(probabilityofPrecipitation12h: [],
                                                                 weatherPhenomenon: [],
                                                                 apparentTemperature: [],
                                                                 temperature: [],
                                                                 relativeHumidity: [],
                                                                 comfortIndex: [],
                                                                 weatherDescription: [],
                                                                 probabilityofPrecipitation6h: [],
                                                                 windSpeed: [],
                                                                 windDirection: [],
                                                                 dewPointTemperature: [])
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let currentTime = Date()
            let currentTimeString = dateFormatter.string(from: currentTime)
            //            print(currentTimeString)
            
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
                //                print("elementValues")
//                print(elementValues)
                switch elements[i].elementName {
                case "PoP12h":
                    pinCitiesWeatherDataTemp.probabilityofPrecipitation12h = elementValues
                case "Wx":
                    pinCitiesWeatherDataTemp.weatherPhenomenon = elementValues
                case "AT":
                    pinCitiesWeatherDataTemp.apparentTemperature = elementValues
                case "T":
                    pinCitiesWeatherDataTemp.temperature = elementValues
                case "RH":
                    pinCitiesWeatherDataTemp.relativeHumidity = elementValues
                case "CI":
                    pinCitiesWeatherDataTemp.comfortIndex = elementValues
                case "WeatherDescription":
                    pinCitiesWeatherDataTemp.weatherDescription = elementValues
                case "PoP6h":
                    pinCitiesWeatherDataTemp.probabilityofPrecipitation6h = elementValues
                case "WS":
                    pinCitiesWeatherDataTemp.windSpeed = elementValues
                case "WD":
                    pinCitiesWeatherDataTemp.windDirection = elementValues
                case "Td":
                    pinCitiesWeatherDataTemp.dewPointTemperature = elementValues
                default:
                    if let elementName = elements[i].elementName {
                        print("Organize data error, element name:", elementName)
                    } else {
                        print("Organize error, unknown data")
                    }
                }
            }
//                    print(pinCitiesWeatherDataTemp.weatherPhenomenon)
            pinCitiesWeatherData.append(pinCitiesWeatherDataTemp)
        }
        if index == pinCities.count-1 {
            print("hourForecastCollectionView.reloadData()")
            DispatchQueue.main.async {
                
                self.cityLabel.text = self.currentCity
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let currentTime = Date()
                
                var key = false
                for i in 0..<self.pinCitiesWeatherData[self.currentCityIndex].temperature.count-1 {
                    if let timeString1 = self.pinCitiesWeatherData[self.currentCityIndex].temperature[i].dataTime,
                       let timeString2 = self.pinCitiesWeatherData[self.currentCityIndex].temperature[i+1].dataTime,
                       let time1 = dateFormatter.date(from: timeString1),
                       let time2 = dateFormatter.date(from: timeString2),
                       key == false {
                        let result1 = currentTime.compare(time1)
                        let result2 = currentTime.compare(time2)
                        if result1 == .orderedDescending && result2 == .orderedAscending {
                            key = true
                            let currentTemperature = self.pinCitiesWeatherData[self.currentCityIndex].temperature[i].elementValue[0].value
                            self.currentTemparatureLabel.text = currentTemperature+"°"
                            let currentClimate = self.pinCitiesWeatherData[self.currentCityIndex].weatherPhenomenon[i].elementValue[0].value
                            self.currentClimateLabel.text = currentClimate
                            var maxTemperature = -999
                            var minTemperature = 999
                            for i in 0..<8 {
                                if let currentTemperature = Int(self.pinCitiesWeatherData[self.currentCityIndex].temperature[i].elementValue[0].value) {
                                    if currentTemperature > maxTemperature {
                                        maxTemperature = currentTemperature
                                    }
                                    if currentTemperature < minTemperature {
                                        minTemperature = currentTemperature
                                    }
                                    self.temparatureIntervalLabel.text = "H:\(maxTemperature)° L:\(minTemperature)°"
                                }
                            }
                        }
                    }
                    
                }
                self.hourForecastCollectionView.reloadData()
            }
        }
        
    }
    
    //            DispatchQueue.main.async {
    //                self.cityLabel.text = locationName
    //            }
    
    func checkLocationAuth() {
        
        let authorizationStatus: CLAuthorizationStatus
        
        if #available(iOS 14, *){
            authorizationStatus = locationMgr.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        switch authorizationStatus {
        case .notDetermined:
            // First time launch app need to get authorize from user
            locationMgr.requestWhenInUseAuthorization()
            locationMgr.startUpdatingLocation()
        case .authorizedWhenInUse:
            locationMgr.startUpdatingLocation()
        case .denied:
            let alertController = UIAlertController(title: "定位權限已關閉", message: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
        default:
            break
        }
        
    }
    
    func reverseGeocoder() {
        let geocoder = CLGeocoder()
        let currentLocation = CLLocation(latitude: currentLat, longitude: currentLon)
        //        print(currentLocation)
        print(NSLocale.current)
        let locale = Locale(identifier: "zh_TW")
        geocoder.reverseGeocodeLocation(currentLocation, preferredLocale: locale) { placemarks, error -> Void in
            if error != nil {
                print("ReverseGeocoder Error: ", error!.localizedDescription)
                return
            }
            
            guard let placemark = placemarks?.first else {
                return
            }
            
            if let placemark = placemarks?[0],
               let cityName = placemark.locality {
                self.currentCity = cityName
                print("cityName: ", cityName)
            }
        }
    }
    
    func startTimer() {
        let timer = Timer(fire: Date(), interval: 60, repeats: true) { timer in
            self.checkTime()
        }
        RunLoop.current.add(timer, forMode: .default)
        timer.tolerance = 0.1
    }
    
    func checkTime() {
        let now = Date()
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: now)
        if minute == 0 {
            // 每到整點更新天氣資訊
        }
    }
    
    @IBAction func tappedTestButton() {
        //        getCityWeatherData(cityName: "彰化縣")
        reverseGeocoder()
    }
    
}

extension WeatherViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth: CGFloat = 70
        let cellHeight = hourForecastCollectionView.bounds.height
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}

extension WeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("pinCitiesWeatherData.count:", pinCitiesWeatherData.count)
        if pinCitiesWeatherData.count == 0 {
            return 0
        } else {
            return pinCitiesWeatherData[currentCityIndex].weatherPhenomenon.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hourclimatecell", for: indexPath) as! WeatherHourClimateCollectionViewCell
        cell.backgroundColor = UIColor.systemGray6
        
        let wx = pinCitiesWeatherData[currentCityIndex].weatherPhenomenon[indexPath.row].elementValue[0].value
        
        switch wx {
        case "晴":
            cell.forecastImageView.image = UIImage(systemName: "sun.max")
        case "陰":
            cell.forecastImageView.image = UIImage(systemName: "cloud.sun")
        case "多雲":
            cell.forecastImageView.image = UIImage(systemName: "cloud")
        case "短暫雨":
            cell.forecastImageView.image = UIImage(systemName: "choud.rain")
        default:
            print("字串", wx)
            }
        let temperature = pinCitiesWeatherData[currentCityIndex].temperature[indexPath.row].elementValue[0].value
        cell.temperatureLabel.text = temperature + "°"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var timeString = ""
        if let time = pinCitiesWeatherData[currentCityIndex].temperature[indexPath.row].startTime {
            timeString = time
        }
        
        if let time = pinCitiesWeatherData[currentCityIndex].temperature[indexPath.row].dataTime {
            timeString = time
        }
        
        if let date = dateFormatter.date(from: timeString) {
            let calendar = Calendar.current
            
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            let hour = calendar.component(.hour, from: date)
            let monthInt = Int(month)
            let dayInt = Int(day)
            let hourInt = Int(hour)
            //            print("Hour: \(hourInt)")
//            if indexPath.row == 0 {
//                cell.timeLabel.text = "NOW"
//            } else
            if hourInt == 0 {
                cell.timeLabel.text = "12AM"
            } else if hourInt == 12 {
                cell.timeLabel.text = "\(hourInt)PM"
            } else if hourInt > 12 {
                cell.timeLabel.text = "\(hourInt-12)PM"
            } else {
                cell.timeLabel.text = String(hourInt)+"AM"
            }
        }
        
        return cell
    }
    
}

extension WeatherViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 40
        } else {
            return 50
        }
    }
    
}

extension WeatherViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayclimatecell", for: indexPath)
        cell.backgroundColor = UIColor.systemGray3
        
        return cell
    }
    
    
}

extension WeatherViewController: CLLocationManagerDelegate {
    
    // 定位改變
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation: CLLocation = locations[0]
        print("didUpdateLocations ", userLocation)
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuth()
    }
    
    
}

extension WeatherViewController: SearchViewControllerDelegate {
    func tappedSearchButton(county: String,city: String) {
        print(#function)
//        getCityWeatherData(countyName: county, cityName: city)
    }
}

