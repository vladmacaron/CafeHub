//
//  PlaceTableViewCell.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 12.01.22.
//

import UIKit
import TagListView
import SDWebImage

class PlaceTableViewCell: UITableViewCell {

    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagList: TagListView!
    @IBOutlet weak var zipLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        placeImage.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        tagList.removeAllTags()
        placeImage.image = nil
        //placeImage.sd_cancelCurrentImageLoad()
    }
    
}
