//
//  ProductCell.swift
//  Broker MQTT
//
//  Created by Henrique Velloso on 14/12/18.
//  Copyright © 2018 Henrique Velloso. All rights reserved.
//

import UIKit

class ProductCell: UITableViewCell {
    
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var betsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
