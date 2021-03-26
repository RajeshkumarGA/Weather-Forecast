//
//  FavoriteDestinationsData+CoreDataProperties.swift
//  Weather forecast
//
//  Created by RajeshKumar on 25/03/21.
//
//

import Foundation
import CoreData


extension FavoriteDestinationsData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteDestinationsData> {
        return NSFetchRequest<FavoriteDestinationsData>(entityName: "FavoriteDestinationsData")
    }

    @NSManaged public var cityname: String?

}

extension FavoriteDestinationsData : Identifiable {

}
