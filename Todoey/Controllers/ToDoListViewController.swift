//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    let realm = try! Realm()
    var toDoItems: Results<ToDoItem>?
    var selectedCategory: ToDoCategory? {
        didSet {
            loadToDoItems()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        if let category = selectedCategory {
            title = "\(category.name) items"
            let color = getColorFor(row: 0)
            let contrastColor = ContrastColorOf(color, returnFlat: true)
            navigationController?.configureFor(color: color)
            addButton.tintColor = contrastColor
            searchBar.barTintColor = color
            if #available(iOS 13.0, *) {
                searchBar.searchTextField.textColor = contrastColor
                searchBar.searchTextField.leftView?.tintColor = contrastColor
            }
        }
    }
    
    //MARK: - TableView Datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let itemsCount = toDoItems?.count ?? 0
        if itemsCount == 0 {
            tableView.setEmptyView(title: "Hurray! Nothing Todoey!", message: "You may add some items\nclicking on the + button")
        }
        else {
            tableView.restore()
        }
        return itemsCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let color = getColorFor(row: indexPath.row)
        var title = ""
        var done = false
        if let item = toDoItems?[indexPath.row] {
            title = item.title
            done = item.done
        }
        cell.backgroundColor = color
        cell.textLabel?.text = title
        cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        cell.accessoryType = done ? .checkmark : .none
        return cell
    }
    
    private func getColorFor(row: Int) -> UIColor {
        let totalOfRows = toDoItems?.count ?? 1
        let percent = row > 0 ? CGFloat(row) / CGFloat(totalOfRows * 4) : CGFloat(0)
        return selectedCategory?.cellColor.asUIColor().darken(byPercentage: percent) ?? K.defaultCellColor
    }
    
    //MARK: - TableView Delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if hasItems(), let item = toDoItems?[indexPath.row] {
            updateRealm(warnIfError: "Error saving done status") {
                item.done = !item.done
            }
        } else {
            tableView.reloadData()
        }
    }
    
    //MARK: - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let text = textField.text, text.count > 0, let category = self.selectedCategory {
                self.updateRealm(warnIfError: "Error saving new items") {
                    let item = ToDoItem()
                    item.title = text
                    item.dateCreated = Date()
                    category.items.append(item)
                }
            }
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model manipulation methods
    func hasItems(minCount: Int = 0) -> Bool {
        return toDoItems?.count ?? 0 > minCount
    }
    
    private func loadToDoItems(withFilter: String = "") {
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        if (!withFilter.isEmpty) {
            toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", withFilter)
        }
        tableView.reloadData()
    }
    
    private func updateRealm(reloadAfterUpdate: Bool = true, warnIfError: String = "Error updating realm", update: () -> Void) {
        do {
            try realm.write {
                update()
            }
            if reloadAfterUpdate { tableView.reloadData() }
        } catch {
            print("\(warnIfError), \(error)")
        }
    }
    
    //MARK: - SwipeTableViewCellDelegate methods
    override func swipeAction(forRowAt indexPath: IndexPath) {
        if let item = toDoItems?[indexPath.row]  {
            updateRealm(reloadAfterUpdate: false, warnIfError: "Error deleting item") {
                realm.delete(item)
            }
        }
    }
}

//MARK: - UISearchBarDelegate extension
extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadToDoItems(withFilter: searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            print("searchBar.text?.count == 0")
            loadToDoItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
