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

    private var toGoPlaces: [SavedPlaces] = [SavedPlaces]()
    private var savedPlaces: [SavedPlaces] = [SavedPlaces]()
    private var mainData: [SavedPlaces] = [SavedPlaces]()
    private var placesNames: [String] = [String]()
    private var filterPlacesNames: [String] = [String]()
    
    var animator: TransitionAnimator?
    var selectedCell: PlaceTableViewCell?
    var selectedCellImageViewSnapshot: UIView?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterLabel: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "PlaceTableViewCell", bundle: nil), forCellReuseIdentifier: "generalTableViewCell")
        tableView.register(UINib(nibName: "EmptyTableViewCell", bundle: nil), forCellReuseIdentifier: "emptyTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.prefetchDataSource = self
        loadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ReloadData), name: NSNotification.Name(rawValue: "savedPlaceChangeValue"), object: nil)
        
        //self.loadPlacesNames()
        tableView.reloadData()
    }
    
    //reloading tableView when receiving notification from DetailedViewController
    @objc func ReloadData(notification: NSNotification) {
        DispatchQueue.main.async {
            self.loadData()
            self.tableView.reloadData()
        }
    }
    
    func presentSecondViewController(with data: SavedPlaces, image: UIImage) {
        let secondViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailedViewController") as! DetailedViewController

        //secondViewController.transitioningDelegate = self
        secondViewController.modalPresentationStyle = .popover
        secondViewController.savedPlace = data
        secondViewController.placeImage = image
        present(secondViewController, animated: true)
    }
    
    func loadData() {
        savedPlaces.removeAll()
        mainData.removeAll()
        toGoPlaces.removeAll()
        if let tempSavedPlaces = self.loadAllSavedPlaces() {
            savedPlaces = tempSavedPlaces
            mainData = tempSavedPlaces
            tempSavedPlaces.forEach { place in
                if place.wantToGo {
                    self.toGoPlaces.append(place)
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
    
    func deletePlace(id: Int16) {
        StorageManager.sharedManager.delete(id: id)
    }
    
    func changeValueWantToGo(wantToGo: Bool, place: SavedPlaces) {
        StorageManager.sharedManager.update(wantToGo: wantToGo, place: place)
    }
    
    //TODO: add buttons for 2 filters: by default "Saved Placs" and another filter "Want to go"
    @IBAction func pressSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mainData = savedPlaces
            //self.loadData()
            self.tableView.reloadData()
            break
        case 1:
            mainData = toGoPlaces
            //self.loadData()
            self.tableView.reloadData()
            break
        default:
            fatalError("cant find SelectedSegment Index")
        }
    }
    
}

//MARK: - TableView DataSource

extension SavedPlacesController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mainData.count == 0 {
        case true:
            return 1
        case false:
            return mainData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //TODO: add cell for empty View
        if mainData.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyTableViewCell", for: indexPath) as! EmptyTableViewCell
            cell.configureCell()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "generalTableViewCell", for: indexPath) as! PlaceTableViewCell
            let place = mainData[indexPath.row]
            cell.tag = indexPath.row
            
            if cell.tag == indexPath.row {
                cell.configureCellforSavedPlacesController(place: place)
            }
            return cell
        }
        
        //return cell
    }
    
    //MARK: Swipe Actions

    //TODO: add custom colors and notification on screen about success of action
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        switch filterLabel.selectedSegmentIndex {
        case 0:
            let addAction = UIContextualAction(style: .normal, title: nil, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                self.changeValueWantToGo(wantToGo: true, place: self.mainData[indexPath.row])
                if !self.toGoPlaces.contains(self.mainData[indexPath.row]) {
                    self.toGoPlaces.append(self.mainData[indexPath.row])
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toGoPlaceChangeValue"), object: nil)
                success(true)
            })
            addAction.image = UIImage(systemName: "plus.square.on.square")
            addAction.backgroundColor = .systemGreen
            
            return UISwipeActionsConfiguration(actions: [addAction])
        case 1:
            return nil
        default:
            fatalError("cant find SelectedSegment Index")
        }
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        switch filterLabel.selectedSegmentIndex {
        case 0:
            let deleteAction = UIContextualAction(style: .destructive, title: nil, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                self.deletePlace(id: self.mainData[indexPath.row].id)
                self.mainData.remove(at: indexPath.row)
                self.savedPlaces.remove(at: indexPath.row)
                if self.mainData.isEmpty {
                    self.tableView.reloadData()
                } else {
                    self.tableView.deleteRows(at: [indexPath], with: .none)
                }
                success(true)
            })
            deleteAction.image = UIImage(systemName: "trash")
            deleteAction.backgroundColor = .red
            
            return UISwipeActionsConfiguration(actions: [deleteAction])
        case 1:
            let deleteAction = UIContextualAction(style: .destructive, title: nil, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                self.changeValueWantToGo(wantToGo: false, place: self.mainData[indexPath.row])
                self.mainData.remove(at: indexPath.row)
                self.toGoPlaces.remove(at: indexPath.row)
                if self.mainData.isEmpty {
                    self.tableView.reloadData()
                } else {
                    self.tableView.deleteRows(at: [indexPath], with: .none)
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toGoPlaceChangeValue"), object: nil)
                success(true)
            })
            deleteAction.image = UIImage(systemName: "trash")
            deleteAction.backgroundColor = .red
            
            return UISwipeActionsConfiguration(actions: [deleteAction])
        default:
            fatalError("cant find SelectedSegment Index")
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

//MARK: - TableView Delegate

extension SavedPlacesController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCell = tableView.cellForRow(at: indexPath) as? PlaceTableViewCell
        //selectedCellImageViewSnapshot = selectedCell?.placeImage.snapshotView(afterScreenUpdates: false)
        presentSecondViewController(with: mainData[indexPath.row], image: (selectedCell?.placeImage.image)!)
    }
}

/*extension SavedPlacesController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let firstViewController = presenting as? SavedPlacesController,
            let secondViewController = presented as? DetailedViewController,
            let selectedCellImageViewSnapshot = selectedCellImageViewSnapshot
            else { return nil }

        animator = TransitionAnimator(type: .present, firstViewController: firstViewController, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let secondViewController = dismissed as? DetailedViewController,
            let selectedCellImageViewSnapshot = selectedCellImageViewSnapshot
            else { return nil }

        animator = TransitionAnimator(type: .dismiss, firstViewController: self, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
        return animator
    }
}*/

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
