//
//  DetailedViewController.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 20.01.22.
//

import UIKit
import TagListView

class DetailedViewController: UIViewController {

    var savedPlace: SavedPlaces?
    var firebasePlace: Cafe?
    var placeImage: UIImage!
    
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var openingHoursLabel: UILabel!
    @IBOutlet weak var tagList: TagListView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainImage.image = placeImage
        
        if let savedPlace = savedPlace {
            titleLabel.text = savedPlace.name
            addressLabel.text = savedPlace.address
            openingHoursLabel.text = savedPlace.openingHours
            descriptionLabel.text = savedPlace.placeDescription
            tagList.textFont = UIFont.systemFont(ofSize: 15, weight: .regular)
            tagList.addTags(savedPlace.type!)
        }
        
        if let firebasePlace = firebasePlace {
            titleLabel.text = firebasePlace.name
            addressLabel.text = firebasePlace.address
            openingHoursLabel.text = firebasePlace.openingHours
            descriptionLabel.text = firebasePlace.placeDescription
            tagList.textFont = UIFont.systemFont(ofSize: 15, weight: .regular)
            tagList.addTags(firebasePlace.type)
        }
        
    }
    
    @IBAction func closeView(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
