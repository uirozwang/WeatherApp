//
//  PageViewController.swift
//  WeatherApp
//
//  Created by Wang Uiroz on 2023/3/23.
//

import UIKit

class PageViewController: UIPageViewController {
    
    var pinCities: [City] = []
    var pinCitiesDetail: [CityDetail] = []
    var threeCheck = false
    var sevenCheck = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        loadPinCitiesData()
        getWeatherData()
    }
    
    // 將 Status Bar 修改為 light
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // MARK: - Save & Load
    
    func loadPinCitiesData() {
        
        guard let pinCitiesEncoded = UserDefaults.standard.value(forKey: "pinCities") as? Data else {
            print("Warning: Could not load pinCities data from UserDefaults.")
            pinCities.append(City(countyName: "臺北市", cityName: "中正區"))
            return
        }
        if let data = try? JSONDecoder().decode([City].self, from: pinCitiesEncoded) as [City] {
            self.pinCities = data
        } else {
            print("Error: can't decode data from UserDefaults.")
        }
        if pinCities.isEmpty {
            pinCities.append(City(countyName: "臺北市", cityName: "中正區"))
        }
    }
    
    func savePinCitiesData() {
        if let data = try? JSONEncoder().encode(pinCities) {
            UserDefaults.standard.set(data, forKey: "pinCities")
        } else {
            print("Error: can't encode data")
        }
    }
    
    func getWeatherData() {
        for i in 0..<pinCities.count {
            let detail = CityDetail(countyName: pinCities[i].countyName, cityName: pinCities[i].cityName)
            detail.getThreeDaysCityWeatherData {
                if self.sevenCheck && i == 0 {
                    DispatchQueue.main.async {
                        self.setViewControllers([self.createWeatherViewController(forPage: 0)], direction: .forward, animated: false)
                    }
                } else {
                    self.threeCheck = true
                }
            }
            detail.getSevenDaysCityWeatherData {
                if self.threeCheck && i == 0 {
                    DispatchQueue.main.async {
                        self.setViewControllers([self.createWeatherViewController(forPage: 0)], direction: .forward, animated: false)
                    }
                } else {
                    self.sevenCheck = true
                }
            }
            pinCitiesDetail.append(detail)
        }
    }
    
    func createWeatherViewController(forPage page: Int) -> WeatherViewController {
        let weatherViewController = storyboard!.instantiateViewController(withIdentifier: "weatherviewcontroller") as! WeatherViewController
        weatherViewController.currentCityIndex = page
        return weatherViewController
    }
}

extension PageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let currentViewController = viewController as? WeatherViewController {
            if currentViewController.currentCityIndex > 0 {
                return createWeatherViewController(forPage: currentViewController.currentCityIndex-1)
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let currentViewController = viewController as? WeatherViewController {
            if currentViewController.currentCityIndex < pinCities.count - 1 {
                return createWeatherViewController(forPage: currentViewController.currentCityIndex+1)
            }
        }
        return nil
    }
    
}

extension PageViewController: ListViewControllerDelegate {
    func saveData() {
        savePinCitiesData()
    }
    func switchTo(page: Int) {
        setViewControllers([createWeatherViewController(forPage: page)], direction: .forward, animated: false)
    }
    func updateData(pinCities: [City], pinCitiesDetail: [CityDetail]) {
        self.pinCities = pinCities
        self.pinCitiesDetail = pinCitiesDetail
        savePinCitiesData()
    }
}
