//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by gacordeiro LuizaLabs on 23/04/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    var swipeActionTitle = "Delete"
    var swipeActionImageName = "delete-icon"
    var isDestructive = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.swipeCellKey, for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        return cell
    }
    
    func swipeAction(forRowAt indexPath: IndexPath) {
        // override at descendent
    }

//MARK: - SwipeTableViewCellDelegate methods
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let swipeAction = SwipeAction(style: isDestructive ? .destructive : .default, title: swipeActionTitle) { action, indexPath in
            self.swipeAction(forRowAt: indexPath)
        }
        
        swipeAction.image = UIImage(named: swipeActionImageName)
        
        return [swipeAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = isDestructive ? .destructive : .selection
        return options
    }
}
