//
//  ConciergeViewController.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 10.01.22.
//

import UIKit
import FirebaseFirestore

class ConciergeViewController: UIViewController {

    let db = Firestore.firestore()
    let sharedPlaces = PlaceManager.shared
    
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
        //needs limit?
        db.collection("places").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let place = document.data()
                    self.sharedPlaces.places.append(Cafe(name: place["name"] as! String, address: place["address"] as! String, zip: place["zip"] as! String, imageLink: place["imageLink"] as! String, type: place["type"] as! [String], rating: place["rating"] as! Double, placeDescription: place["description"] as! String, openingHours: place["openingHours"] as! String))
                }
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toMain", sender: nil)
                }
            }
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
