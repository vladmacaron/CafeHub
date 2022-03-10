//
//  HomeScreenController.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 07.11.21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import TagListView
import SDWebImage
import MapKit

class HomeScreenController: UIViewController {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    let locationManager = CLLocationManager()
    let sharedPlaces = PlaceManager.shared

    var places: [[Cafe]] = [[], [], [], []]
    var trendingList: [Int] = []
    
    static let tableCellID: String = "tableViewCellID_section_#"
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    let defaultLocation = CLLocation(latitude: 48.209131857255954, longitude: 16.37417610826001)
    let numberOfCollectionItems: Int = 20
    
    // Set true to enable UICollectionViews scroll pagination
    var paginationEnabled: Bool = true
    
    //parameters for FlowLayout
    let collectionTopInset: CGFloat = 0
    let collectionBottomInset: CGFloat = 0
    let collectionLeftInset: CGFloat = 10
    let collectionRightInset: CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //locationManager.requestWhenInUseAuthorization()
        checkLocationServices()
        
        tableView.dataSource = self
        tableView.delegate = self
        locationManager.delegate = self
        //self.loadData()
        
        //spinner.startAnimating()
        //tableView.isHidden = true
        
        //self.loadTrendingPlaces()
        //self.loadPlaces()
        self.loadData()
        self.loadTrendingPlaces()
        self.loadSavedPlaces()
        self.loadBackgroundData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ReloadData), name: NSNotification.Name(rawValue: "toGoPlaceChangeValue"), object: nil)
    }
    
    @objc func ReloadData(notification: NSNotification) {
        DispatchQueue.main.async {
            self.places[3].removeAll()
            self.loadSavedPlaces()
            self.tableView.reloadData()
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // Show an alert letting them know what’s up
            break
        case .authorizedAlways:
            break
        @unknown default:
            fatalError("location access error")
        }
    }
    
    func sortPlacesByLocation() {
        if self.locationManager.location != nil {
            self.places[2].sort { lhs, rhs in
                self.locationManager.location!.distance(from: lhs.location!) < self.locationManager.location!.distance(from: rhs.location!)
            }
        } else {
            self.places[2].sort { lhs, rhs in
                self.defaultLocation.distance(from: lhs.location!) < self.defaultLocation.distance(from: rhs.location!)
            }
        }
    }
    
    func sortPlacesByMatch() {
        self.places[1].sort { lhs, rhs in
            lhs.calculateMatch() > rhs.calculateMatch()
        }
    }

    func loadData() {
        DispatchQueue.main.async {
            self.places[1].append(contentsOf: self.sharedPlaces.places[0..<10])
            self.sortPlacesByMatch()
            self.places[2].append(contentsOf: self.sharedPlaces.places[0..<10])
            self.sortPlacesByLocation()
            self.tableView.reloadData()
        }
    }
    
    func loadTrendingPlaces() {
        let trendingList = db.collection("categories").document("trending")
        trendingList.getDocument { document, err in
            if let document = document, document.exists {
                let trendingPlaces = document.data()!["placesID"] as? [Any]
                for place in trendingPlaces! {
                    self.trendingList.append(place as! Int)
                }
                self.db.collection("places").whereField("id", in: self.trendingList).getDocuments { querySnapshot, err in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            let place = document.data()
                            self.places[0].append(Cafe(id: place["id"] as! Int16, name: place["name"] as! String, address: place["address"] as! String, zip: place["zip"] as! String, imageLink: place["imageLink"] as! String, type: place["type"] as! [String], rating: place["rating"] as! Double, openingHours: place["openingHours"] as! String))
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
                
            } else {
                print("Trending document does not exist")
            }
        }
    }
    
    func loadBackgroundData() {
        var sharedPlacesID : [Int16] = []
        sharedPlaces.places.forEach { place in
            sharedPlacesID.append(place.id)
        }
        
        db.collection("places")
            .whereField("id", notIn: sharedPlacesID)
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let place = document.data()
                        //DispatchQueue.main.async {
                        self.sharedPlaces.places.append(Cafe(id: place["id"] as! Int16, name: place["name"] as! String, address: place["address"] as! String, zip: place["zip"] as! String, imageLink: place["imageLink"] as! String, type: place["type"] as! [String], rating: place["rating"] as! Double, openingHours: place["openingHours"] as! String))
                        //}
                    }
                    
                    
                }
            }
    }
    
    func loadSavedPlaces() {
        if let savedPlaces = StorageManager.sharedManager.fetchAllPlacesToGoAsCafe() {
            self.places[3].append(contentsOf: savedPlaces)
        }
    }
    
    func presentDetailedViewController(with data: Cafe, image: UIImage) {
        let secondViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailedViewController") as! DetailedViewController
        
        //secondViewController.transitioningDelegate = self
        secondViewController.sheetPresentationController?.detents = [.medium(), .large()]
        secondViewController.modalPresentationStyle = .popover
        secondViewController.firebasePlace = data
        secondViewController.placeImage = image
        present(secondViewController, animated: true)
    }

}

//MARK: - TableView Data Source

extension HomeScreenController: UITableViewDataSource {
    
    func numberOfSections(in _: UITableView) -> Int {
        if places[3].count == 0 {
            return places.count-1
        } else {
            return places.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Instead of having a single cellIdentifier for each type of
        // UITableViewCells, like in a regular implementation, we have multiple
        // cellIDs, each related to a indexPath section. By Doing so the
        // UITableViewCells will still be recycled but only with
        // dequeueReusableCell of that section.
        //
        // For example the cellIdentifier for section 4 cells will be:
        //
        // "tableViewCellID_section_#3"
        //
        // dequeueReusableCell will only reuse previous UITableViewCells with
        // the same cellIdentifier instead of using any UITableViewCell as a
        // regular UITableView would do, this is necessary because every cell
        // will have a different UICollectionView with UICollectionViewCells in
        // it and UITableView reuse won't work as expected giving back wrong
        // cells.
        
        var cell: CollectionTableViewCell? = tableView.dequeueReusableCell(withIdentifier: HomeScreenController.tableCellID + indexPath.section.description) as? CollectionTableViewCell

        if cell == nil {
            cell = CollectionTableViewCell(style: .default, reuseIdentifier: HomeScreenController.tableCellID + indexPath.section.description)

            // Configure the cell...
            cell?.selectionStyle = .none
            cell?.collectionViewPaginatedScroll = paginationEnabled
        }

        return cell!
    }
    
    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "New Places in the City:"
        case 1:
            return "You may like:"
        case 2:
            return "Near me:"
        case 3:
            return "Want to go:"
        default:
            return "ERROR"
        }
    }
}

//MARK: - TableView Delegate

extension HomeScreenController: UITableViewDelegate {
    
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 180
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 25
    }

    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        return 0
    }

    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell: CollectionTableViewCell = cell as? CollectionTableViewCell else {
            return
        }

        cell.setCollectionView(dataSource: self, delegate: self, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 2:
            return addHeaderViewWithButton(for: section)
        default:
            return nil
        }
    }
    
    func addHeaderViewWithButton(for section: Int) -> UIView {
        let header = UIView()
        header.frame = tableView.bounds
        
        //adding blur to background
        header.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = header.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        header.addSubview(blurEffectView)
        
        //adding label to the view
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: 200, height: 25))
        label.text = "Near me"
        label.textColor = UIColor.black
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        header.addSubview(label)
        
        //adding button to the view
        let buttonWidth = CGFloat(100)
        let DoneBut: UIButton = UIButton(frame: CGRect(x: header.frame.maxX-buttonWidth, y: 0, width: buttonWidth, height: 25))
        DoneBut.setTitle("See all", for: .normal)
        DoneBut.setTitleColor(.blue, for: .normal)
        DoneBut.setTitleColor(.lightGray, for: .selected)
        DoneBut.isSelected = !DoneBut.isSelected
        DoneBut.backgroundColor = .clear
        DoneBut.tag = section
        
        //adding target to button for execution of a segue
        DoneBut.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        header.addSubview(DoneBut)
        return header
    }
    
    //custom Header View for Sections in TableView
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        //configure title for section
        header.textLabel?.textColor = UIColor.black
        header.textLabel?.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        header.textLabel?.frame = header.bounds
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 3
    }
   
}

//MARK: - CollectionView Data Source

extension HomeScreenController: UICollectionViewDataSource {
    
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        //return numberOfCollectionItems
        guard let indexedCollectionView: IndexedCollectionView = collectionView as? IndexedCollectionView else {
            fatalError("UICollectionView must be of GLIndexedCollectionView type")
        }
        return places[indexedCollectionView.indexPath.section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: IndexedCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: IndexedCollectionViewCell.identifier, for: indexPath) as? IndexedCollectionViewCell else {
            fatalError("UICollectionViewCell must be of GLIndexedCollectionViewCell type")
        }

        guard let indexedCollectionView: IndexedCollectionView = collectionView as? IndexedCollectionView else {
            fatalError("UICollectionView must be of GLIndexedCollectionView type")
        }
        
        let cafe = places[indexedCollectionView.indexPath.section][indexPath.row]
        
        cell.configureCollectionViewCell(place: cafe)
        
        return cell
    }
    
}

//MARK: - CollectionView Delegate FlowLayout

extension HomeScreenController: UICollectionViewDelegateFlowLayout {

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: collectionTopInset, left: collectionLeftInset, bottom: collectionBottomInset, right: collectionRightInset)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let collectionItemWidth: CGFloat = 250
        //let collectionViewHeight: CGFloat = tableView.rowHeight
        let collectionViewHeight: CGFloat = 165
        //let tableViewCellHeight: CGFloat = 180
        //let collectionItemWidth: CGFloat = 250
        //let collectionViewHeight: CGFloat = tableViewCellHeight - (collectionLeftInset + collectionRightInset)
        
        return CGSize(width: collectionItemWidth, height: collectionViewHeight)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 10
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }
}

//MARK: - CollectionView Delegate

extension HomeScreenController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as? IndexedCollectionViewCell
        guard let indexedCollectionView: IndexedCollectionView = collectionView as? IndexedCollectionView else {
            fatalError("UICollectionView must be of GLIndexedCollectionView type")
        }
        presentDetailedViewController(with: places[indexedCollectionView.indexPath.section][indexPath.row], image: (selectedCell?.imageView.image)!)
    }
}

//MARK: - CLLocation Delegate

extension HomeScreenController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.sortPlacesByLocation()
        self.tableView.reloadSections(IndexSet(integer: 2), with: .fade)
    }
}
