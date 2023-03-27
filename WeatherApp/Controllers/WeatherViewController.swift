//
//  ViewController.swift
//  WeatherApp
//
//  Created by Wang Uiroz on 2023/2/23.
//

import UIKit
import CoreLocation

protocol WeatherViewControllerDelegate {
    func tappedAddButton(city: City)
}

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var currentTemparatureLabel: UILabel!
    @IBOutlet weak var currentClimateLabel: UILabel!
    @IBOutlet weak var temparatureIntervalLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var hourForecastCollectionView: UICollectionView!
    @IBOutlet weak var dayForecastTableView: UITableView!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var pageControll: UIPageControl!
    
    var delegate: WeatherViewControllerDelegate?
    
    let countiesDomain = AllCountyDomain.shared.allCityDomain
    
    var locationAuth: Bool?
    // default location, NCUE
    var currentLat = 24.081013
    var currentLon = 120.558316
    var currentCounty = ""
    var currentCity = ""
    let delayInSeconds: TimeInterval = 0
    let textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    
    // index 0 is location, other places is set by user
    var currentCityIndex: Int = 0
    var pinCity: CityDetail!
    var tempCity: City!
    var addState = false
    var repeatState = false
    
    var locationMgr: CLLocationManager!
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let distance: CGFloat = 50 // 设置行距
        let alpha = 1 - max(min(offsetY / distance, 1.0), 0.0)
        temparatureIntervalLabel.alpha = alpha
//        print(alpha)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hourForecastCollectionView.delegate = self
        hourForecastCollectionView.dataSource = self
        dayForecastTableView.delegate = self
        dayForecastTableView.dataSource = self
        scrollView.delegate = self
        
        toolbar.isHidden = addState
        if repeatState && addState {
            addButton.isHidden = true
        } else if addState {
            addButton.isHidden = false
        } else {
            addButton.isHidden = true
        }
        cancelButton.isHidden = !addState
        
        startTimer()
        configureInterface()
        updateInterface()
        
        if currentCityIndex == 0 {
            setLocation()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        locationMgr.stopUpdatingLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hourForecastCollectionView.frame.size.width = scrollView.frame.width-40
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showlistvc" {
            if let vc = segue.destination as? ListViewController,
               let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let pageViewController = windowScene.windows.first?.rootViewController as? PageViewController {
                vc.delegate = pageViewController
                vc.pinCities = pageViewController.pinCities
                vc.pinCitiesDetail = pageViewController.pinCitiesDetail
                dismiss(animated: false)
            }
        }
    }
    
    func updateInterface() {

//        let city = pageViewController.pinCities[currentCityIndex]
//        pinCity = CityDetail(countyName: city.countyName, cityName: city.cityName)
        if addState {
            pinCity = CityDetail(countyName: tempCity.countyName, cityName: tempCity.cityName)
            pinCity.getThreeDaysCityWeatherData {
                DispatchQueue.main.async {
                    self.cityLabel.text = self.pinCity.cityName
                    self.currentTemparatureLabel.text = self.pinCity.currentTemperature
                    self.currentClimateLabel.text = self.pinCity.currentClimate
                    self.temparatureIntervalLabel.text = "H: "+self.pinCity.currentMaxTemperature + "° L: " + self.pinCity.currentMinTemperature + "°"
                    self.hourForecastCollectionView.reloadData()
                }
            }
            pinCity.getSevenDaysCityWeatherData {
                DispatchQueue.main.async {
                    self.dayForecastTableView.reloadData()
                }
            }
        } else {
//            let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageViewController
            // 在 iOS 15.0 中，windows 属性已被标记为过时，取而代之的是 UIWindowScene.windows 属性。UIWindowScene 是 iOS 13.0 引入的新类，它代表着一个窗口场景，通常一个应用程序只有一个窗口场景。在一个窗口场景中，可能有多个窗口对象。
            // 这里我们使用了 UIApplication.shared.connectedScenes 方法来获取所有连接的场景，从中取出第一个 UIWindowScene 对象。然后使用 windows 属性来获取该窗口场景中的所有窗口，并从中取出第一个窗口对象。最后使用 rootViewController 属性来获取该窗口的根视图控制器，也就是你要访问的 PageViewController。注意这里我们使用了可选绑定来处理获取对象可能失败的情况。这种方式可以让你避免使用 windows 属性，使你的代码更加兼容 iOS 15.0 以及以后的版本。
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let pageViewController = windowScene.windows.first?.rootViewController as? PageViewController else {
                fatalError("Unable to retrieve window and/or page view controller")
            }
            pinCity = pageViewController.pinCitiesDetail[currentCityIndex]
            pageControll.numberOfPages = pageViewController.pinCities.count
            pageControll.currentPage = currentCityIndex
            
            self.cityLabel.text = self.pinCity.cityName
            self.currentTemparatureLabel.text = self.pinCity.currentTemperature
            self.currentClimateLabel.text = self.pinCity.currentClimate
            self.temparatureIntervalLabel.text = "H: "+self.pinCity.currentMaxTemperature + "° L: " + self.pinCity.currentMinTemperature + "°"
            self.hourForecastCollectionView.reloadData()
            self.dayForecastTableView.reloadData()
        }
        /*
        pinCity.getThreeDaysCityWeatherData {
            DispatchQueue.main.async {
                self.cityLabel.text = self.pinCity.cityName
                self.currentTemparatureLabel.text = self.pinCity.currentTemperature
                self.currentClimateLabel.text = self.pinCity.currentClimate
                self.temparatureIntervalLabel.text = "H: "+self.pinCity.currentMaxTemperature + "° L: " + self.pinCity.currentMinTemperature + "°"
                self.hourForecastCollectionView.reloadData()
            }
        }
        pinCity.getSevenDaysCityWeatherData {
            DispatchQueue.main.async {
                self.dayForecastTableView.reloadData()
            }
        }
         */
        
    }
    
    func configureInterface() {
        
        view.backgroundColor = UIColor(red: 78/255, green: 98/255, blue: 120/255, alpha: 1)
        
        cityLabel.textColor = textColor
        currentTemparatureLabel.textColor = textColor
        currentClimateLabel.textColor = textColor
        temparatureIntervalLabel.textColor = textColor
        addButton.tintColor = textColor
        cancelButton.tintColor = textColor
        locationButton.tintColor = textColor
        toolbar.tintColor = textColor
        toolbar.barTintColor = UIColor(red: 78/255, green: 98/255, blue: 120/255, alpha: 1)
        
        pageControll.setCurrentPageIndicatorImage(UIImage(systemName: "location.fill"), forPage: 0)
        
        pageControll.setCurrentPageIndicatorImage(UIImage(systemName: "sun.fill"), forPage: 1)
        pageControll.setIndicatorImage(UIImage(systemName: "rain.fill"), forPage: 2)
        
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
            if locationAuth != false {
                updateInterface()
            }
            locationAuth = false
            print("notDetermined")
        case .authorizedWhenInUse:
            locationMgr.startUpdatingLocation()
            if locationAuth != true {
                updateInterface()
            }
            locationAuth = true
            print("authorizedWhenInUsed")
        case .authorizedAlways:
            locationMgr.startUpdatingLocation()
            if locationAuth != true {
                updateInterface()
            }
            locationAuth = true
            print("authorizedAlways")
        case .denied:
            print("denied")
            if locationAuth != false {
                updateInterface()
            }
            locationAuth = false
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
//                self.pinCity = City(countyName: countyName, cityName: cityName)
                self.updateInterface()
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
//        hourForecastCollectionView.setContentOffset(hourForecastCollectionView.contentOffset, animated: false)
//        reverseGeocoder()
    }
    @IBAction func tappedListButton() {
        dismiss(animated: true)
        performSegue(withIdentifier: "showlistvc", sender: self)
    }
    @IBAction func tappedAddButton() {
        delegate?.tappedAddButton(city: tempCity)
    }
    @IBAction func tappedCancelButton() {
        dismiss(animated: true)
    }
    
}

extension WeatherViewController: UICollectionViewDelegate {
    
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
        if pinCity.threeDaysWeatherData.weatherPhenomenon.count == 0 {
            return 0
        } else {
            return pinCity.threeDaysWeatherData.weatherPhenomenon.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hourclimatecell", for: indexPath) as! WeatherHourClimateCollectionViewCell
        
        cell.timeLabel.textColor = textColor
        cell.temperatureLabel.textColor = textColor
        
        let wx = pinCity.threeDaysWeatherData.weatherPhenomenon[indexPath.row].elementValue[0].value
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
        let temperature = pinCity.threeDaysWeatherData.temperature[indexPath.row].elementValue[0].value
        cell.temperatureLabel.text = temperature + "°"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var timeString = ""
        if let time = pinCity.threeDaysWeatherData.temperature[indexPath.row].startTime {
            timeString = time
        }
        
        if let time = pinCity.threeDaysWeatherData.temperature[indexPath.row].dataTime {
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
        if pinCity.sevenDaysWeatherData.minTemperature.count == 0 {
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
            let (min, max) = pinCity.getMinAndMaxTemperature(date: day)
            let (sevenMin, sevenMax) = pinCity.getSevenDayMinAndMaxTemperature()
            
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
            
            let wx = pinCity.getWeatherPhenomenonForDate(date: currentDate)
            
            cell.weatherImageView.image = UIImage(systemName: wx)?.withRenderingMode(.alwaysOriginal)
        } else {
            print("day climate tableview day calculation failure")
        }
        return cell
    }
    
}

extension WeatherViewController: CLLocationManagerDelegate {
    
    func setLocation() {
        locationMgr = CLLocationManager()
        // 移動多遠更新座標點
        locationMgr.distanceFilter = kCLLocationAccuracyHundredMeters
        // 定位精準度
        locationMgr.desiredAccuracy = kCLLocationAccuracyKilometer
        locationMgr.delegate = self
    }
    
    // 定位改變
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation: CLLocation = locations[0]
        print("didUpdateLocations ", userLocation)
//        reverseGeocoder()
        //        getPinCitiesWeatherData()
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function)
        checkLocationAuth()
    }
}
