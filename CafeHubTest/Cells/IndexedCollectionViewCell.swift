//
//  IndexedCollectionViewCell.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 07.11.21.
//

import UIKit
import TagListView
import Cosmos
import SDWebImage

class IndexedCollectionViewCell: UICollectionViewCell {

    static let identifier: String = "collectionViewCellID"
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var zipLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var matchLabel: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var blurView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = 10
        
        blurView.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurViewEffect = UIVisualEffectView(effect: blurEffect)
        blurViewEffect.frame = blurView.bounds
        blurViewEffect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.addSubview(blurViewEffect)
        blurView.layer.masksToBounds = true
        blurView.layer.cornerRadius = 10
        blurView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        titleLabel.textColor = .white
    }

    override func prepareForReuse() {
        tagListView.removeAllTags()
        imageView.image = nil
    }
}
