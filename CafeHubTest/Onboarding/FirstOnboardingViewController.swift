//
//  FirstOnboardingViewController.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 10.01.22.
//

import UIKit
import TagListView
import SDWebImage
import FirebaseFirestore
import FirebaseStorage

class FirstOnboardingViewController: UIViewController {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    let sharedPlaces = PlaceManager.shared
    var lastDocument: QueryDocumentSnapshot?

    private var initialPlaces: [Cafe] = [Cafe]()
    private var filterPlaces: [Cafe] = [Cafe]()
    private var placesNames: [String] = [String]()
    private var filterPlacesNames: [String] = [String]()
    private var imageURLsArray: [URL] = [URL]()
    var tags: [String] = [String]()

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "PlaceTableViewCell", bundle: nil), forCellReuseIdentifier: "generalTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.prefetchDataSource = self
        
        self.loadPlaces()
        self.loadPlacesNames()

        tableView.reloadData()
        searchBar.delegate = self
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if let pageController = parent as? OnboardingPageViewController {
            pageController.tags = Array(Set(self.tags))
            pageController.pushNext()
        }
    }
    
    /*func loadPlaces(with limit: Int) {
        db.collection("places").limit(to: limit).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let place = document.data()
                    self.filterPlaces.append(Cafe(name: place["name"] as! String, address: place["address"] as! String, zip: place["zip"] as! String, imageLink: place["imageLink"] as! String, type: place["type"] as! [String], rating: place["rating"] as! Double))
                    self.initialPlaces.append(contentsOf: self.filterPlaces)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }*/
    
    func loadPlaces() {
        db.collection("places").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.lastDocument = querySnapshot?.documents.last
                self.filterPlaces.removeAll()
                for document in querySnapshot!.documents {
                    let place = document.data()
                    self.filterPlaces.append(Cafe(id: place["id"] as! Int16, name: place["name"] as! String, address: place["address"] as! String, zip: place["zip"] as! String, imageLink: place["imageLink"] as! String, type: place["type"] as! [String], rating: place["rating"] as! Double, openingHours: place["openingHours"] as! String))
                    self.sharedPlaces.places.append(Cafe(id: place["id"] as! Int16, name: place["name"] as! String, address: place["address"] as! String, zip: place["zip"] as! String, imageLink: place["imageLink"] as! String, type: place["type"] as! [String], rating: place["rating"] as! Double, openingHours: place["openingHours"] as! String))
                    self.tags.append(contentsOf: place["type"] as! [String])
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
    
    func loadLocalData() {
        filterPlaces.append(contentsOf: sharedPlaces.places)
        filterPlaces.sort { c1, c2 in
            c1.name<c2.name
        }
    }

}

extension FirstOnboardingViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "generalTableViewCell", for: indexPath) as! PlaceTableViewCell
        //let place = places[indexPath.row]
        let place = filterPlaces[indexPath.row]
        
        cell.cellDelegate = self
        cell.tag = indexPath.row
        cell.saveButton.tag = indexPath.row
        
        if let savedPlaces = loadAllSavedPlaces() {
            if savedPlaces.contains(where: { cafe in
                if cafe.name == place.name {
                    return true
                } else {
                    return false
                }
            }) {
                cell.saveButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                cell.checkButton = false
            }
        }
        
        cell.configureCellforOnboardingController(place: place)
        
        return cell
    }
    
}

extension FirstOnboardingViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 180
    }
}

/*extension FirstOnboardingViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if let lastDocument = self.lastDocument {
            self.db.collection("places")
                .limit(to: indexPaths.count)
                .start(afterDocument: lastDocument).getDocuments { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        self.lastDocument = querySnapshot?.documents.last
                        for document in querySnapshot!.documents {
                            let place = document.data()
                            self.filterPlaces.append(Cafe(id: place["id"] as! Int16, name: place["name"] as! String, address: place["address"] as! String, zip: place["zip"] as! String, imageLink: place["imageLink"] as! String, type: place["type"] as! [String], rating: place["rating"] as! Double, openingHours: place["openingHours"] as! String))
                        }
                        //TODO: SHOULD BE FIXED
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
        }
        
    }
    
}*/

extension FirstOnboardingViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
        if(searchText.isEmpty) {
            filterPlacesNames = placesNames
            loadLocalData()
            self.tableView.reloadData()
        } else {
            filterPlacesNames = placesNames.filter({ (dataString: String) -> Bool in
                if dataString.range(of: searchText, options: .caseInsensitive) != nil {
                    return true
                } else {
                    return false
                }
            })
            
            if !filterPlacesNames.isEmpty {
                self.filterPlaces.removeAll()
                print(filterPlacesNames)
                for name in filterPlacesNames {
                    if let place = self.sharedPlaces.places.first(where: {$0.name==name}) {
                        
                        self.filterPlaces.append(place)
                    }
                }
                self.tableView.reloadData()
            }
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func savePlace(place: Cafe) {
        StorageManager.sharedManager.addPlace(id: place.id, name: place.name, address: place.address, zip: place.zip,
                                              imageLink: place.imageLink, rating: place.rating, type: place.type, openingHours: place.openingHours, wantToGo: false)
    }
    
    func deletePlace(id: Int16) {
        StorageManager.sharedManager.delete(id: id)
    }
    
    func loadAllSavedPlaces() -> [Cafe]? {
        return StorageManager.sharedManager.fetchAllSavedPlacesAsCafe()
    }
}

extension FirstOnboardingViewController: PlaceTableViewCellDelegate {
    func didPressButton(_ tag: Int) {
        let place = filterPlaces[tag]
        var check = false
        
        if let savedPlaces = loadAllSavedPlaces() {
            if savedPlaces.isEmpty {
                self.savePlace(place: place)
                return
            }
            
            for savedPlace in savedPlaces {
                if (savedPlace.name == place.name) {
                    check = true
                }
            }
            if check {
                self.deletePlace(id: place.id)
                return
            } else {
                self.savePlace(place: place)
                return
            }
        }
    }
}

