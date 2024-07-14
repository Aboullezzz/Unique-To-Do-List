//
//  CategoryViewController.swift
//  Unique To-Do List
//
//  Created by Mohamed on 11/07/2024.
//

import UIKit

class CategoryViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var categoryTableView: UITableView!
    
    @IBAction func addCategoryButtonPressed(_ sender: UIButton) { showAddCategoryAlert() }
    
    let viewModel = CategoryViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }
    
    private func setupData() {
        viewModel.loadCategories()
        configureSearchBar()
        defaultCategories()
        setupNotificationCenter()
        setupTableView()
    }
    
    private func setupTableView() {
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
    }
    
    private func defaultCategories() {
        if viewModel.categories.isEmpty {
            let defaultCategories = ["Work", "Personal", "Health", "Wishlist", "Birthday"]
            for categoryName in defaultCategories {
                let defaultPriority: Int16 = 0
                viewModel.addItemsInCategoryVC(name: categoryName, title: categoryName, done: false, dueDate: Date(), time: Date(), reminder: "", notes: "", creationDate: Date(), priority: defaultPriority)
            }
            categoryTableView.reloadData()
        }
    }
    
    private func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleTaskUpdatedNotification), name: NSNotification.Name("TaskUpdated"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("TaskUpdated"), object: nil)
    }
    
    @objc func handleTaskUpdatedNotification() {
        viewModel.loadCategories()
        categoryTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CategoryDetailSegue" {
            if let taskDetailVC = segue.destination as? TasksForCategoryViewController {
                if let indexPath = categoryTableView.indexPathForSelectedRow {
                    let selectedTask = viewModel.categories[indexPath.section]
                    taskDetailVC.selectedCategory = selectedTask
                }
            }
        }
    }
    
    private func showCategoryDetail(for category: Category) {
        performSegue(withIdentifier: "CategoryDetailSegue", sender: category)
    }
    
    private func showAddCategoryAlert() {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add New Category", style: .default) { (action) in
            if let newCategoryName = textField.text, !newCategoryName.isEmpty {
                let defaultPriority: Int16 = 0
                self.viewModel.addItemsInCategoryVC(name: newCategoryName, title: "", done: false, dueDate: Date(), time: Date(), reminder: "", notes: "", creationDate: Date(), priority: defaultPriority)
                self.categoryTableView.reloadData()
            }
        }
        addAction.setValue(UIColor(red: 47.0/255.0, green: 79.0/255.0, blue: 79.0/255.0, alpha: 1.0), forKey: "titleTextColor")
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        alert.addAction(addAction)
        present(alert, animated: true, completion: nil)
    }

}

extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        let category = viewModel.categories[indexPath.section]
        
        cell.configureCell(withTitle: category.name!, isChecked: category.isDone, priority: category.priority) {
            category.isDone.toggle()
            self.viewModel.saveCategories()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = viewModel.categories[indexPath.section]
        showCategoryDetail(for: category)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.viewModel.deleteCategory(at: indexPath.section)
            tableView.deleteSections(IndexSet(arrayLiteral: indexPath.section), with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            self.viewModel.deleteCategory(at: indexPath.section)
            tableView.deleteSections(IndexSet(arrayLiteral: indexPath.section), with: .fade)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}
