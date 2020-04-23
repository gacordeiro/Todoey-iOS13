//
//  Item.swift
//  Todoey
//
//  Created by gacordeiro LuizaLabs on 18/02/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class ToDoItem: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: ToDoCategory.self, property: "items")
}
