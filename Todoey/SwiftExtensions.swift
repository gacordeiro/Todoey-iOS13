//
//  SwiftExtensions.swift
//  Todoey
//
//  Created by gacordeiro LuizaLabs on 23/04/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit

extension Date {
    static let FORMAT_DATETIME = "yyyy-MM-dd HH:mm:ss"
    func asString(withFormat: String = FORMAT_DATETIME) -> String {
        let format = DateFormatter()
        format.dateFormat = withFormat
        return format.string(from: self)
    }
}

extension String {
    func asUIColor(default: UIColor = K.defaultCellColor) -> UIColor {
        return UIColor.init(hexString: self) ?? K.defaultCellColor
    }
}
