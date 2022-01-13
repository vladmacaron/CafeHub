//
//  SavedPlacesController.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 13.01.22.
//

import UIKit
import TagListView
import SDWebImage
import FirebaseFirestore
import FirebaseStorage

class SavedPlacesController: UIViewController {
    let db = Firestore.firestore()
    let storage = Storage.storage()

    private var filterPlaces: [Cafe] = [Cafe]()
    private var savedPlaces: [SavedPlaces] = [SavedPlaces]()
    private var placesNames: [String] = [String]()
    private var filterPlacesNames: [String] = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "PlaceTableViewCell", bundle: nil), forCellReuseIdentifier: "generalTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        //searchBar.delegate = self
        //tableView.prefetchDataSource = self
        if let tempSavedPlaces = self.loadAllSavedPlaces() {
            savedPlaces = tempSavedPlaces
        }
        
        self.loadPlacesNames()
        tableView.reloadData()
    }
    
    func loadPlaces() {
        db.collection("places").limit(to: 20).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let place = document.data()
                    self.filterPlaces.append(Cafe(name: place["name"] as! String, address: place["address"] as! String, zip: place["zip"] as! String, imageLink: place["imageLink"] as! String, type: place["type"] as! [String], rating: place["rating"] as! Double))
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func loadPlacesNames() {
        if let places = StorageManager.sharedManager.fetchAllSavedPlaces() {
            for place in places {
                self.placesNames.append(place.name!)
            }
        }
    }

    func loadAllSavedPlaces() -> [SavedPlaces]? {
        if let places = StorageManager.sharedManager.fetchAllSavedPlaces() {
            return places
        } else {
            return nil
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

extension SavedPlacesController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "generalTableViewCell", for: indexPath) as! PlaceTableViewCell
        //let place = places[indexPath.row]
        let place = savedPlaces[indexPath.row]
        
        cell.saveButton.isHidden = true
        
        cell.tag = indexPath.row
        
        cell.titleLabel.text = place.name
        cell.tagList.addTags(place.type!)
        cell.zipLabel.text = place.zip
        
        cell.placeImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.placeImage.sd_imageIndicator?.startAnimatingIndicator()
        let imageRef = storage.reference(forURL: place.imageLink!)
        imageRef.downloadURL { url, err in
            if let err = err {
                print("Failed generating url: \(err)")
            } else {
                if cell.tag == indexPath.row {
                    cell.placeImage.sd_imageIndicator?.stopAnimatingIndicator()
                    cell.placeImage.sd_setImage(with: url, placeholderImage: UIImage(named: "Cafe_Menta_index"), options: .continueInBackground)
                }
            }
        }
        
        return cell
    }
}

extension SavedPlacesController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 180
    }
}

/*extension SavedPlacesController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
        if(searchText.isEmpty) {
            filterPlacesNames = placesNames
        } else {
            filterPlacesNames = placesNames.filter({ (dataString: String) -> Bool in
                if dataString.range(of: searchText, options: .caseInsensitive) != nil {
                    return true
                } else {
                    return false
                }
            })
            
            if !filterPlacesNames.isEmpty {
                db.collection("places").whereField("name", in: filterPlacesNames).getDocuments { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        self.filterPlaces.removeAll()
                        for document in querySnapshot!.documents {
                            let place = document.data()
                            self.filterPlaces.append(Cafe(name: place["name"] as! String, address: place["address"] as! String, zip: place["zip"] as! String, imageLink: place["imageLink"] as! String, type: place["type"] as! [String], rating: place["rating"] as! Double))
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        
        self.tableView.reloadData()
    }
    
    func savePlace(place: Cafe) {
        StorageManager.sharedManager.addPlace(name: place.name, address: place.address, zip: place.zip,
                                              imageLink: place.imageLink, rating: place.rating, type: place.type)
    }
    
    func deletePlace(name: String) {
        StorageManager.sharedManager.delete(name: name)
    }

}*/
