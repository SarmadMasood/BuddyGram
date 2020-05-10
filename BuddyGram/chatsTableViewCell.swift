//
//  chatsTableViewCell.swift
//  BuddyGram
//
//  Created by Mac OSX on 4/23/20.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import UIKit

class chatsTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var latestMsgLabel: UILabel!
    @IBOutlet weak var chatImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        chatImage.layer.cornerRadius = 25
        chatImage.clipsToBounds = true
        self.layer.masksToBounds = false

        // Configure the view for the selected state
    }

}
