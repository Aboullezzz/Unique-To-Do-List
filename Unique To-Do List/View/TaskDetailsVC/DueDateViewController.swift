//
//  DueDateViewController.swift
// Unique To Do List
//
//  Created by Mohamed on 12/07/2024.
//

import UIKit

protocol DueDateDelegate: AnyObject {
    func didSelectDueDate(_ date: Date)
}

class DueDateViewController: UIViewController {
    
    @IBAction func saveButtonPressed(_ sender: UIButton) { saveButton() }
    
    @IBOutlet weak var datePickerOutlet: UIDatePicker!
    
    weak var delegate: DueDateDelegate?
    var selectedDate: Date?
    var taskItems: Item?
    var categoryItems: CategoryTasks?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func saveButton(){
        let selectedDate = datePickerOutlet.date
        delegate?.didSelectDueDate(selectedDate)
        dismiss(animated: true, completion: nil)
    }
}

