//
//  IndexedCollectionViewCell.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 07.11.21.
//

import UIKit

class IndexedCollectionViewCell: UICollectionViewCell {

    static let identifier: String = "collectionViewCellID"
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var zipLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var matchLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //imageView.image = UIImage(named: "Cafe_Menta_index")
        imageView.layer.cornerRadius = 10
    }

}
