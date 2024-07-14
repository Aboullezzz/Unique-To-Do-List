//
//  CategoryViewModel.swift
//  Unique To-Do List
//
//  Created by Mohamed on 10/07/2024.
//

import UIKit
import CoreData

class CategoryViewModel{
    
    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error Saving Categories \(error)")
        }
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest(), predicate: NSPredicate? = nil, in tableView: UITableView? = nil) {
        do {
            if let predicate = predicate {
                request.predicate = predicate
            }
            categories = try context.fetch(request)
        } catch {
            print("Error in Fetching Categories \(error)")
        }
    }
    
    func addItemsInCategoryVC(name:String,title: String,done:Bool,dueDate:Date,time: Date,reminder:String,notes: String,creationDate: Date, priority:Int16) {
        let newItems = Category(context: context)
        newItems.name = name
        newItems.title = title
        newItems.isDone = false
        newItems.dueDate = dueDate
        newItems.time = time
        newItems.reminder = reminder
        newItems.notes = notes
        newItems.creationDate = creationDate
        newItems.priority = priority
        saveCategories()
        loadCategories()
    }
    
    func deleteCategory(at index: Int) {
        let item = self.categories[index]
        self.context.delete(item)
        do {
            try self.context.save()
        } catch {
            print("Error saving context after deletion: \(error)")
        }
        self.categories.remove(at: index)
    }
}

// MARK: - Category SearchBar Delegate
extension CategoryViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        viewModel.loadCategories(with: request, predicate: predicate)
        categoryTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            viewModel.loadCategories()
            categoryTableView.reloadData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    func configureSearchBar() {
        searchBar.delegate = self
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
//        let labelItem = UIBarButtonItem(title: "Category List Search...", style: .plain, target: nil, action: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let dismissButton = UIBarButtonItem(title: "Dismiss", style: .plain, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexibleSpace, dismissButton]
        searchBar.inputAccessoryView = toolbar
    }
    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
}
