//
//  ReminderViewController.swift
//  Unique To-Do List
//
//  Created by Mohamed on 12/07/2024.
//


import UIKit

protocol TimePickerDelegate: AnyObject {
    func didSelectTime(_ time: Date)
}

class TimePickerViewController: UIViewController {
    
    @IBAction func saveButtonPressed(_ sender: UIButton) { saveButton() }

    @IBOutlet weak var timePickerOutlet: UIDatePicker!
    
    weak var delegate: TimePickerDelegate?
    var selectedTime: Date?
    var taskItems: Item?
    var categoryItems: CategoryTasks?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func saveButton(){
        let selectedTime = timePickerOutlet.date
        delegate?.didSelectTime(selectedTime)
        dismiss(animated: true, completion: nil)
    }
}

