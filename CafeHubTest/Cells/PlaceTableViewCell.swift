//
//  PlaceTableViewCell.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 12.01.22.
//

import UIKit
import TagListView
import SDWebImage

protocol PlaceTableViewCellDelegate: AnyObject {
    func didPressButton(_ tag: Int)
}

class PlaceTableViewCell: UITableViewCell {

    var cellDelegate: PlaceTableViewCellDelegate?
    var checkButton = true
    
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagList: TagListView!
    @IBOutlet weak var zipLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        placeImage.layer.cornerRadius = 10
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
