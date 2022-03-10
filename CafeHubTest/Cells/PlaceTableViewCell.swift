//
//  PlaceTableViewCell.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 12.01.22.
//

import UIKit
import TagListView
import SDWebImage
import FirebaseStorage

protocol PlaceTableViewCellDelegate: AnyObject {
    func didPressButton(_ tag: Int)
}

class PlaceTableViewCell: UITableViewCell {

    let storage = Storage.storage()
    var item: SavedPlaces?
    
    var cellDelegate: PlaceTableViewCellDelegate?
    var checkButton = true
    
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagList: TagListView!
    @IBOutlet weak var zipLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var blurView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        placeImage.layer.cornerRadius = 10
        
        blurView.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurViewEffect = UIVisualEffectView(effect: blurEffect)
        blurViewEffect.frame = blurView.bounds
        blurViewEffect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.addSubview(blurViewEffect)
        blurView.layer.masksToBounds = true
        blurView.layer.cornerRadius = 10
        blurView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
    }
    
    func configureCellForSearchViewController(place: Cafe) {
        saveButton.isHidden = true
        
        titleLabel.text = place.name
        if let placeTag = place.type.first {
            tagList.addTag(placeTag)
        }
        zipLabel.text = place.zip
        
        placeImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        placeImage.sd_imageIndicator?.startAnimatingIndicator()
        placeImage.sd_setImage(with: URL(string: place.imageLink), placeholderImage: UIImage(named: "Cafe_Placeholder"), options: .continueInBackground) {
            _,_,_,_ in
            self.placeImage.sd_imageIndicator?.stopAnimatingIndicator()
        }
    }
    
    func configureCellforOnboardingController(place: Cafe) {
        //saveButton.setImage(UIImage(systemName: "heart"), for: .normal)
        titleLabel.text = place.name
        tagList.addTags(place.type)
        zipLabel.text = place.zip
        
        placeImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        placeImage.sd_imageIndicator?.startAnimatingIndicator()
        placeImage.sd_setImage(with: URL(string: place.imageLink), placeholderImage: UIImage(named: "Cafe_Placeholder"), options: .continueInBackground) {
            _,_,_,_ in
            self.placeImage.sd_imageIndicator?.stopAnimatingIndicator()
        }
    }
    
    func configureCellforSavedPlacesController(place: SavedPlaces) {
        saveButton.isHidden = true
        
        titleLabel.text = place.name
        tagList.addTags(place.type!)
        zipLabel.text = place.zip
        
        placeImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        placeImage.sd_imageIndicator?.startAnimatingIndicator()
        placeImage.sd_setImage(with: URL(string: place.imageLink!), placeholderImage: UIImage(named: "Cafe_Placeholder"), options: .continueInBackground) {
            _,_,_,_ in
            self.placeImage.sd_imageIndicator?.stopAnimatingIndicator()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        tagList.removeAllTags()
        placeImage.image = nil
        saveButton.setImage(UIImage(systemName: "heart"), for: .normal)
        //placeImage.sd_cancelCurrentImageLoad()
    }
    
    @IBAction func didPressSaveButton(_ sender: UIButton) {
        cellDelegate?.didPressButton(sender.tag)
        
        if checkButton {
            /*UIView.transition(with: sender, duration: 0.5, options: .transitionFlipFromRight, animations: {
                sender.setImage(UIImage(systemName: "checkmark"), for: .normal)
                        }, completion: nil)*/
            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            checkButton = false
        } else {
            /*UIView.transition(with: sender, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                sender.setImage(UIImage(systemName: "plus"), for: .normal)
                        }, completion: nil)*/
            sender.setImage(UIImage(systemName: "heart"), for: .normal)
            checkButton = true
        }
    }
}
