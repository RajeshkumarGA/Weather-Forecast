//
//  FavoriteDestinationsCell.swift
//  Weather forecast
//
//  Created by RajeshKumar on 25/03/21.
//

import UIKit

class FavoriteDestinationsCell: UITableViewCell {
    
    @IBOutlet weak var cityName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
