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
    @IBOutlet weak var pageControl: UIPageControl!
    
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
    var pinCityDetail: CityDetail!
    var tempCity: City!
    var addState = false
    var repeatState = false
    
    var locationMgr: CLLocationManager!
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.isDescendant(of: self.pageControl) {
                return
            }
        // 更新 pagecontrol 的當前頁面
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        self.pageControl.currentPage = currentPage
        
        let offsetY = scrollView.contentOffset.y
        let distance: CGFloat = 50 // 设置行距
        let alpha = 1 - max(min(offsetY / distance, 1.0), 0.0)
        temparatureIntervalLabel.alpha = alpha
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
        if !addState && currentCityIndex == 0 {
            locationButton.isHidden = false
        } else {
            locationButton.isHidden = true
        }
        
        startTimer()
        configureInterface()
        updateInterface()
        
        if currentCityIndex == 0 && !addState {
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
            if let listViewController = segue.destination as? ListViewController,
               let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let pageViewController = windowScene.windows.first?.rootViewController as? PageViewController {
                listViewController.delegate = pageViewController
                listViewController.pinCities = pageViewController.pinCities
                listViewController.pinCities[0] = City(countyName: self.pinCityDetail.countyName,
                                                       cityName: self.pinCityDetail.cityName)
                listViewController.pinCitiesDetail = pageViewController.pinCitiesDetail
                listViewController.pinCitiesDetail[0] = self.pinCityDetail
                dismiss(animated: false)
            }
        }
    }
    
    func manualUpdate() {
        pinCityDetail.getThreeDaysCityWeatherData {
            DispatchQueue.main.async {
                self.cityLabel.text = self.pinCityDetail.cityName
                self.currentTemparatureLabel.text = self.pinCityDetail.currentTemperature
                self.currentClimateLabel.text = self.pinCityDetail.currentClimate
                self.temparatureIntervalLabel.text = "H: "+self.pinCityDetail.currentMaxTemperature + "° L: " + self.pinCityDetail.currentMinTemperature + "°"
                self.hourForecastCollectionView.reloadData()
            }
        }
        pinCityDetail.getSevenDaysCityWeatherData {
            DispatchQueue.main.async {
                self.dayForecastTableView.reloadData()
            }
        }
        
    }
    
    func updateInterface() {
        if addState {
            pinCityDetail = CityDetail(countyName: tempCity.countyName, cityName: tempCity.cityName)
            manualUpdate()
        } else {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let pageViewController = windowScene.windows.first?.rootViewController as? PageViewController else {
                fatalError("Unable to retrieve window and/or page view controller")
            }
            pinCityDetail = pageViewController.pinCitiesDetail[currentCityIndex]
            pageControl.numberOfPages = pageViewController.pinCities.count
            pageControl.currentPage = currentCityIndex
            
            self.cityLabel.text = self.pinCityDetail.cityName
            self.currentTemparatureLabel.text = self.pinCityDetail.currentTemperature
            self.currentClimateLabel.text = self.pinCityDetail.currentClimate
            self.temparatureIntervalLabel.text = "H: "+self.pinCityDetail.currentMaxTemperature + "° L: " + self.pinCityDetail.currentMinTemperature + "°"
            self.hourForecastCollectionView.reloadData()
            self.dayForecastTableView.reloadData()
        }
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
        
        pageControl.setCurrentPageIndicatorImage(UIImage(systemName: "location.fill"), forPage: 0)
        pageControl.setIndicatorImage(UIImage(systemName: "location.fill"), forPage: 0)
        
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
        case .authorizedWhenInUse:
            locationMgr.startUpdatingLocation()
            if locationAuth != true {
                updateInterface()
            }
            locationAuth = true
        case .authorizedAlways:
            locationMgr.startUpdatingLocation()
            if locationAuth != true {
                updateInterface()
            }
            locationAuth = true
        case .denied:
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
                self.pinCityDetail = CityDetail(countyName: countyName, cityName: cityName)
                self.manualUpdate()
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
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        // 在3的倍數的整點，主動更新天氣資訊
        if hour%3 == 0 && minute == 0 {
            manualUpdate()
        }
    }
    // MARK: - Actions
    @IBAction func tappedTestButton() {
        // 停止它，否則會報錯，似乎也可以用performBatchUpdates(_:completion:)來解決
        hourForecastCollectionView.setContentOffset(hourForecastCollectionView.contentOffset, animated: false)
        reverseGeocoder()
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
// MARK: - CollectionView
extension WeatherViewController: UICollectionViewDelegateFlowLayout {
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let cellWidth: CGFloat = 70
//        let cellHeight = hourForecastCollectionView.bounds.height
//
//        return CGSize(width: cellWidth, height: cellHeight)
//    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
    
}

extension WeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if pinCityDetail.threeDaysWeatherData.weatherPhenomenon.count == 0 {
            return 0
        } else {
            return pinCityDetail.threeDaysWeatherData.weatherPhenomenon.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hourclimatecell", for: indexPath) as! WeatherHourClimateCollectionViewCell
        
        cell.timeLabel.textColor = textColor
        cell.temperatureLabel.textColor = textColor
        
        var wx = WeatherType.undefined
        if let weatherType = WeatherType(rawValue: pinCityDetail.threeDaysWeatherData.weatherPhenomenon[indexPath.row].elementValue[1].value) {
            wx = weatherType
        }
        cell.forecastImageView.image = UIImage(systemName: wx.iconName)?.withRenderingMode(.alwaysOriginal)
        
        let temperature = pinCityDetail.threeDaysWeatherData.temperature[indexPath.row].elementValue[0].value
        cell.temperatureLabel.text = temperature + "°"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var timeString = ""
        if let time = pinCityDetail.threeDaysWeatherData.temperature[indexPath.row].startTime {
            timeString = time
        }
        
        if let time = pinCityDetail.threeDaysWeatherData.temperature[indexPath.row].dataTime {
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
// MARK: - TableView
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
        if pinCityDetail.sevenDaysWeatherData.minTemperature.count == 0 {
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
            let (min, max) = pinCityDetail.getMinAndMaxTemperature(date: day)
            let (sevenMin, sevenMax) = pinCityDetail.getSevenDayMinAndMaxTemperature()
            
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
//            print(day)
            let wx = pinCityDetail.getWeatherPhenomenonForDate(date: day)
            
            cell.weatherImageView.image = UIImage(systemName: wx)?.withRenderingMode(.alwaysOriginal)
        } else {
            print("day climate tableview day calculation failure")
        }
        return cell
    }
    
}
// MARK: - Location
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
//        let userLocation: CLLocation = locations[0]
//        print("didUpdateLocations ", userLocation)
        reverseGeocoder()
        manualUpdate()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuth()
    }
}
