//
//  TableViewCell.swift
//  GettMobileDelivery
//
//  Created by Roei Baruch on 06/06/2021.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var parcelLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(name: String) {

        parcelLabel.text = name
    }
    
}
