//
//  TVShow+CoreDataProperties.swift
//  
//
//  Created by Brian Lim on 1/29/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TVShow {

    @NSManaged var backgroundImg: Data?
    @NSManaged var day: String?
    @NSManaged var plot: String?
    @NSManaged var rated: String?
    @NSManaged var startTime: String?
    @NSManaged var title: String?
    @NSManaged var imgUrl: String?

}
