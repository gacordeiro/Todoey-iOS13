//
//  RealmData.swift
//  Todoey
//
//  Created by gacordeiro LuizaLabs on 18/02/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class ToDoCategory: Object {
    @objc dynamic var name: String = ""
    let items = List<ToDoItem>()
}
