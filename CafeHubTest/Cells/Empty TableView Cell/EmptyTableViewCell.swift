//
//  EmptyTableViewCell.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 03.02.22.
//

import UIKit

class EmptyTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell() {
        titleLabel.text = "No saved places found, you can mark places as saved to view them here."
    }
    
}
