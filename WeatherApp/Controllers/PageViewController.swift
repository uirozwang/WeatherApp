//
//  PageViewController.swift
//  WeatherApp
//
//  Created by Wang Uiroz on 2023/3/23.
//

import UIKit

class PageViewController: UIPageViewController {
    
    var pinCities: [City] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        loadPinCitiesData()
        setViewControllers([createWeatherViewController(forPage: 0)], direction: .forward, animated: false)
    }
    
    // MARK: - Save & Load
    
    func loadPinCitiesData() {
        
        guard let pinCitiesEncoded = UserDefaults.standard.value(forKey: "pinCities") as? Data else {
            print("Warning: Could not load pinCities data from UserDefaults.")
            pinCities.append(City(countyName: "台北市", cityName: "中正區"))
            return
        }
        if let data = try? JSONDecoder().decode([City].self, from: pinCitiesEncoded) as [City] {
            self.pinCities = data
        } else {
            print("Error: can't decode data from UserDefaults.")
        }
        /*
        if let data = UserDefaults.standard.data(forKey: "pinCities") {
            do {
                let data = try JSONDecoder().decode([City].self, from: data)
                self.pinCities = data
//                getPinCitiesWeatherData()
            } catch {
                print("Decoding error:", error)
            }
        }
        */
        if pinCities.isEmpty {
            pinCities.append(City(countyName: "台北市", cityName: "中正區"))
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
