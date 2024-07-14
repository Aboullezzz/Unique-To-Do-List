//
//  TasksCell.swift
//  Unique To-Do List
//
//  Created by Mohamed on 10/07/2024.
//

import UIKit

class TasksCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkCircleImage: UIImageView!
    
    var onToggleChecked: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkmarkImage()
    }
    
    func checkmarkImage(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        checkCircleImage.addGestureRecognizer(tapGestureRecognizer)
        checkCircleImage.isUserInteractionEnabled = true
    }
    
    @objc func imageTapped() {
        onToggleChecked?()
    }
    
    func configureCell(withTitle title: String, isChecked: Bool, priority: Int16, toggleChecked: @escaping () -> Void) {
        titleLabel.text = title
        checkCircleImage.image = isChecked ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        setBackgroundColorForPriority(priority)
        onToggleChecked = toggleChecked
        
        self.contentView.backgroundColor = backgroundColor
    }
    
    private func setBackgroundColorForPriority(_ priority: Int16) {
        switch priority {
        case 1:
            backgroundColor  = UIColor(red: 255.0/255.0, green: 100.0/255.0, blue: 130.0/255.0, alpha: 1.0)
        case 2:
            backgroundColor = UIColor(red: 184/255.0, green: 134.0/255.0, blue: 11.0/255.0, alpha: 1.0)
        case 3:
            backgroundColor = UIColor(red: 0.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        default:
            backgroundColor = .white
        }
    }
}
