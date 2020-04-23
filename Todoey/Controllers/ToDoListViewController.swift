//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController {
    
    let realm = try! Realm()
    var toDoItems: Results<ToDoItem>?
    var selectedCategory: ToDoCategory? {
        didSet {
            loadToDoItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let category = selectedCategory?.name {
            title = "Items for \(category)"
        }
    }
    
    //MARK: - TableView Datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = toDoItems?.count ?? 1
        return rows > 0 ? rows : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.toDoItemCellKey, for: indexPath)
        var title = "No Todoey items added yet"
        var done = false
        if toDoItems?.count ?? 0 > indexPath.row, let item = toDoItems?[indexPath.row] {
            title = item.title
            done = item.done
        }
        cell.textLabel?.text = title
        cell.accessoryType = done ? .checkmark : .none
        return cell
    }
    
    //MARK: - TableView Delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if toDoItems?.count ?? 0 > 0, let item = toDoItems?[indexPath.row] {
            if (item.done) {
                let alert = UIAlertController(title: "Delete Todoey Item?", message: "", preferredStyle: .alert)
                let actionDelete = UIAlertAction(title: "Delete", style: .default) { (action) in
                    self.updateRealm(warnIfError: "Error deleting item") {
                        self.realm.delete(item)
                    }
                }
                let actionNotDone = UIAlertAction(title: "Not Done", style: .default) { (action) in
                    self.unckeck(item)
                }
                alert.addAction(actionDelete)
                alert.addAction(actionNotDone)
                present(alert, animated: true, completion: nil)
            } else {
                unckeck(item)
            }
        }
        tableView.reloadData()
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
    private func loadToDoItems(withFilter: String = "") {
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        if (!withFilter.isEmpty) {
            toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", withFilter)
        }
        tableView.reloadData()
    }
    
    private func unckeck(_ item: ToDoItem) {
        updateRealm(warnIfError: "Error saving done status") {
            item.done = !item.done
        }
    }
    
    private func updateRealm(warnIfError: String = "Error updating realm", update: () -> Void) {
        do {
            try realm.write {
                update()
            }
            tableView.reloadData()
        } catch {
            print("\(warnIfError), \(error)")
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
