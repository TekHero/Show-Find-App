//
//  ProductCell.swift
//  TV-Show-Track
//
//  Created by Brian Lim on 2/15/16.
//  Copyright © 2016 codebluapps. All rights reserved.
//

import UIKit

class ProductCell: UITableViewCell {
    
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var productTitleLbl: UILabel!
    @IBOutlet weak var productDescLbl: UILabel!
    @IBOutlet weak var purchasedLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
