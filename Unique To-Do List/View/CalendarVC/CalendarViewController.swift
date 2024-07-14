//
//  CalendarViewController.swift
//  Unique To-Do List
//
//  Created by Mohamed on 10/07/2024.
//

import UIKit
import CoreData

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var calendarDatePicker: UIDatePicker!
    
    @IBOutlet weak var calendarTableView: UITableView!
    
    var combinedTasks: [CombinedTask] = []
    var items: [Item] = []
    var categoryTasks: [CategoryTasks] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchAndCombineData()
        setupNotificationCenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAndCombineData()
    }
    
    private func setupTableView() {
        calendarTableView.delegate = self
        calendarTableView.dataSource = self
    }
    
    private func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleTaskUpdatedNotification), name: NSNotification.Name("TaskUpdated"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("TaskUpdated"), object: nil)
    }
    
    @objc func handleTaskUpdatedNotification() {
        fetchAndCombineData()
    }
    
    private func fetchAndCombineData() {
        fetchItems()
        fetchCategoryTasks()
        
        combinedTasks = items.map { CombinedTask(title: $0.title ?? "", dueDate: $0.dueDate, time: $0.time, reminder: $0.reminder, notes: $0.notes, isDone: false) }
        combinedTasks += categoryTasks.map { CombinedTask(title: $0.title ?? "", dueDate: $0.dueDate, time: $0.time, reminder: $0.reminder, notes: $0.notes, isDone: true) }
        combinedTasks.sort { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
        
        DispatchQueue.main.async {
            self.calendarTableView.reloadData()
        }
    }
    
    private func fetchItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        if let predicate = predicate {
            request.predicate = predicate
        }
        do {
            items = try context.fetch(request)
        } catch {
            print("Error fetching Items: \(error)")
        }
    }
    
    private func fetchCategoryTasks(with request: NSFetchRequest<CategoryTasks> = CategoryTasks.fetchRequest(), predicate: NSPredicate? = nil) {
        if let predicate = predicate {
            request.predicate = predicate
        }
        do {
            categoryTasks = try context.fetch(request)
        } catch {
            print("Error fetching CategoryTasks: \(error)")
        }
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return combinedTasks.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        
        let item = combinedTasks[indexPath.section]
        cell.cellTitleLabel.text = item.title
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
}
