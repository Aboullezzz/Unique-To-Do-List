//
//  TasksViewController.swift
//  Unique To-Do List
//
//  Created by Mohamed on 10/07/2024.
//

import UIKit

class TasksViewController: UIViewController {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tasksTableView: UITableView!
    
    @IBAction func addTasksButtonPressed(_ sender: UIButton) {showAddItemsView()}
    
    
    let viewModel = TasksViewModel()
    var addItemView: AddItemView!
    var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataInTasksVC()
        addKeyboardObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    private func setupDataInTasksVC() {
        viewModel.loadItems()
        configureSearchBar()
        setupNotificationCenter()
        setupTableView()
        addKeyboardObservers()
    }
    
    private func setupTableView() {
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
    }
    
    private func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleTaskUpdatedNotification), name: NSNotification.Name("TaskUpdated"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("TaskUpdated"), object: nil)
        removeKeyboardObservers()
    }
    
    @objc func handleTaskUpdatedNotification() {
        viewModel.loadItems()
        tasksTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TaskDetailSegue" {
            if let taskDetailVC = segue.destination as? TaskDetailsViewController,
               let indexPath = tasksTableView.indexPathForSelectedRow {
                let selectedTask = viewModel.items[indexPath.section]
                taskDetailVC.taskItems = selectedTask
            }
        }
    }
    
    private func showTaskDetails(for task: Item) {
        performSegue(withIdentifier: "TaskDetailSegue", sender: task)
    }
    
    private func showAddItemsView() {
        backgroundView = UIView(frame: self.view.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.alpha = 0
        backgroundView.isUserInteractionEnabled = true
        view.addSubview(backgroundView)
        
        addItemView = AddItemView(frame: CGRect(x: 20, y: (view.frame.height - 300) / 2, width: view.frame.width - 40, height: 300))
        
        addItemView.addAction = { [weak self] in
            guard let self = self else { return }
            if let newItemTitle = self.addItemView.textField.text, !newItemTitle.isEmpty {
                let selectedPriority = self.addItemView.prioritySegmentedControl.selectedSegmentIndex + 1
                self.viewModel.addItemsInTasksVC(
                    title: newItemTitle,
                    done: false,
                    dueDate: Date(),
                    time: Date(),
                    reminder: "",
                    notes: "",
                    creationDate: Date(),
                    priority: Int16(selectedPriority))
                self.tasksTableView.reloadData()
                self.dismissAddItemsView()
            }
        }
        addItemView.cancelAction = { [weak self] in
            self?.dismissAddItemsView()
        }
        
        // Add and animate the views
        view.addSubview(addItemView)
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.alpha = 1
            self.addItemView.alpha = 1
        }
        
        // Make the text field the first responder to show the keyboard
        addItemView.textField.becomeFirstResponder()
    }
    
    private func dismissAddItemsView() {
        addItemView.textField.resignFirstResponder()
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.alpha = 0
            self.addItemView.alpha = 0
        }) { _ in
            self.backgroundView.removeFromSuperview()
            self.addItemView.removeFromSuperview()
            self.backgroundView = nil
            self.addItemView = nil
        }
    }
}

extension TasksViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath) as! TasksCell
        let item = viewModel.items[indexPath.section]
        
        cell.configureCell(withTitle: item.title!, isChecked: item.isDone, priority: item.priority) {
            item.isDone.toggle()
            self.viewModel.saveItems()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = cell.backgroundColor
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.items[indexPath.section]
        showTaskDetails(for: item)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.viewModel.deleteItem(at: indexPath.section)
            tableView.deleteSections(IndexSet(arrayLiteral: indexPath.section), with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            self.viewModel.deleteItem(at: indexPath.section)
            tableView.deleteSections(IndexSet(arrayLiteral: indexPath.section), with: .fade)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}

extension TasksViewController {
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        adjustAddItemViewForKeyboard(show: true, keyboardFrame: keyboardFrame)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        adjustAddItemViewForKeyboard(show: false, keyboardFrame: .zero)
    }
    
    
    func adjustAddItemViewForKeyboard(show: Bool, keyboardFrame: CGRect) {
        guard let addItemView = self.addItemView else { return }
        let keyboardHeight = show ? keyboardFrame.height : 0
        UIView.animate(withDuration: 0.3) {
            addItemView.frame.origin.y = (self.view.frame.height - keyboardHeight - addItemView.frame.height) / 2
        }
    }
}
