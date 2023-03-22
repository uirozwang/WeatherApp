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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var hourForecastCollectionView: UICollectionView!
    @IBOutlet weak var dayForecastTableView: UITableView!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    let opendataAuth = "CWB-77C0E18C-8CFF-40CB-9335-BCB226CFF4DE"
    
    let countiesDomain = AllCountyDomain.shared.allCityDomain
    
    var weatherThreeDaysResultData: [WeatherResult] = []
    var weatherSevenDaysResultData: [WeatherResult] = []
    
    // 當前顯示的城市，0代表GPS定位
    var currentCityIndex: Int = 0
    
    // default location, NCUE
    var currentLat = 24.081013
    var currentLon = 120.558316
    var currentCounty = ""
    var currentCity = ""
    let delayInSeconds: TimeInterval = 0
    let textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    
    // index 0 is location, other places is set by user
    var pinCities: [City] = []
    var pinCitiesThreeDaysWeatherData: [CityThreeDaysWeatherData] = []
    var pinCitiesSevenDaysWeatherData: [CitySevenDaysWeatherData] = []
    
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
        checkFirstLaunch()
        configureInterface()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuth()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationMgr.stopUpdatingLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hourForecastCollectionView.frame.size.width = scrollView.frame.width-40
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchVC" {
            let vc = segue.destination as? SearchViewController
            vc?.delegate = self
        }
    }
    
    func checkFirstLaunch() {
        
        let defaults = UserDefaults.standard
        // 檢查是否第一次啟動
        if !defaults.bool(forKey: "HasLaunchedBefore") {
            // 第一次啟動
            defaults.set(true, forKey: "HasLaunchedBefore")
            pinCities = [City(countyName: "新北市", cityName: "中和區")]
            do {
                let data = try JSONEncoder().encode(pinCities)
                UserDefaults.standard.set(data, forKey: "pinCities")
            } catch {
                print("Encoding error", error)
            }
        } else {
            loadPinCitiesData()
        }
    }
    
    func configureInterface() {
        
        view.backgroundColor = UIColor(red: 78/255, green: 98/255, blue: 120/255, alpha: 1)
        
        cityLabel.textColor = textColor
        currentTemparatureLabel.textColor = textColor
        currentClimateLabel.textColor = textColor
        temparatureIntervalLabel.textColor = textColor
        searchButton.tintColor = textColor
        locationButton.tintColor = textColor
        
        dayForecastTableView.sectionHeaderTopPadding = 0
        
        hourForecastCollectionView.frame.size.width = scrollView.frame.size.width-40
        
        hourForecastCollectionView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        dayForecastTableView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        hourForecastCollectionView.layer.cornerRadius = 13
        dayForecastTableView.layer.cornerRadius = 13
        
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
            let okAction = UIAlertAction(title: "OK", style: .default) { action in
                self.getPinCitiesWeatherData()
            }
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
        //        print(NSLocale.current)
        let locale = Locale(identifier: "zh_TW")
        geocoder.reverseGeocodeLocation(currentLocation, preferredLocale: locale) { placemarks, error -> Void in
            if error != nil {
                print("ReverseGeocoder Error: ", error!.localizedDescription)
                return
            }
            
            guard (placemarks?.first) != nil else {
                return
            }
            
            if let placemark = placemarks?[0],
               let cityName = placemark.locality,
               let countyName = placemark.subAdministrativeArea {
                self.currentCity = cityName
                self.currentCounty = countyName
                self.pinCities[0] = City(countyName: countyName, cityName: cityName)
                self.getPinCitiesWeatherData()
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
        // 停止它，否則會報錯，似乎也可以用performBatchUpdates(_:completion:)來解決
        hourForecastCollectionView.setContentOffset(hourForecastCollectionView.contentOffset, animated: false)
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
        if pinCitiesThreeDaysWeatherData.count == 0 {
            return 0
        } else {
            return pinCitiesThreeDaysWeatherData[currentCityIndex].weatherPhenomenon.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hourclimatecell", for: indexPath) as! WeatherHourClimateCollectionViewCell
        
        cell.timeLabel.textColor = textColor
        cell.temperatureLabel.textColor = textColor
        
        let wx = pinCitiesThreeDaysWeatherData[currentCityIndex].weatherPhenomenon[indexPath.row].elementValue[0].value
        switch wx {
        case "晴":
            cell.forecastImageView.image = UIImage(systemName: "sun.max.fill")?.withRenderingMode(.alwaysOriginal)
        case "陰":
            cell.forecastImageView.image = UIImage(systemName: "cloud.sun.fill")?.withRenderingMode(.alwaysOriginal)
        case "多雲":
            cell.forecastImageView.image = UIImage(systemName: "cloud.fill")?.withRenderingMode(.alwaysOriginal)
        case "短暫雨":
            cell.forecastImageView.image = UIImage(systemName: "cloud.rain.fill")?.withRenderingMode(.alwaysOriginal)
        case "短暫陣雨":
            cell.forecastImageView.image = UIImage(systemName: "cloud.rain.fill")?.withRenderingMode(.alwaysOriginal)
        case "短暫陣雨或雷雨":
            cell.forecastImageView.image = UIImage(systemName: "cloud.bolt.rain.fill")?.withRenderingMode(.alwaysOriginal)
        default:
            print("字串", wx)
        }
        let temperature = pinCitiesThreeDaysWeatherData[currentCityIndex].temperature[indexPath.row].elementValue[0].value
        cell.temperatureLabel.text = temperature + "°"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var timeString = ""
        if let time = pinCitiesThreeDaysWeatherData[currentCityIndex].temperature[indexPath.row].startTime {
            timeString = time
        }
        
        if let time = pinCitiesThreeDaysWeatherData[currentCityIndex].temperature[indexPath.row].dataTime {
            timeString = time
        }
        
        if let date = dateFormatter.date(from: timeString) {
            let calendar = Calendar.current
            
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            let hour = calendar.component(.hour, from: date)
            //            let monthInt = Int(month)
            //            let dayInt = Int(day)
            let hourInt = Int(hour)
            //            print("Hour: \(hourInt)")
            //            if indexPath.row == 0 {
            //                cell.timeLabel.text = "NOW"
            //            } else
            if hourInt == 0 {
                cell.timeLabel.text = "\(month)/\(day)\n12AM"
            } else if hourInt == 12 {
                cell.timeLabel.text = "\(month)/\(day)\n\(hourInt)PM"
            } else if hourInt > 12 {
                cell.timeLabel.text = "\(month)/\(day)\n\(hourInt-12)PM"
            } else {
                cell.timeLabel.text = "\(month)/\(day)\n"+String(hourInt)+"AM"
            }
        }
        return cell
    }
}

extension WeatherViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        35
    }
    
}

extension WeatherViewController: UITableViewDataSource {
    
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //        let view = tableView.tableHeaderView as! WeatherDayClimateTableViewHeaderView
    //        view.titleLabel.textColor = textColor
    //        return view
    //    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayclimatecell", for: indexPath) as! WeatherDayClimateTableViewCell
        
        cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        
        cell.weekLabel.textColor = textColor
        cell.lowTemperatureLabel.textColor = textColor
        cell.highTemperatureLabel.textColor = textColor
        
        if pinCitiesSevenDaysWeatherData.count == 0 {
            cell.weekLabel.text = "N/A"
            cell.lowTemperatureLabel.text = "N/A"
            cell.highTemperatureLabel.text = "N/A"
            return cell
        }
        let currentDate = Date()
        let calendar = Calendar.current
        if let day = calendar.date(byAdding: .day, value: indexPath.row, to: currentDate) {
            let weekday = calendar.component(.weekday, from: day)
            if indexPath.row == 0 {
                cell.weekLabel.text = "Today"
            } else {
                cell.weekLabel.text = AllWeekday.shared.allWeekday[weekday-1]
            }
            let (min, max) = getMinAndMaxTemperature(date: day)
            let (sevenMin, sevenMax) = getSevenDayMinAndMaxTemperature()
            
            if min == 999 && max == -999 {
                cell.lowTemperatureLabel.text = "N/A"
                cell.highTemperatureLabel.text = "N/A"
                cell.lineView.isHidden = true
                cell.weatherImageView.isHidden = true
            } else {
                cell.lowTemperatureLabel.text = String(min)+"°"
                cell.highTemperatureLabel.text = String(max)+"°"
                cell.lineView.isHidden = false
                cell.weatherImageView.isHidden = false
            }
            
            let sevneMinDouble = Double(sevenMin)
            let sevneMaxDouble = Double(sevenMax)
            let minDouble = Double(min)
            let maxDouble = Double(max)
            
            let left = (minDouble-sevneMinDouble)/(sevneMaxDouble-sevneMinDouble)
            let right = (maxDouble-minDouble)/(sevneMaxDouble-sevneMinDouble)
            
            cell.lineView.widthLeft = left
            cell.lineView.widthRight = right
            
            let wx = getWeatherPhenomenonForDate(date: currentDate)
            
            cell.weatherImageView.image = UIImage(systemName: wx)?.withRenderingMode(.alwaysOriginal)
        } else {
            print("day climate tableview day calculation failure")
        }
        return cell
    }
    
    
}

extension WeatherViewController: CLLocationManagerDelegate {
    
    // 定位改變
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation: CLLocation = locations[0]
        print("didUpdateLocations ", userLocation)
//        reverseGeocoder()
        //        getPinCitiesWeatherData()
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuth()
    }
    
    
}

extension WeatherViewController: SearchViewControllerDelegate {
    func tappedSearchButton(county: String,city: String) {
        pinCities = [City(countyName: county, cityName: city)]
        savePinCitiesData()
        getPinCitiesWeatherData()
    }
}

extension WeatherViewController {
    
    // MARK: - Save & Load

    func savePinCitiesData() {
        do {
            let data = try JSONEncoder().encode(pinCities)
            UserDefaults.standard.set(data, forKey: "pinCities")
        } catch {
            print("Encoding error", error)
        }
    }
    
    func loadPinCitiesData() {
        if let data = UserDefaults.standard.data(forKey: "pinCities") {
            do {
                let data = try JSONDecoder().decode([City].self, from: data)
                self.pinCities = data
                getPinCitiesWeatherData()
            } catch {
                print("Decoding error:", error)
            }
        }
    }
    
    // MARK: - CallAPI & Organize Data
    
    // 考量到有可能只更新一個資料的情況，所做的保留
    func getPinCitiesWeatherData() {
        weatherThreeDaysResultData = []
        pinCitiesThreeDaysWeatherData = []
        
        weatherSevenDaysResultData = []
        pinCitiesSevenDaysWeatherData = []
        
        let dispatchGroup = DispatchGroup()
        
        for i in 0..<pinCities.count {
            dispatchGroup.enter()
            dispatchGroup.enter()
            getThreeDaysCityWeatherData(index: i, dispatchGroup: dispatchGroup)
            getSevenDaysCityWeatherData(index: i, dispatchGroup: dispatchGroup)
        }
        
        dispatchGroup.notify(queue: .main) {
            self.organizeThreeDaysResultAllData()
            self.organizeSevenDaysResultAllData()
        }
        
    }
    
    func organizeThreeDaysResultAllData() {
        for i in 0..<pinCities.count {
            organizeThreeDaysResultData(index: i)
        }
    }
    
    func organizeSevenDaysResultAllData() {
        for i in 0..<pinCities.count {
            organizeSevenDaysResultData(index: i)
        }
    }
    
    func getThreeDaysCityWeatherData(index: Int, dispatchGroup: DispatchGroup) {
        var dayDomain = ""
        
        for county in countiesDomain {
            if county.chineseName == pinCities[index].countyName {
                dayDomain = county.dayDomain
            }
        }
        
        var dayRequest = URLRequest(url: URL(string: "https://opendata.cwb.gov.tw/api/v1/rest/datastore/\(dayDomain)?Authorization=\(opendataAuth)")!,timeoutInterval: Double.infinity)
        dayRequest.addValue("TS01a5ae52=0107dddfefa99779413a2b3bda072beac3f035ffa20639b0e7758f3923825255ae45862654dd0722657e7154c272801968bba8bc9f", forHTTPHeaderField: "Cookie")
        
        dayRequest.httpMethod = "GET"
        
        let task1 = URLSession.shared.dataTask(with: dayRequest) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            //            print(String(data: data, encoding: .utf8)!)
            do {
                let result = try JSONDecoder().decode(WeatherResult.self, from: data)
                //                print(result)
                self.weatherThreeDaysResultData.append(result)
                dispatchGroup.leave()
//                if index == self.pinCities.count-1 {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + self.delayInSeconds) {
//                        self.organizeThreeDaysResultAllData()
//                    }
//                }
            } catch {
                print(error)
            }
        }
        task1.resume()
    }
    
    func getSevenDaysCityWeatherData(index: Int, dispatchGroup: DispatchGroup) {
        var weekDomain = ""
        
        for county in countiesDomain {
            if county.chineseName == pinCities[index].countyName {
                weekDomain = county.weekDomain
            }
        }
        var weekRequest = URLRequest(url: URL(string: "https://opendata.cwb.gov.tw/api/v1/rest/datastore/\(weekDomain)?Authorization=\(opendataAuth)")!,timeoutInterval: Double.infinity)
        weekRequest.addValue("TS01a5ae52=0107dddfefa99779413a2b3bda072beac3f035ffa20639b0e7758f3923825255ae45862654dd0722657e7154c272801968bba8bc9f", forHTTPHeaderField: "Cookie")
        
        weekRequest.httpMethod = "GET"
        
        let task2 = URLSession.shared.dataTask(with: weekRequest) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            //            print(String(data: data, encoding: .utf8)!)
            do {
                let result = try JSONDecoder().decode(WeatherResult.self, from: data)
                //                print(result)
                self.weatherSevenDaysResultData.append(result)
                dispatchGroup.leave()
//                if index == self.pinCities.count-1 {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + self.delayInSeconds) {
//                        self.organizeSevenDaysResultAllData()
//                    }
//                }
            } catch {
                print(error)
            }
        }
        task2.resume()
    }
    
    func organizeThreeDaysResultData(index: Int) {
        
        if let records = weatherThreeDaysResultData[index].records,
           let county = records.locations,
           let cities = county[0].location {
            let cityName = pinCities[index].cityName
            var citiesIndex = 999
            for i in 0..<cities.count {
                if cities[i].locationName == cityName {
                    citiesIndex = i
                }
            }
            
            if citiesIndex == 999 {
                print("no city to origanize")
                return
            }
            let elements = cities[citiesIndex].weatherElement!
            
            var pinCitiesWeatherDataTemp = CityThreeDaysWeatherData(probabilityofPrecipitation12h: [],
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
            pinCitiesThreeDaysWeatherData.append(pinCitiesWeatherDataTemp)
        }
        if index == pinCities.count-1 {
            DispatchQueue.main.async {
                
                self.cityLabel.text = self.pinCities[self.currentCityIndex].cityName
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let currentTime = Date()
                
                var key = false
                for i in 0..<self.pinCitiesThreeDaysWeatherData[self.currentCityIndex].temperature.count {
                    if i < self.pinCitiesThreeDaysWeatherData[self.currentCityIndex].temperature.count-1,
                       let timeString1 = self.pinCitiesThreeDaysWeatherData[self.currentCityIndex].temperature[i].dataTime,
                       let timeString2 = self.pinCitiesThreeDaysWeatherData[self.currentCityIndex].temperature[i+1].dataTime,
                       let time1 = dateFormatter.date(from: timeString1),
                       let time2 = dateFormatter.date(from: timeString2),
                       key == false {
                        let result1 = currentTime.compare(time1)
                        let result2 = currentTime.compare(time2)
                        if result1 == .orderedDescending && result2 == .orderedAscending {
                            key = true
                            let currentTemperature = self.pinCitiesThreeDaysWeatherData[self.currentCityIndex].temperature[i].elementValue[0].value
                            self.currentTemparatureLabel.text = currentTemperature+"°"
                            let currentClimate = self.pinCitiesThreeDaysWeatherData[self.currentCityIndex].weatherPhenomenon[i].elementValue[0].value
                            self.currentClimateLabel.text = currentClimate
                            var maxTemperature = -999
                            var minTemperature = 999
                            for i in 0..<8 {
                                if let currentTemperature = Int(self.pinCitiesThreeDaysWeatherData[self.currentCityIndex].temperature[i].elementValue[0].value) {
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
                // 當第一筆資料已經不包含當前天氣時才會啟用
                if key == false {
                    let currentTemperature = self.pinCitiesThreeDaysWeatherData[self.currentCityIndex].temperature[0].elementValue[0].value
                    self.currentTemparatureLabel.text = currentTemperature+"°"
                    let currentClimate = self.pinCitiesThreeDaysWeatherData[self.currentCityIndex].weatherPhenomenon[0].elementValue[0].value
                    self.currentClimateLabel.text = currentClimate
                    var maxTemperature = -999
                    var minTemperature = 999
                    for i in 0..<8 {
                        if let currentTemperature = Int(self.pinCitiesThreeDaysWeatherData[self.currentCityIndex].temperature[i].elementValue[0].value) {
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
                
                self.hourForecastCollectionView.reloadData()
                self.dayForecastTableView.reloadData()
            }
        }
    }
    
    func organizeSevenDaysResultData(index: Int) {
        
        if let records = weatherSevenDaysResultData[index].records,
           let county = records.locations,
           let cities = county[0].location {
            let cityName = pinCities[index].cityName
            var citiesIndex = 999
                for i in 0..<cities.count {
                if cities[i].locationName == cityName {
                    citiesIndex = i
                }
            }
            
            if citiesIndex == 999 {
                print("no city to origanize")
                return
            }
            let elements = cities[citiesIndex].weatherElement!
            
            var pinCitiesWeatherDataTemp = CitySevenDaysWeatherData(probabilityofPrecipitation12h: [], averageTemperature: [], averageRelativeHumidity: [], minComfortIndex: [], windSpeed: [], maxApparentTemperature: [], weatherPhenomenon: [], maxComfortIndex: [], minTemperature: [], ultravioletIndex: [], weatherDescription: [], minApparentTemperature: [], maxTemperature: [], windDirection: [], averageDewPointTemperature: [])
            
            //            let dateFormatter = DateFormatter()
            //            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            //            let currentTime = Date()
            //            let currentTimeString = dateFormatter.string(from: currentTime)
            
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
                    pinCitiesWeatherDataTemp.probabilityofPrecipitation12h = elementValues
                case "T":
                    pinCitiesWeatherDataTemp.averageTemperature = elementValues
                case "RH":
                    pinCitiesWeatherDataTemp.averageRelativeHumidity = elementValues
                case "MinCI":
                    pinCitiesWeatherDataTemp.minComfortIndex = elementValues
                case "WS":
                    pinCitiesWeatherDataTemp.windSpeed = elementValues
                case "MaxAT":
                    pinCitiesWeatherDataTemp.maxApparentTemperature = elementValues
                case "Wx":
                    pinCitiesWeatherDataTemp.weatherPhenomenon = elementValues
                case "MaxCI":
                    pinCitiesWeatherDataTemp.maxComfortIndex = elementValues
                case "MinT":
                    pinCitiesWeatherDataTemp.minTemperature = elementValues
                case "UVI":
                    pinCitiesWeatherDataTemp.ultravioletIndex = elementValues
                case "WeatherDescription":
                    pinCitiesWeatherDataTemp.weatherDescription = elementValues
                case "MinAT":
                    pinCitiesWeatherDataTemp.minApparentTemperature = elementValues
                case "MaxT":
                    pinCitiesWeatherDataTemp.maxTemperature = elementValues
                case "WD":
                    pinCitiesWeatherDataTemp.windDirection = elementValues
                case "Td":
                    pinCitiesWeatherDataTemp.averageDewPointTemperature = elementValues
                default:
                    if let elementName = elements[i].elementName {
                        print("Organize data error, element name:", elementName)
                    } else {
                        print("Organize error, unknown data")
                    }
                }
            }
            pinCitiesSevenDaysWeatherData.append(pinCitiesWeatherDataTemp)
        }
        if index == pinCities.count-1 {
            DispatchQueue.main.async {
                self.hourForecastCollectionView.reloadData()
                self.dayForecastTableView.reloadData()
            }
        }
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
        
        for i in 0..<pinCitiesSevenDaysWeatherData[currentCityIndex].minTemperature.count {
            if let timeString = pinCitiesSevenDaysWeatherData[currentCityIndex].minTemperature[i].startTime,
               let minTemperature = Int(pinCitiesSevenDaysWeatherData[currentCityIndex].minTemperature[i].elementValue[0].value),
               let maxTemperature = Int(pinCitiesSevenDaysWeatherData[currentCityIndex].maxTemperature[i].elementValue[0].value),
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
        
        for i in 0..<pinCitiesSevenDaysWeatherData[currentCityIndex].minTemperature.count {
            if let timeString = pinCitiesSevenDaysWeatherData[currentCityIndex].minTemperature[i].startTime,
               let minTemperature = Int(pinCitiesSevenDaysWeatherData[currentCityIndex].minTemperature[i].elementValue[0].value),
               let maxTemperature = Int(pinCitiesSevenDaysWeatherData[currentCityIndex].maxTemperature[i].elementValue[0].value),
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
        
        for i in 0..<pinCitiesSevenDaysWeatherData[currentCityIndex].weatherPhenomenon.count {
            if let timeString = pinCitiesSevenDaysWeatherData[currentCityIndex].weatherPhenomenon[i].startTime,
               let dataDate = dateFormatter.date(from: timeString) {
                let dataYear = calendar.component(.year, from: dataDate)
                let dataMonth = calendar.component(.month, from: dataDate)
                let dataDay = calendar.component(.day, from: dataDate)
                let dataHour = calendar.component(.hour, from: dataDate)
                var wx = WeatherType.undefined
                
                if dataYear == todayYear && dataMonth == todayMonth && dataDay == todayDay && dataHour == 6 {
                    if let weatherType = WeatherType(rawValue: pinCitiesSevenDaysWeatherData[currentCityIndex].weatherPhenomenon[i].elementValue[0].value) {
                        wx = weatherType
                    }
                } else {
                    // 沒資料，顯示第一筆
                    if let weatherType = WeatherType(rawValue: pinCitiesSevenDaysWeatherData[currentCityIndex].weatherPhenomenon[0].elementValue[0].value) {
                        wx = weatherType
                    }
                }
                return wx.iconName
            }
        }
        print("something error getWeatherPhenomenonForDate(date: Date)")
        return "questionmark.square.fill"
    }
    
}
