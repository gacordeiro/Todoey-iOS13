//
//  CategoryViewController.swift
//  Todoey
//
//  Created by gacordeiro LuizaLabs on 14/02/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    @IBOutlet weak var addButton: UIBarButtonItem!
    let realm = try! Realm()
    var categories: Results<ToDoCategory>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadToDoCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let color = UIColor.flatBlue()
        let contrastColor = ContrastColorOf(color, returnFlat: true)
        addButton.tintColor = contrastColor
        navigationController?.configureFor(color: color)
    }

    //MARK: - TableView Datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let itemsCount = categories?.count ?? 0
        if itemsCount == 0 {
            tableView.setEmptyView(title: "Hurray! Nothing Todoey!", message: "You may add some categories\nclicking on the + button")
        }
        else {
            tableView.restore()
        }
        return itemsCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        var color: UIColor = K.defaultCellColor
        var title = "No Categories added yet"
        if let category = categories?[indexPath.row] {
            title = category.name
            color = category.cellColor.asUIColor()
        }
        cell.textLabel?.text = title
        cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        cell.backgroundColor = color
        return cell
    }

    //MARK: - TableView Delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if hasCategories() {
            performSegue(withIdentifier: K.goToToDoItemsSegue, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.goToToDoItemsSegue, let indexPath = tableView.indexPathForSelectedRow {
            let destinationVC = segue.destination as! ToDoListViewController
            destinationVC.selectedCategory = categories?[indexPath.row]
            tableView.reloadData()
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
                category.cellColor = UIColor.randomFlat().hexValue()
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
