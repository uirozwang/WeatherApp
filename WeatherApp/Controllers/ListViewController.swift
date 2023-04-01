//
//  SearchViewController.swift
//  WeatherApp
//
//  Created by Wang Uiroz on 2023/2/26.
//

import UIKit

protocol ListViewControllerDelegate {
    func saveData()
    func switchTo(page: Int)
    func updateData(pinCities: [City], pinCitiesDetail: [CityDetail])
}

class ListViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var searchController: UISearchController!
    @IBOutlet var searchBar: UISearchBar!
    
    var delegate: ListViewControllerDelegate?
    
    var shouldShowSearchResults = false
    var selectedIndexPath: IndexPath?
    
    // search result
    var filteredArray: [City] = []
    // pin places by user
    var pinCities: [City] = []
    var pinCitiesDetail: [CityDetail] = []
    var cityNameArray: [String] = []
    var allCityNameData = AllCityName.shared.allCityName
    var allCountyDomainData = AllCountyDomain.shared.allCityDomain
    var allCityDataArray: [City] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = UIColor(red: 78/255, green: 98/255, blue: 120/255, alpha: 1)
        tableView.backgroundColor = UIColor(red: 78/255, green: 98/255, blue: 120/255, alpha: 1)
        
        // 準備廢除
        cityNameArray = AllCityName.shared.allCityName.flatMap{$0}
        configureSearchController()
        // 將資料整合，包含縣市名稱以及搜尋字串相符的計數
        configureCityNameArray()
    }
    
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.barTintColor = UIColor(red: 78/255, green: 98/255, blue: 120/255, alpha: 1)
        searchController.searchBar.searchTextField.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        // change placeholder text color, but icon color not change
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Enter Search Here", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        } else {
            if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
                searchField.attributedPlaceholder = NSAttributedString(string: "Enter Search Here", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
            }
        }
        searchController.searchBar.tintColor = UIColor.white
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func configureCityNameArray() {
        for i in 0..<allCityNameData.count {
            for j in 0..<allCityNameData[i].count {
                let countyName = allCountyDomainData[i].chineseName
                let cityName = allCityNameData[i][j]
                allCityDataArray.append(City(countyName: countyName, cityName: cityName, count: 0))
            }
        }
    }
    
    func savePinCitiesData() {
        do {
            let data = try JSONEncoder().encode(pinCities)
            UserDefaults.standard.set(data, forKey: "pinCities")
        } catch {
            print("Encoding error", error)
        }
    }

}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if shouldShowSearchResults {
            return 40
        } else {
            return 80
        }
    }
}

extension ListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            return filteredArray.count
        } else {
            return pinCities.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if shouldShowSearchResults {
            let cell = tableView.dequeueReusableCell(withIdentifier: "resultcell", for: indexPath) as! SearchResultTableViewCell
            let countyName = filteredArray[indexPath.row].countyName
            let cityName = filteredArray[indexPath.row].cityName
            cell.countyNameLabel.text = countyName
            cell.cityNameLabel.text = cityName
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pinplacecell", for: indexPath) as! SearchPinPlacesTableViewCell
            if indexPath.row == 0 {
                cell.cityNameLabel.text = "當前位置"
                cell.secondLabel.text = pinCitiesDetail[indexPath.row].cityName
            } else {
                cell.cityNameLabel.text = pinCities[indexPath.row].cityName
                cell.secondLabel.text = "\(Date())"
            }
            cell.climateLabel.text = pinCitiesDetail[indexPath.row].threeDaysWeatherData.weatherPhenomenon[0].elementValue[0].value
            cell.currentTemperatureLabel.text = pinCitiesDetail[indexPath.row].threeDaysWeatherData.temperature[0].elementValue[0].value+"°"
            let (min, max) = pinCitiesDetail[indexPath.row].getMinAndMaxTemperature(date: Date())
            cell.minAndMaxTemperatureLabel.text = "H:\(max)° L:\(min)°"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if shouldShowSearchResults {
            searchController.searchBar.resignFirstResponder()
            tableView.deselectRow(at: indexPath, animated: false)
            selectedIndexPath = indexPath
            if let headerView = tableView.tableHeaderView as? UISearchBar {
                headerView.resignFirstResponder()
            }
            let weatherViewController = storyboard!.instantiateViewController(withIdentifier: "weatherviewcontroller") as! WeatherViewController
            weatherViewController.tempCity = filteredArray[indexPath.row]
            weatherViewController.addState = true
            for pinCity in pinCities {
                if filteredArray[indexPath.row].countyName == pinCity.countyName &&
                    filteredArray[indexPath.row].cityName == pinCity.cityName {
                    weatherViewController.repeatState = true
                }
            }
            searchController.isActive = false
            searchController.resignFirstResponder()
            weatherViewController.delegate = self
            weatherViewController.currentCityIndex = indexPath.row
            // 目前這行是因為沒辦法處理searchVC造成崩潰，而決定停用該VC，為後續畫面正常而決定顯示現有的城市，避免畫面異常，讓reloadData延後執行
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                self.shouldShowSearchResults = false
                self.tableView.reloadData()
            }
            present(weatherViewController, animated: true)
        } else {
            // 回傳，並切換到指定頁面
            delegate?.switchTo(page: indexPath.row)
            dismiss(animated: true)
        }
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row == 0 {
            return UISwipeActionsConfiguration()
        } else {
            let action = UIContextualAction(style: .destructive, title: "delete", handler: { action, sourceView, completionHandler in
                self.pinCities.remove(at: indexPath.row)
                self.pinCitiesDetail.remove(at: indexPath.row)
                tableView.reloadData()
                completionHandler(true)
                self.delegate?.updateData(pinCities: self.pinCities, pinCitiesDetail: self.pinCitiesDetail)
            })
            let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: [action])
            return swipeActionsConfiguration
        }
    }
}

extension ListViewController: UISearchResultsUpdating {
    
    // 與搜尋字串相符的字數越多排序越往前
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchString = searchController.searchBar.text else {
            return
        }
        filteredArray = []
        // 與搜尋字串相符的字數
        for i in 0..<allCityDataArray.count {
            allCityDataArray[i].count = 0
            let countyName = allCityDataArray[i].countyName
            let cityName = allCityDataArray[i].cityName
            let name = countyName + cityName
            // 完全相符的直接排第一
            if searchString == name {
                allCityDataArray[i].count!+=10
            }
            for searchCh in searchString {
                for ch in name {
                    if ch == searchCh {
                        allCityDataArray[i].count!+=1
                    }
                }
            }
        }
        // 排除掉count=0的部分
            for i in 0..<allCityDataArray.count {
            if let count = allCityDataArray[i].count {
                if count > 0 {
                    filteredArray.append(allCityDataArray[i])
                }
            }
        }
        // bubble sort
        if filteredArray.count > 1 {
            var len = filteredArray.count
            while(len>1) {
                len-=1
                for i in 0..<len {
                    if let count0 = filteredArray[i].count,
                       let count1 = filteredArray[i+1].count {
                        if count0 < count1 {
                            let temp = filteredArray[i]
                            filteredArray[i] = filteredArray[i+1]
                            filteredArray[i+1] = temp
                        }
                    }
                }
            }
        }
        tableView.reloadData()
    }
    
    
}

extension ListViewController: UISearchBarDelegate {
    
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        shouldShowSearchResults = true
//        tableView.reloadData()
//    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // 也許searchText為空的時候要另外做處理
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableView.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            shouldShowSearchResults = false
        } else {
            shouldShowSearchResults = true
        }
        tableView.reloadData()
    }
    
}

extension ListViewController: WeatherViewControllerDelegate {
    func tappedAddButton(city: City) {
        pinCities.append(city)
        savePinCitiesData()
        pinCitiesDetail.append(CityDetail(countyName: city.countyName, cityName: city.cityName))
        var threeOrSeven: Bool?
        pinCitiesDetail[pinCitiesDetail.count-1].getSevenDaysCityWeatherData {
            if threeOrSeven == false {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                threeOrSeven = true
            }
        }
        pinCitiesDetail[pinCitiesDetail.count-1].getThreeDaysCityWeatherData {
            if threeOrSeven == true {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                threeOrSeven = false
            }
        }
        dismiss(animated: true)
        delegate?.updateData(pinCities: pinCities, pinCitiesDetail: pinCitiesDetail)
    }
}
