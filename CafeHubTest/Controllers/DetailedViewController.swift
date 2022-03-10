//
//  DetailedViewController.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 20.01.22.
//

import UIKit
import TagListView
import SDWebImage
import FirebaseStorage
import MapKit

class DetailedViewController: UIViewController {
    let storage = Storage.storage()
    
    var savedPlace: SavedPlaces?
    var firebasePlace: Cafe!
    var placeImage: UIImage?
    var checkButton = true
    let defaults = UserDefaults.standard
    private var userTypes: [String] = [String]()
    
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var openingHoursLabel: UILabel!
    @IBOutlet weak var tagList: TagListView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(DetailedViewController.didPressAddress))
        addressLabel.isUserInteractionEnabled = true
        addressLabel.addGestureRecognizer(tap)
        
        configureView()
    }
    
    func configureView() {
        
        if let types = (defaults.array(forKey: "PlaceTypeList") as? [String]) {
            userTypes.append(contentsOf: types)
        }
        
        if let savedPlace = savedPlace {
            firebasePlace = Cafe(id: savedPlace.id, name: savedPlace.name!, address: savedPlace.address!, zip: savedPlace.zip!, imageLink: savedPlace.imageLink!, type: savedPlace.type!, rating: savedPlace.rating, openingHours: savedPlace.openingHours!)
        }
        
        if let image = placeImage {
            mainImage.image = image
        } else {
            self.mainImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.mainImage.sd_imageIndicator?.startAnimatingIndicator()
            self.mainImage.sd_setImage(with: URL(string: firebasePlace.imageLink), placeholderImage: UIImage(named: "Cafe_Placeholder"), options: .continueInBackground) {
                _,_,_,_ in
                self.mainImage.sd_imageIndicator?.stopAnimatingIndicator()
            }
        }
        
        titleLabel.text = firebasePlace.name
        addressLabel.text = firebasePlace.address
        openingHoursLabel.text = firebasePlace.openingHours.replacingOccurrences(of: ", ", with: "\n")
        tagList.textFont = UIFont.systemFont(ofSize: 15, weight: .regular)
        tagList.addTags(firebasePlace.type)
        
        if findPlace(id: firebasePlace!.id) != nil {
            saveButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            self.checkButton = false
        } else {
            saveButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    
    @IBAction func closeView(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func didPressSave(_ sender: UIButton) {
        if checkButton {
            UIView.transition(with: sender, duration: 0.5, options: .curveEaseIn, animations: {
                sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }, completion: {_ in
                self.savePlace(place: self.firebasePlace)
                self.userTypes.append(contentsOf: self.firebasePlace.type)
                self.defaults.set(Array(Set(self.userTypes)), forKey: "PlaceTypeList")
            })
            checkButton = false
        } else {
            //saveButton.setImage(UIImage(systemName: "plus"), for: .normal)
            UIView.transition(with: sender, duration: 0.5, options: .curveEaseIn, animations: {
                sender.setImage(UIImage(systemName: "heart"), for: .normal)
            }, completion: {_ in
                self.deletePlace(id: self.firebasePlace!.id)
                self.userTypes.removeLast(self.firebasePlace.type.count)
            })
            checkButton = true
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "savedPlaceChangeValue"), object: nil)
    }
    
    //action when pressing on address label to show it in Apple Maps or Google Maps
    @IBAction func didPressAddress(sender: UITapGestureRecognizer) {
        openMapButtonAction()
    }
    
    func openMapButtonAction() {

        firebasePlace.getCoordinate { coordinates, err in
            let latitude = coordinates.coordinate.latitude
            let longitude = coordinates.coordinate.longitude
            
            let appleURL = "http://maps.apple.com/?daddr=\(latitude),\(longitude)"
            let googleURL = "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=driving"
            
            let googleItem = ("Google Map", URL(string:googleURL)!)
            var installedNavigationApps = [("Apple Maps", URL(string:appleURL)!)]
            
            if UIApplication.shared.canOpenURL(googleItem.1) {
                installedNavigationApps.append(googleItem)
            }
            
            let alert = UIAlertController(title: "Choose App for Map", message: "Select Navigation App", preferredStyle: .actionSheet)
            for app in installedNavigationApps {
                let button = UIAlertAction(title: app.0, style: .default, handler: { _ in
                    UIApplication.shared.open(app.1, options: [:], completionHandler: nil)
                })
                alert.addAction(button)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true)
        }
    }
    
    func savePlace(place: Cafe) {
        StorageManager.sharedManager.addPlace(id: place.id, name: place.name, address: place.address, zip: place.zip,
                                              imageLink: place.imageLink, rating: place.rating, type: place.type, openingHours: place.openingHours, wantToGo: false)
    }
    
    func deletePlace(id: Int16) {
        StorageManager.sharedManager.delete(id: id)
    }
    
    func findPlace(id: Int16) -> SavedPlaces? {
        return StorageManager.sharedManager.find(id: id)
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
