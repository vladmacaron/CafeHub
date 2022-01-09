//
//  IndexedCollectionViewCell.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 07.11.21.
//

import UIKit
import TagListView

class IndexedCollectionViewCell: UICollectionViewCell {

    static let identifier: String = "collectionViewCellID"
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var zipLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var matchLabel: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var imageView: UIImageView!
    //var types: [String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //tagListView.addTags(types)
        imageView.layer.cornerRadius = 10
    }

}
