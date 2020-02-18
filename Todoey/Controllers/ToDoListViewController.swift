//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemArray: [ToDoItem] = []
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
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.toDoItemCellKey, for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    //MARK: - TableView Delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveToDoItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let text = textField.text {
                let item = ToDoItem(context: self.context)
                item.title = text
                item.done = false
                item.parentCategory = self.selectedCategory
                self.itemArray.append(item)
                self.saveToDoItems()
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model manipulation methods
    private func loadToDoItems(with request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()) {
        do {
            let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory?.name ?? "")
            if let requestPredicate = request.predicate {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [requestPredicate, categoryPredicate])
            } else {
                request.predicate = categoryPredicate
            }
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching item data from context, \(error)")
        }
        tableView.reloadData()
    }
    
    private func saveToDoItems() {
        do {
            try context.save()
        } catch {
            print("Error saving items, \(error)")
        }
        tableView.reloadData()
    }
}

//MARK: - UISearchBarDelegate extension
extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadToDoItems(with: request)
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
