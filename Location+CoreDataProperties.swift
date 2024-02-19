//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by Travis Burns on 2/16/24.
//
//

import Foundation
import CoreData
import CoreLocation


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    //properties
    @NSManaged public var latitude: Double
    @NSManaged public var category: String
    @NSManaged public var date: Date
    @NSManaged public var locationDescription: String
    @NSManaged public var longitude: Double
    @NSManaged public var placemark: CLPlacemark?
    @NSManaged public var photoID: NSNumber?

}

extension Location : Identifiable {

}
