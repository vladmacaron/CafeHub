//
//  SecondOnboardingViewController.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 10.01.22.
//

import UIKit
import TagListView
import SDWebImage
import FirebaseFirestore
import FirebaseStorage

class SecondOnboardingViewController: UIViewController {
    let db = Firestore.firestore()
    let storage = Storage.storage()

    private var filterPlaces: [Cafe] = [Cafe]()
    private var placesNames: [String] = [String]()
    private var filterPlacesNames: [String] = [String]()

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "PlaceTableViewCell", bundle: nil), forCellReuseIdentifier: "generalTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        
        self.loadPlaces()
        self.loadPlacesNames()
        tableView.reloadData()
        searchBar.delegate = self
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if let pageController = parent as? OnboardingPageViewController {
            pageController.pushNext()
        }
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
        db.collection("places").order(by: "name").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let place = document.data()
                    self.placesNames.append(place["name"] as! String)
                }
            }
        }
    }

}

extension SecondOnboardingViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "generalTableViewCell", for: indexPath) as! PlaceTableViewCell
        //let place = places[indexPath.row]
        let place = filterPlaces[indexPath.row]
        
        cell.saveButton.setImage(UIImage(systemName: "plus"), for: .normal)
        
        cell.cellDelegate = self
        cell.tag = indexPath.row
        cell.saveButton.tag = indexPath.row
        
        if let savedPlaces = loadAllSavedPlaces() {
            for savedPlace in savedPlaces {
                if (savedPlace.name == place.name) {
                    cell.saveButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
                    cell.checkButton = false
                }
            }
        }
        
        cell.titleLabel.text = place.name
        cell.tagList.addTags(place.type)
        cell.zipLabel.text = place.zip
        
        let imageRef = storage.reference(forURL: place.imageLink)
        imageRef.downloadURL { url, err in
            if let err = err {
                print("Failed generating url: \(err)")
            } else {
                if cell.tag == indexPath.row {
                    cell.placeImage.sd_setImage(with: url, placeholderImage: UIImage(named: "Cafe_Menta_index"), options: .continueInBackground)
                }
            }
        }
        
        return cell
    }
    
}

extension SecondOnboardingViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 180
    }
}

extension SecondOnboardingViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        <#code#>
    }
    
    
}

extension SecondOnboardingViewController: UISearchBarDelegate {
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
    
    func loadAllSavedPlaces() -> [Cafe]? {
        return StorageManager.sharedManager.fetchAllSavedPlacesAsCafe()
    }
}

extension SecondOnboardingViewController: PlaceTableViewCellDelegate {
    func didPressButton(_ tag: Int) {
        let place = filterPlaces[tag]
        
        if let savedPlaces = loadAllSavedPlaces() {
            if savedPlaces.isEmpty {
                self.savePlace(place: place)
                return
            }
            
            for savedPlace in savedPlaces {
                if (savedPlace.name != place.name) {
                    self.savePlace(place: place)
                    return
                } else {
                    self.deletePlace(name: place.name)
                    return
                }
            }
        }
    }
}

//TODO: add prefetching, infintie scrolling
