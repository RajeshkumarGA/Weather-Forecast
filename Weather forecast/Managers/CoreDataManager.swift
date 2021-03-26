//
//  CoreDataManager.swift
//  Weather forecast
//
//  Created by RajeshKumar on 25/03/21.
//

import Foundation
import CoreData

class CoreDataManager{
    private init(){}
    static let shared = CoreDataManager()
    
    func createFavoriteDestinationsData(cityName : String){
       let data = FavoriteDestinationsData(context: PersistentStorage.shared.context)
        data.cityname = cityName.capitalized
        PersistentStorage.shared.saveContext()
    }
    
    func fetchFavoriteDestinationsData() -> [String]{
        var favoriteDestinationsArr = [String]()
        do{
            guard let result = try PersistentStorage.shared.context.fetch(FavoriteDestinationsData.fetchRequest()) as? [FavoriteDestinationsData] else {return []}
            if result.count > 0{
                result.forEach({guard let city = ($0.cityname) else {return}
                    print(city)
                    favoriteDestinationsArr.append(city.capitalized)
                })
            }
            return favoriteDestinationsArr
        }catch let error{
            debugPrint(error)
            return []
        }
    }
    
    func deleteFavoriteDestinationsData(city : String){
        let context = PersistentStorage.shared.context
        let fetchRequest = NSFetchRequest<FavoriteDestinationsData>(entityName: "FavoriteDestinationsData")
                fetchRequest.predicate = NSPredicate(format:"cityname = %@", city as CVarArg)

        let result = try? context.fetch(fetchRequest)
        let resultData = result as! [NSManagedObject]
        for object in resultData {
            context.delete(object)
        }
        do{
            try context.save()
            print("saved")
        }catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func createHistoryData(cityName : String, date : String, iconName : String, tempFormat : String, weatherdescription : String){
       let data = CityWeatherData(context: PersistentStorage.shared.context)
        data.cityName = cityName
        data.date = date
        data.iconName = iconName
        data.tempFormat = tempFormat
        data.weatherdescription = weatherdescription
        
        PersistentStorage.shared.saveContext()
    }
    
    
}
