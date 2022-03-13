//
//  Record+CoreDataProperties.swift
//  Recording
//
//  Created by Md Hosne Mobarok on 11/1/22.
//
//

import Foundation
import CoreData


extension Record {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Record> {
        return NSFetchRequest<Record>(entityName: "Record")
    }

    @NSManaged public var name: String?
    @NSManaged public var soundData: Data?
    @NSManaged public var recordingTime: String?
    @NSManaged public var recordingDuration: String?

}

extension Record : Identifiable {

}


