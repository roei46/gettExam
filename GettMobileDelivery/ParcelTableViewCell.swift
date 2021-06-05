//
//  ParcelTableViewCell.swift
//  GettMobileDelivery
//
//  Created by Roei Baruch on 05/06/2021.
//

import UIKit

class ParcelTableViewCell: UITableViewCell {

    
    @IBOutlet weak var nameLbl: UILabel!
        
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(parcel: Parcel ) {
        nameLbl.text = parcel.display_identifier
    }

}
