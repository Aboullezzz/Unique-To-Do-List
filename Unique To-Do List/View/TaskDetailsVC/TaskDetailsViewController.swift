//
//  TaskDetailsViewController.swift
//  Unique To-Do List
//
//  Created by Mohamed on 12/07/2024.
//

import UIKit
import CoreData

class TaskDetailsViewController: UIViewController {
    
    
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskTitleTextField: UITextView!
    
    @IBAction func saveDataButtonPressed(_ sender: UIButton) {  saveNewTextByButtonPressed() }
    
    @IBAction func dueDateButtonPressed(_ sender: UIButton) { dueDateButtonPressed() }
    @IBOutlet weak var dueDateTextLabel: UILabel!
    
    @IBAction func timeButtonPressed(_ sender: UIButton) {  timeButtonPressed() }
    @IBOutlet weak var timeTextLabel: UILabel!
    
    @IBAction func reminderButtonPressed(_ sender: UIButton) {  reminderButtonPressed() }
    @IBOutlet weak var reminderTextLabel: UILabel!
    
    @IBAction func notesButtonPressed(_ sender: UIButton) {   notesButtonPressed() }
    @IBOutlet weak var notesTextLabel: UILabel!
    @IBOutlet weak var notesTextField: UITextView!
    
    
    var taskItems: Item?
    var categoryItems: CategoryTasks?
    var onDismiss: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editTextLabels()
    }
    
    private func editTextLabels() {
        if let task = taskItems {
            taskTitleLabel.text = (task.title ?? "No title set") + " " + "Settings"
            editTextLabelsForTask(task)
        } else if let category = categoryItems {
            taskTitleLabel.text = (category.title ?? "No title set")
            editTextLabelsForCategory(category)
        } else {
            print("Error: Both taskItems and categoryItems are nil")
        }
    }
    
    private func editTextLabelsForTask(_ task: Item) {
        taskTitleTextField.text = task.title ?? ""
        dueDateTextLabel.text = formatDate(task.dueDate) ?? "No due date set"
        timeTextLabel.text = formatTime(task.time) ?? "No time set"
        reminderTextLabel.text = task.reminder ?? "No reminder set"
        notesTextLabel.text = task.notes ?? "No notes set"
        notesTextField.text = task.notes ?? ""
    }
    
    private func editTextLabelsForCategory(_ category: CategoryTasks) {
        taskTitleTextField.text = category.title ?? ""
        dueDateTextLabel.text = formatDate(category.dueDate) ?? "No due date set"
        timeTextLabel.text = formatTime(category.time) ?? "No time set"
        reminderTextLabel.text = category.reminder ?? "No reminder set"
        notesTextLabel.text = category.notes ?? "No notes set"
        notesTextField.text = category.notes ?? ""
    }
    
    private func saveNewTextByButtonPressed() {
        guard let updatedTitle = taskTitleTextField.text, !updatedTitle.isEmpty else {
            return
        }
        
        if let task = taskItems {
            task.title = updatedTitle
            task.notes = notesTextField.text
            saveTask()
        } else if let category = categoryItems {
            category.title = updatedTitle
            category.notes = notesTextField.text
            saveCategory()
        }
        onDismiss?()
        NotificationCenter.default.post(name: Notification.Name("TaskUpdated"), object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    private func saveTask() {
        guard let task = taskItems else {
            return
        }
        do {
            try task.managedObjectContext?.save()
            scheduleNotification()
        } catch {
            print("Error saving task: \(error)")
        }
    }
    
    private func saveCategory() {
        guard let category = categoryItems else {
            return
        }
        do {
            try category.managedObjectContext?.save()
            scheduleNotification()
        } catch {
            print("Error saving category: \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ToDueDateVC":
            if let dueDateVC = segue.destination as? DueDateViewController {
                dueDateVC.delegate = self
                dueDateVC.taskItems = taskItems
                dueDateVC.categoryItems = categoryItems
            }
            
        case "ToTimePickerVC":
            if let timeVC = segue.destination as? TimePickerViewController {
                timeVC.delegate = self
                timeVC.taskItems = taskItems
                timeVC.categoryItems = categoryItems
            }
            
        case "ToReminderVC":
            if let reminderVC = segue.destination as? ReminderViewController {
                reminderVC.delegate = self
                reminderVC.taskItems = taskItems
                reminderVC.categoryItems = categoryItems
            }
            
        case "ToNotesVC":
            if let notesVC = segue.destination as? NotesViewController {
                notesVC.delegate = self
                notesVC.selectedNotes = notesTextLabel.text
                notesVC.taskItems = taskItems
                notesVC.categoryItems = categoryItems
            }
            
        default:
            break
        }
    }
    
}
// MARK: - DueDate Setup
extension TaskDetailsViewController: DueDateDelegate{
    
    func didSelectDueDate(_ date: Date) {
        if let task = taskItems {
            task.dueDate = date
            dueDateTextLabel.text = formatDate(date)
            scheduleNotification()
        } else if let category = categoryItems {
            category.dueDate = date
            dueDateTextLabel.text = formatDate(date)
            scheduleNotification()
        }
    }
    
    private func updateDueDate(_ date: Date) {
        if let task = taskItems {
            task.dueDate = date
            dueDateTextLabel.text = formatDate(date)
            scheduleNotification()
        } else if let category = categoryItems {
            category.dueDate = date
            dueDateTextLabel.text = formatDate(date)
            scheduleNotification()
        }
    }
    
    private func formatDate(_ date: Date?) -> String? {
        guard let date = date else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
    
    private func dueDateButtonPressed() {
        performSegue(withIdentifier: "ToDueDateVC", sender: self)
        
    }
}
// MARK: - Time Setup
extension TaskDetailsViewController: TimePickerDelegate{
    
    func didSelectTime(_ time: Date) {
        if let task = taskItems {
            task.time = time
            timeTextLabel.text = formatTime(time)
            scheduleNotification()
        } else if let category = categoryItems {
            category.time = time
            timeTextLabel.text = formatTime(time)
            scheduleNotification()
        }
    }
    
    private func updateTime(_ time: Date) {
        if let task = taskItems {
            task.time = time
            timeTextLabel.text = formatTime(time)
            scheduleNotification()
        } else if let category = categoryItems {
            category.time = time
            timeTextLabel.text = formatTime(time)
            scheduleNotification()
        }
    }
    
    private func formatTime(_ time: Date?) -> String? {
        guard let time = time else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: time)
    }
    
    private func timeButtonPressed() {
        performSegue(withIdentifier: "ToTimePickerVC", sender: self)
    }
}
// MARK: - Reminder Setup
extension TaskDetailsViewController: ReminderDelegate {
    
    func didSelectReminder(_ reminder: String) {
        updateReminder(reminder)
    }
    
    private func updateReminder(_ reminder: String) {
        if let task = taskItems {
            task.reminder = reminder
        } else if let categoryTask = categoryItems {
            categoryTask.reminder = reminder
        }
        reminderTextLabel.text = reminder
        scheduleNotification()
    }
    
    private func reminderButtonPressed() {
        let reminderVC = ReminderViewController()
        reminderVC.delegate = self
        reminderVC.taskItems = taskItems
        reminderVC.categoryItems = categoryItems
        performSegue(withIdentifier: "ToReminderVC", sender: self)
    }
    
}
// MARK: - Notes Setup
extension TaskDetailsViewController: NotesDelegate {
    
    func didSelectNotes(_ notes: String) {
        if let task = taskItems {
            task.notes = notes
        } else if let category = categoryItems {
            category.notes = notes
        }
        updateNotesText(notes)
    }
    
    private func updateNotes(_ notes: String) {
        if let task = taskItems {
            task.notes = notes
        } else if let category = categoryItems {
            category.notes = notes
        }
        updateNotesText(notes)
    }
    
    private func updateNotesText(_ notes: String) {
        notesTextLabel.text = notes
        notesTextField.text = notes
    }
    
    private func notesButtonPressed() {
        performSegue(withIdentifier: "ToNotesVC", sender: self)
    }
}
// MARK: - Setup Notifications
extension TaskDetailsViewController{
    
    func scheduleNotification() {
        if let task = taskItems {
            guard let dueDate = task.dueDate, let time = task.time else {
                print("Task due date or time is nil. No notification scheduled.")
                return
            }
            scheduleNotifications(for: task, dueDate: dueDate, time: time)
        } else if let category = categoryItems {
            guard let dueDate = category.dueDate, let time = category.time else {
                print("Category due date or time is nil. No notification scheduled.")
                return
            }
            scheduleNotifications(for: category, dueDate: dueDate, time: time)
        } else {
            print("No task or category available. No notification scheduled.")
        }
    }
    
    private func scheduleNotifications(for item: NSManagedObject, dueDate: Date, time: Date) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "To-Do List"
                content.body = (item as? Item)?.title ?? (item as? CategoryTasks)?.title ?? "Reminder"
                content.sound = .default
                
                var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
                dateComponents.hour = Calendar.current.component(.hour, from: time)
                dateComponents.minute = Calendar.current.component(.minute, from: time)
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(identifier: "\(item.objectID)", content: content, trigger: trigger)
                
                center.add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error.localizedDescription)")
                    } else {
                        print("Notification scheduled successfully")
                    }
                }
            } else if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    
}



