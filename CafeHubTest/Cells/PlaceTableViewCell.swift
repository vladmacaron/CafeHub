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
        
        if let place = item {
            configureCellforSavedPlaces(place: place)
        }
    }
    
    func configureCellforSavedPlaces(place: SavedPlaces) {
        saveButton.isHidden = true
        
        titleLabel.text = place.name
        tagList.addTags(place.type!)
        zipLabel.text = place.zip
        
        placeImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        placeImage.sd_imageIndicator?.startAnimatingIndicator()
        let imageRef = storage.reference(forURL: place.imageLink!)
        imageRef.downloadURL { url, err in
            if let err = err {
                print("Failed generating url: \(err)")
            } else {
                //if cell.tag == indexPath.row {
                self.placeImage.sd_imageIndicator?.stopAnimatingIndicator()
                self.placeImage.sd_setImage(with: url, placeholderImage: UIImage(named: "Cafe_Menta_index"), options: .continueInBackground)
                //}
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        tagList.removeAllTags()
        placeImage.image = nil
        //placeImage.sd_cancelCurrentImageLoad()
    }
    
    @IBAction func didPressSaveButton(_ sender: UIButton) {
        cellDelegate?.didPressButton(sender.tag)
        
        if checkButton {
            UIView.transition(with: sender, duration: 0.5, options: .transitionFlipFromRight, animations: {
                sender.setImage(UIImage(systemName: "checkmark"), for: .normal)
                        }, completion: nil)
            //saveButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            checkButton = false
        } else {
            //saveButton.setImage(UIImage(systemName: "plus"), for: .normal)
            UIView.transition(with: sender, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                sender.setImage(UIImage(systemName: "plus"), for: .normal)
                        }, completion: nil)
            checkButton = true
        }
    }
}
