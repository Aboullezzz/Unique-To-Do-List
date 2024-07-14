//
//  TasksViewModel.swift
//  Unique To-Do List
//
//  Created by Mohamed on 10/07/2024.
//

import UIKit
import CoreData

class TasksViewModel{
    
    var items = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func saveItems(){
        do{
            try context.save()
        }catch{
            print("Error Saving Items \(error)")
        }
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        do {
            if let predicate = predicate {
                request.predicate = predicate
            }
            items = try context.fetch(request)
        } catch {
            print("Error in Fetching Items \(error)")
        }
    }
    
    func addItemsInTasksVC(title: String,done:Bool,dueDate:Date,time: Date,reminder:String,notes: String,creationDate: Date,priority: Int16) {
        let newItems = Item(context: context)
        newItems.title = title
        newItems.isDone = false
        newItems.dueDate = dueDate
        newItems.time = time
        newItems.reminder = reminder
        newItems.notes = notes
        newItems.creationDate = creationDate
        newItems.priority = priority
        saveItems()
        loadItems()
    }
    
    func deleteItem(at index: Int) {
        let item = self.items[index]
        self.context.delete(item)
        do {
            try self.context.save()
        } catch {
            print("Error saving context after deletion: \(error)")
        }
        self.items.remove(at: index)
    }
}

// MARK: - TasksVC SearchBar Delegate
extension TasksViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        viewModel.loadItems(with: request, predicate: predicate)
        tasksTableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            viewModel.loadItems()
            tasksTableView.reloadData()
            
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
