//
//  CategoryViewController.swift
//  Todoey
//
//  Created by gacordeiro LuizaLabs on 14/02/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {

    let realm = try! Realm()
    var categories: Results<ToDoCategory>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        navigationController?.navigationBar.tintColor = .white
        loadToDoCategories()
    }

    //MARK: - TableView Datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = categories?.count ?? 1
        return rows > 0 ? rows : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.categoryCellKey, for: indexPath)
        var name = "No Categories added yet"
        if categories?.count ?? 0 > indexPath.row {
            name = categories?[indexPath.row].name ?? ""
        }
        cell.textLabel?.text = name.count > 0 ? name : "<unnamed category>"
        return cell
    }

    //MARK: - TableView Delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.goToToDoItemsSegue, sender: self)
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
    private func loadToDoCategories() {
        categories = realm.objects(ToDoCategory.self)
        tableView.reloadData()
    }

    private func save(_ category: ToDoCategory) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving categories, \(error)")
        }
        tableView.reloadData()
    }
}
