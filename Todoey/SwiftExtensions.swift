//
//  SwiftExtensions.swift
//  Todoey
//
//  Created by gacordeiro LuizaLabs on 23/04/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import ChameleonFramework

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

extension UITableView {
    func setEmptyView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        self.backgroundView = emptyView
    }
    
    func restore() {
        self.backgroundView = nil
    }
}

extension UINavigationController {
    func configureFor(color: UIColor) {
        let contrastColor = ContrastColorOf(color, returnFlat: true)
        let contrastAttrs = [NSAttributedString.Key.foregroundColor : contrastColor]
        
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = contrastAttrs
            navBarAppearance.largeTitleTextAttributes = contrastAttrs
            navBarAppearance.backgroundColor = color
            
            let buttonAppearance = UIBarButtonItemAppearance(style: .plain)
            buttonAppearance.normal.titleTextAttributes = contrastAttrs
            navBarAppearance.buttonAppearance = buttonAppearance
            navBarAppearance.backButtonAppearance = buttonAppearance
            navBarAppearance.doneButtonAppearance = buttonAppearance

            navigationBar.tintColor = contrastColor
            navigationBar.standardAppearance = navBarAppearance
            navigationBar.scrollEdgeAppearance = navBarAppearance
            navigationBar.compactAppearance = navBarAppearance
        } else {
            navigationBar.barTintColor = color
            navigationBar.tintColor = contrastColor
            navigationBar.titleTextAttributes = contrastAttrs
            navigationBar.largeTitleTextAttributes = contrastAttrs
        }
    }
}
