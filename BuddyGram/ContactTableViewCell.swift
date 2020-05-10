//
//  ContactTableViewCell.swift
//  BuddyGram
//
//  Created by Mac OSX on 4/23/20.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

   
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
