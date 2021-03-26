//
//  WeatherViewModel.swift
//  Weather forecast
//
//  Created by RajeshKumar on 24/03/21.
//

import Foundation
import UIKit.UIImage

public class WeatherViewModel {
  private static let defaultAddress = "Kolar, Karnataka"
  
  private let geocoder = LocationGeocoder()
  var city = ""
  let locationName = Box("Loading..")
  let date = Box(" ")
  let icon: Box<UIImage?> = Box(nil)
  let summary = Box(" ")
  let forecastSummary = Box(" ")
  let tempFormat = Box("")
  
  
  private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, MMM d"
    return dateFormatter
  }()
  
  private let tempFormatter: NumberFormatter = {
    let tempFormatter = NumberFormatter()
    tempFormatter.numberStyle = .none
    return tempFormatter
  }()
  
  init() {
    changeLocation(to: Self.defaultAddress)
  }
  
    func getLocationData(to newLocation: String){
        self.flushApiValues()
        self.checkLocationInHistory(location: newLocation)
    }
  
  func changeLocation(to newLocation: String){
    locationName.value = "Loading..."
    self.city = newLocation
    
    geocoder.geocode(addressString: newLocation) { [weak self] (locations) in
      
      guard let self = self else {
        return
      }
      
      self.flushApiValues()
      if let location = locations.first {
        self.locationName.value = location.name
        self.fetchWeatherForLocation(location)
        
        return
      }
    }
  }
  
  func flushApiValues(){
    self.locationName.value = "Not Found"
    self.date.value = ""
    self.icon.value = nil
    self.summary.value = ""
    self.forecastSummary.value = ""
    self.tempFormat.value = ""
  }
  
  private func fetchWeatherForLocation(_ location: Location) {
    WeatherbitService.weatherDataForLocation(
      latitude: location.latitude,
      longitude: location.longitude) { [weak self] (weatherData, error) in
      guard
        let self = self,
        let weatherData = weatherData
      else {
        return
      }
      print(weatherData)
      self.date.value = self.dateFormatter.string(from: weatherData.date)
      self.icon.value = UIImage(named: weatherData.iconName)
      let tempFormat = self.tempFormatter.string(from: weatherData.currentTemp as NSNumber) ?? ""
      self.summary.value = "\(weatherData.description)"
      self.tempFormat.value = "\(String(describing: tempFormat))°"
      self.forecastSummary.value = "\nSummary: \(weatherData.description)"
      CoreDataManager.shared.createHistoryData(cityName: self.city.lowercased(), date: self.dateFormatter.string(from: weatherData.date), iconName: weatherData.iconName, tempFormat: self.tempFormatter.string(from: weatherData.currentTemp as NSNumber) ?? "", weatherdescription: "\(weatherData.description)")
    }
  }
    
    func checkLocationInHistory(location : String){
        do{
            guard let result = try PersistentStorage.shared.context.fetch(CityWeatherData.fetchRequest()) as? [CityWeatherData] else {return}
            for r in result{
                if (r.cityName == location.lowercased()){
                    self.locationName.value = location.capitalized
                    self.date.value = r.date ?? ""
                    self.icon.value = UIImage(named: r.iconName ?? "c02d")
                    self.summary.value = r.weatherdescription ?? ""
                    self.forecastSummary.value = r.weatherdescription ?? ""
                    self.tempFormat.value = ("\(r.tempFormat ?? "")°")
                    break
                }
            }
            print(result)
        }catch let error{
            debugPrint(error)
        }
    }
  
}
