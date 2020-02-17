//
//  CategoryViewController.swift
//  Todoey
//
//  Created by gacordeiro LuizaLabs on 14/02/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    //TODO: Understand why ToDoCategory is not recognized
    //var categoryArray: [ToDoCategory] = []
    var categoryArray: [ToDoItem] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadToDoCategories()
    }

    //MARK: - TableView Datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.categoryCellKey, for: indexPath)
        //cell.textLabel?.text = categoryArray[indexPath.row].name
        cell.textLabel?.text = categoryArray[indexPath.row].title
        return cell
    }

    //MARK: - TableView Delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categoryArray[indexPath.row].done = !categoryArray[indexPath.row].done
        saveToDoCategories()
        tableView.deselectRow(at: indexPath, animated: true)
        //TODO: Perform segue to list ----------------------------------------------------
    }
    
    //MARK: - Add new categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            if let text = textField.text {
                //let category = ToDoCategory(context: self.context)
                let category = ToDoItem(context: self.context)
                //category.name = text
                category.title = text
                self.categoryArray.append(category)
                self.saveToDoCategories()
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
    //private func loadToDoCategories(with request: NSFetchRequest<ToDoCategory> = ToDoCategory.fetchRequest()) {
    private func loadToDoCategories(with request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()) {
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context, \(error)")
        }
        tableView.reloadData()
    }

    private func saveToDoCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
        tableView.reloadData()
    }
}
