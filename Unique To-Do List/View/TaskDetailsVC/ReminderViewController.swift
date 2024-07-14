//
//  ReminderViewController.swift
//  Unique To-Do List
//
//  Created by Mohamed on 12/07/2024.
//
import UIKit

protocol ReminderDelegate: AnyObject {
    func didSelectReminder(_ reminder: String)
}

class ReminderViewController: UIViewController {
    
    
    @IBAction func saveReminderButton(_ sender: UIButton) { saveReminder() }
    
    @IBOutlet weak var reminderSwitchOutlet: UISwitch!
    @IBAction func reminderSwitchPressed(_ sender: UISwitch) {  updateButtonInteraction() }
    
    @IBOutlet weak var reminderAOutlet: UIButton!
    @IBAction func reminderAAction(_ sender: UIButton) { }
    
    @IBOutlet weak var reminderBOutlet: UIButton!
    @IBAction func reminderBAction(_ sender: UIButton) { }
    
    @IBOutlet weak var reminderCOutlet: UIButton!
    @IBAction func reminderCAction(_ sender: UIButton) { }
    
    @IBOutlet weak var reminderDOutlet: UIButton!
    @IBAction func reminderDAction(_ sender: UIButton) { }
    
    @IBOutlet weak var reminderEOutlet: UIButton!
    @IBAction func reminderEAction(_ sender: UIButton) {  }
    
    @IBOutlet weak var reminderFOutlet: UIButton!
    @IBAction func reminderFAction(_ sender: UIButton) { }
    
    weak var delegate: ReminderDelegate?
    var selectReminder = Set<String>()
    var taskItems: Item!
    var categoryItems: CategoryTasks!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        restoreSelectedReminders()
        restoreSelectedRemindersWithTasksCategory()
        updateButtonInteraction()
    }
    
    private func setupButtons() {
        reminderAOutlet.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        reminderBOutlet.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        reminderCOutlet.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        reminderDOutlet.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        reminderEOutlet.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        reminderFOutlet.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    private func restoreSelectedReminders() {
        guard let task = taskItems else {
            print("Error: Task is nil")
            return
        }
        guard let reminderText = task.reminder else {
            print("Warning: Task reminder is nil")
            selectReminder = []
            updateButtonStates()
            return
        }
        let savedReminders = reminderText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        selectReminder = Set(savedReminders)
        updateButtonStates()
    }
    
    private func restoreSelectedRemindersWithTasksCategory() {
        guard let categoryItems = categoryItems else {
            print("Error: CategoryItems is nil")
            return
        }
        guard let reminderText = categoryItems.reminder else {
            print("Warning: CategoryItems reminder is nil")
            selectReminder = []
            updateButtonStates()
            return
        }
        let savedReminders = reminderText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        selectReminder = Set(savedReminders)
        updateButtonStates()
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        toggleSelection(sender)
    }
    
    private func toggleSelection(_ button: UIButton) {
        button.isSelected = !button.isSelected
        let reminderText = button.titleLabel?.text ?? ""
        if button.isSelected {
            selectReminder.insert(reminderText)
        } else {
            selectReminder.remove(reminderText)
        }
        updateButtonImage(for: button)
    }
    
    private func updateButtonStates() {
        reminderAOutlet.isSelected = selectReminder.contains(reminderAOutlet.titleLabel?.text ?? "hi")
        reminderBOutlet.isSelected = selectReminder.contains(reminderBOutlet.titleLabel?.text ?? "")
        reminderCOutlet.isSelected = selectReminder.contains(reminderCOutlet.titleLabel?.text ?? "")
        reminderDOutlet.isSelected = selectReminder.contains(reminderDOutlet.titleLabel?.text ?? "")
        reminderEOutlet.isSelected = selectReminder.contains(reminderEOutlet.titleLabel?.text ?? "")
        reminderFOutlet.isSelected = selectReminder.contains(reminderFOutlet.titleLabel?.text ?? "")
        
        updateButtonImage(for: reminderAOutlet)
        updateButtonImage(for: reminderBOutlet)
        updateButtonImage(for: reminderCOutlet)
        updateButtonImage(for: reminderDOutlet)
        updateButtonImage(for: reminderEOutlet)
        updateButtonImage(for: reminderFOutlet)
    }
    
    private func updateButtonImage(for button: UIButton) {
        let image = button.isSelected ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "square")
        button.setImage(image, for: .normal)
    }
    
    private func saveReminder() {
        if let task = taskItems {
            saveReminderForTask(task)
        } else if let category = categoryItems {
            saveReminderForCategory(category)
        } else {
            print("Error: Both taskItems and categoryItems are nil")
        }
    }
    
    private func saveReminderForTask(_ task: Item) {
        let reminderText = selectReminder.joined(separator: ", ")
        task.reminder = reminderText
        
        guard let context = task.managedObjectContext else {
            print("Error: Managed object context is nil")
            return
        }
        
        do {
            try context.save()
            delegate?.didSelectReminder(reminderText)
            NotificationCenter.default.post(name: Notification.Name("TaskUpdated"), object: nil)
            dismiss(animated: true, completion: nil)
        } catch {
            print("Error saving reminder for task: \(error)")
        }
    }
    
    private func updateButtonInteraction() {
        let isSwitchOn = reminderSwitchOutlet.isOn
        reminderAOutlet.isUserInteractionEnabled = isSwitchOn
        reminderBOutlet.isUserInteractionEnabled = isSwitchOn
        reminderCOutlet.isUserInteractionEnabled = isSwitchOn
        reminderDOutlet.isUserInteractionEnabled = isSwitchOn
        reminderEOutlet.isUserInteractionEnabled = isSwitchOn
        reminderFOutlet.isUserInteractionEnabled = isSwitchOn
        
        if isSwitchOn {
            reminderBOutlet.isSelected = true
            updateButtonImage(for: reminderBOutlet)
            selectReminder.insert(reminderBOutlet.titleLabel?.text ?? "")
        } else {
            reminderAOutlet.isSelected = false
            reminderBOutlet.isSelected = false
            reminderCOutlet.isSelected = false
            reminderDOutlet.isSelected = false
            reminderEOutlet.isSelected = false
            reminderFOutlet.isSelected = false
            
            selectReminder.removeAll()
            
            updateButtonImage(for: reminderAOutlet)
            updateButtonImage(for: reminderBOutlet)
            updateButtonImage(for: reminderCOutlet)
            updateButtonImage(for: reminderDOutlet)
            updateButtonImage(for: reminderEOutlet)
            updateButtonImage(for: reminderFOutlet)
        }
    }
    
    private func saveReminderForCategory(_ category: CategoryTasks) {
        let remindersText = selectReminder.joined(separator: ", ")
        category.reminder = remindersText
        
        guard let context = category.managedObjectContext else {
            print("Error: Managed object context is nil")
            return
        }
        
        do {
            try context.save()
            delegate?.didSelectReminder(remindersText)
            NotificationCenter.default.post(name: Notification.Name("TaskUpdated"), object: nil)
            dismiss(animated: true, completion: nil)
        } catch {
            print("Error saving reminder for category: \(error)")
        }
    }
}
