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
    var firebasePlace: Cafe!
    var placeImage: UIImage!
    var checkButton = true
    
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var openingHoursLabel: UILabel!
    @IBOutlet weak var tagList: TagListView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainImage.image = placeImage
        
        if let savedPlace = savedPlace {
            firebasePlace = Cafe(name: savedPlace.name!, address: savedPlace.address!, zip: savedPlace.zip!, imageLink: savedPlace.imageLink!, type: savedPlace.type!, rating: savedPlace.rating, placeDescription: savedPlace.placeDescription!, openingHours: savedPlace.openingHours!)
        }
        
        titleLabel.text = firebasePlace.name
        addressLabel.text = firebasePlace.address
        openingHoursLabel.text = firebasePlace.openingHours
        descriptionLabel.text = firebasePlace.placeDescription
        tagList.textFont = UIFont.systemFont(ofSize: 15, weight: .regular)
        tagList.addTags(firebasePlace.type)
        
        if let check = findPlace(name: firebasePlace!.name) {
            if check {
                saveButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                self.checkButton = false
            } else {
                saveButton.setImage(UIImage(systemName: "heart"), for: .normal)
            }
        }
        
    }
    
    @IBAction func closeView(_ sender: UIButton) {
        dismiss(animated: true) {
            //TODO: add reload to the views
            
        }
    }
    
    @IBAction func didPressSave(_ sender: UIButton) {
        if checkButton {
            UIView.transition(with: sender, duration: 0.5, options: .curveEaseIn, animations: {
                sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }, completion: {_ in
                self.savePlace(place: self.firebasePlace)
            })
            checkButton = false
        } else {
            //saveButton.setImage(UIImage(systemName: "plus"), for: .normal)
            UIView.transition(with: sender, duration: 0.5, options: .curveEaseIn, animations: {
                sender.setImage(UIImage(systemName: "heart"), for: .normal)
            }, completion: {_ in
                self.deletePlace(name: self.firebasePlace!.name)
            })
            checkButton = true
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "nameOfNotification"), object: nil)
    }
    
    func checkSavedPlace() -> Bool {
        if let place = firebasePlace {
            if let savedPlaces = loadAllSavedPlaces() {
                if savedPlaces.isEmpty {
                    //self.savePlace(place: place)
                    self.checkButton = false
                    return false
                }
                
                for savedPlace in savedPlaces {
                    if (savedPlace.name != place.name) {
                        self.checkButton = false
                        //self.savePlace(place: place)
                        return false
                    } else {
                        self.checkButton = true
                        //self.deletePlace(name: place.name)
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func savePlace(place: Cafe) {
        StorageManager.sharedManager.addPlace(name: place.name, address: place.address, zip: place.zip,
                                              imageLink: place.imageLink, rating: place.rating, type: place.type, placeDescription: place.placeDescription, openingHours: place.openingHours)
    }
    
    func deletePlace(name: String) {
        StorageManager.sharedManager.delete(name: name)
    }
    
    func findPlace(name: String) -> Bool? {
        return StorageManager.sharedManager.find(name: name)
    }
    
    func loadAllSavedPlaces() -> [Cafe]? {
        return StorageManager.sharedManager.fetchAllSavedPlacesAsCafe()
    }
    
    func animateView(_ viewToAnimate: UIView) {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.5, options: .curveEaseIn) {
            viewToAnimate.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        } completion: { _ in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {viewToAnimate.transform = CGAffineTransform(scaleX: 1, y: 1)}, completion: nil)
        }
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
