//
//  NotesViewController.swift
//  Unique To-Do List
//
//  Created by Mohamed on 12/07/2024.
//

import UIKit

protocol NotesDelegate: AnyObject {
    func didSelectNotes(_ notes: String)
}

class NotesViewController: UIViewController {
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {  saveButton() }
    
    @IBOutlet weak var notesTextView: UITextView!
    
    weak var delegate: NotesDelegate?
    var selectedNotes: String?
    var taskItems: Item?
    var categoryItems: CategoryTasks?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveSelectedNotes()
    }
    
    private func saveSelectedNotes(){
        if let selectedNotes = selectedNotes {
            notesTextView.text = selectedNotes
        }
    }
    
    private func saveButton(){
        let selectedText = notesTextView.text
        delegate?.didSelectNotes(selectedText ?? "")
        dismiss(animated: true, completion: nil)
    }
}
