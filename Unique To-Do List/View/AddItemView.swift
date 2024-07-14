//
//  AddItemView.swift
//  Unique To-Do List
//
//  Created by Mohamed on 12/07/2024.
//


import UIKit

class AddItemView: UIView {
    var textField: UITextField!
    var prioritySegmentedControl: UISegmentedControl!
    var addAction: (() -> Void)?
    var cancelAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        
        // Priority Label
        let priorityLabel = UILabel()
        priorityLabel.text = "Priority"
        priorityLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(priorityLabel)
        
        // Segmented Control
        prioritySegmentedControl = UISegmentedControl(items: ["High", "Medium", "Low"])
        prioritySegmentedControl.selectedSegmentIndex = 0
        prioritySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(prioritySegmentedControl)
        
        // Text Field
        textField = UITextField()
        textField.placeholder = "Create New To-Do"
        textField.borderStyle = .roundedRect
        textField.contentVerticalAlignment = .top
        textField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textField)
        
        // Add Button
        let addButton = UIButton(type: .system)
        addButton.setTitle("Add New To-Do", for: .normal)
        addButton.tintColor = UIColor(red: 47.0/255.0, green: 79.0/255.0, blue: 79.0/255.0, alpha: 1.0)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(addButton)
        
        // Cancel Button
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.tintColor = .red
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(cancelButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            priorityLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 25),
            priorityLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            
            prioritySegmentedControl.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            prioritySegmentedControl.leadingAnchor.constraint(equalTo: priorityLabel.trailingAnchor, constant: 8),
            prioritySegmentedControl.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            textField.topAnchor.constraint(equalTo: prioritySegmentedControl.bottomAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            addButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            addButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            
            cancelButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            addButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20)
            
        ])
    }
    
    @objc private func addButtonTapped() {
        addAction?()
    }
    
    @objc private func cancelButtonTapped() {
        cancelAction?()
    }
}
