//
//  CategoryViewController.swift
//  Todoey
//
//  Created by gacordeiro LuizaLabs on 14/02/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm()
    var categories: Results<ToDoCategory>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadToDoCategories()
    }

    //MARK: - TableView Datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories added yet"
        return cell
    }

    //MARK: - TableView Delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if hasCategories() {
            performSegue(withIdentifier: K.goToToDoItemsSegue, sender: self)
        } else {
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.goToToDoItemsSegue, let indexPath = tableView.indexPathForSelectedRow {
            let destinationVC = segue.destination as! ToDoListViewController
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - Add new categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            if let text = textField.text, text.count > 0 {
                let category = ToDoCategory()
                category.name = text
                self.save(category)
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation methods
    func hasCategories(minCount: Int = 0) -> Bool {
        return categories?.count ?? 0 > minCount
    }
    
    private func loadToDoCategories() {
        categories = realm.objects(ToDoCategory.self)
        tableView.reloadData()
    }

    private func save(_ category: ToDoCategory) {
        updateRealm(warnIfError: "Error saving categories") {
            realm.add(category)
        }
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
        if let category = categories?[indexPath.row] {
            updateRealm(reloadAfterUpdate: false, warnIfError: "Error deleting category") {
                realm.delete(category)
            }
        }
    }
}
