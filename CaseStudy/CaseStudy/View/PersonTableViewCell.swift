//
//  PersonTableViewCell.swift
//  CaseStudy
//
//  Created by ali.ocal on 29.03.2023.
//

import UIKit

class PersonTableViewCell: UITableViewCell {

    @IBOutlet private weak var personNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(person: Person) {
        personNameLabel.text = "\(person.fullName) (\(person.id))"
    }
    
}
