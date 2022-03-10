//
//  ConciergeViewController.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 10.01.22.
//

import UIKit
import FirebaseFirestore
import CoreLocation

class ConciergeViewController: UIViewController {

    let db = Firestore.firestore()
    let sharedPlaces = PlaceManager.shared
    
    var randomArr: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if LandscapeManager.shared.isFirstLaunch {
            performSegue(withIdentifier: "toOnboarding", sender: nil)
            LandscapeManager.shared.isFirstLaunch = true
            //   TESTING
            //LandscapeManager.shared.isFirstLaunch = false
        } else {
            loadData()
        }
    }
    
    func loadData() {
        for _ in 1...10 {
            randomArr.append(Int.random(in: 1..<535))
        }
        
        let group = DispatchGroup()
        db.collection("places")
            .whereField("id", in: randomArr)
            .limit(to: 10).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let place = document.data()
                    self.sharedPlaces.places.append(Cafe(id: place["id"] as! Int16, name: place["name"] as! String, address: place["address"] as! String, zip: place["zip"] as! String, imageLink: place["imageLink"] as! String, type: place["type"] as! [String], rating: place["rating"] as! Double, openingHours: place["openingHours"] as! String))
                }
                
                self.sharedPlaces.places.forEach { cafe in
                    group.enter()
                    cafe.getCoordinate { locationCL, err in
                        cafe.location = locationCL
                        group.leave()
                    }
                }
            }
            group.notify(queue: .main) {
                self.performSegue(withIdentifier: "toMain", sender: nil)
            }
        }
        
    }
    
    func getCoordinate(_ address: String, completionHandler: @escaping(CLLocation, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?.first {
                    let locationCL = placemark.location!
                    completionHandler(locationCL, nil)
                    return
                }
            }
        }
    }
}
