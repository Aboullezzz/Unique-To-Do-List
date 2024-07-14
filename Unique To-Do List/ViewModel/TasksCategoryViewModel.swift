//
//  TasksCategoryViewModel.swift
//  Unique To-Do List
//
//  Created by Mohamed on 11/07/2024.
//

import UIKit
import CoreData

class CategoryTasksViewModel{
    
    var categoryTasks = [CategoryTasks]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var currentCategory: Category?
    
    func saveTasks(){
        do{
            try context.save()
        }catch{
            print("Error Saving Items \(error)")
        }
    }
    
    func loadTasks(with request: NSFetchRequest<CategoryTasks> = CategoryTasks.fetchRequest(), predicate: NSPredicate? = nil) {
        do {
            if let predicate = predicate {
                request.predicate = predicate
            }
            categoryTasks = try context.fetch(request)
        } catch {
            print("Error in Fetching Items \(error)")
        }
    }
    
    func loadTasks(for category: Category) {
        let request: NSFetchRequest<CategoryTasks> = CategoryTasks.fetchRequest()
        let predicate = NSPredicate(format: "tasks == %@", category)
        loadTasks(with: request, predicate: predicate)
    }
    
    func addItemsInTasksForCategoryVC(category: Category, title: String, done: Bool, dueDate: Date, time: Date, reminder: String, notes: String, creationDate: Date,priority: Int16) {
        let newItems = CategoryTasks(context: context)
        newItems.title = title
        newItems.isDone = false
        newItems.dueDate = dueDate
        newItems.time = time
        newItems.reminder = reminder
        newItems.notes = notes
        newItems.creationDate = creationDate
        newItems.priority = priority
        newItems.tasks = category
        
        saveTasks()
        loadTasks(for: category)
    }
    
    func deleteItem(at index: Int) {
        let tasks = self.categoryTasks[index]
        self.context.delete(tasks)
        do {
            try self.context.save()
        } catch {
            print("Error saving context after deletion: \(error)")
        }
        self.categoryTasks.remove(at: index)
    }
}

// MARK: - TasksForCategoryVC SearchBar Delegate
extension TasksForCategoryViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        
        let request: NSFetchRequest<CategoryTasks> = CategoryTasks.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        viewModel.loadTasks(with: request, predicate: predicate)
        taskForCategoryTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            viewModel.loadTasks()
            taskForCategoryTableView.reloadData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    func configureSearchBar() {
        searchBar.delegate = self
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
//        let labelItem = UIBarButtonItem(title: "To-Do List Search...", style: .plain, target: nil, action: nil)
//        labelItem.tintColor = .green
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let dismissButton = UIBarButtonItem(title: "Dismiss", style: .plain, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexibleSpace, dismissButton]
        searchBar.inputAccessoryView = toolbar
    }
    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
}
