//
//  CityWeatherData+CoreDataProperties.swift
//  Weather forecast
//
//  Created by RajeshKumar on 25/03/21.
//
//

import Foundation
import CoreData


extension CityWeatherData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CityWeatherData> {
        return NSFetchRequest<CityWeatherData>(entityName: "CityWeatherData")
    }

    @NSManaged public var cityName: String?
    @NSManaged public var date: String?
    @NSManaged public var iconName: String?
    @NSManaged public var currentTemp: String?
    @NSManaged public var weatherdescription: String?
    @NSManaged public var tempFormat: String?

}

extension CityWeatherData : Identifiable {

}
