//
//  IndexedCollectionViewCell.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 07.11.21.
//

import UIKit
import TagListView
import Cosmos

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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = 10
        
        //TODO: find better way to blur bottom of the imageview
        /*let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        //blurView.frame = CGRect(x: mainStackView.bounds.minX, y: mainStackView.bounds.minY, width: mainStackView.bounds.width+10, height: mainStackView.bounds.height+1)
        blurView.frame = mainStackView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainStackView.addSubview(blurView)
        mainStackView.layer.masksToBounds = true
        mainStackView.layer.cornerRadius = 5
        mainStackView.addSubview(titleLabel)
        mainStackView.addSubview(ratingView)*/
        
        titleLabel.textColor = .white
    }

    override func prepareForReuse() {
        tagListView.removeAllTags()
    }
}
