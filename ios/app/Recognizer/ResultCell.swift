//
//  ResultCell.swift
//  RecogApp
//
//  Created by Mitsuhau Emoto on 2018/10/07.
//  Copyright © 2018 Seesaa inc. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var progressbar: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
