//
//  SearchViewController.swift
//  WeatherApp
//
//  Created by Wang Uiroz on 2023/2/26.
//

import UIKit

protocol SearchViewControllerDelegate {
    func tappedSearchButton(county: String, city: String)
}

class SearchViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var searchController: UISearchController!
    
    var delegate: SearchViewControllerDelegate?
    
    var shouldShowSearchResults = false
    
    // search result
    var filteredArray: [City] = []
    // pin places by user
    var pinCities: [City] = []
    var cityNameArray: [String] = []
    var allCityNameData = AllCityName.shared.allCityName
    var allCountyDomainData = AllCountyDomain.shared.allCityDomain
    var allCityDataArray: [City] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
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

    // MARK: - Table view data source

}

extension SearchViewController: UITableViewDelegate {
    
}

extension SearchViewController: UITableViewDataSource {
    
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultcell", for: indexPath) as! SearchResultTableViewCell
        
        if shouldShowSearchResults {
            let countyName = filteredArray[indexPath.row].countyName
            let cityName = filteredArray[indexPath.row].cityName
            cell.countyNameLabel.text = countyName
            cell.cityNameLabel.text = cityName
        } else {
            cell.countyNameLabel.text = ""
            cell.cityNameLabel.text = ""
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: false)
        
        let countyName = filteredArray[indexPath.row].countyName
        let cityName = filteredArray[indexPath.row].cityName
        delegate?.tappedSearchButton(county: countyName, city: cityName)
        dismiss(animated: true)
        dismiss(animated: true)
    }
    
}

extension SearchViewController: UISearchResultsUpdating {
    
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
//        print(filteredArray)
        tableView.reloadData()
    }
    
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tableView.reloadData()
    }
    
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
    
}
