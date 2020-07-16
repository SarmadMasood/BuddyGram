//
//  CountryTableViewCell.swift
//  BuddyGram
//
//  Created by Mac OSX on 5/15/20.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import UIKit

class CountryTableViewCell: UITableViewCell {

    @IBOutlet weak var ISOCode: UILabel!
    
    @IBOutlet weak var dialCode: UILabel!
    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
