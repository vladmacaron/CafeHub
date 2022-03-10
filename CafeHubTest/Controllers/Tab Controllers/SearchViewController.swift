//
//  SearchViewController.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 08.02.22.
//

import UIKit
import TagListView
import SDWebImage

class SearchViewController: UIViewController {
    let sharedPlaces = PlaceManager.shared

    private var initialPlaces: [Cafe] = [Cafe]()
    private var filterPlaces: [Cafe] = [Cafe]()
    private var placesNames: [String] = [String]()
    private var filterPlacesNames: [String] = [String]()
    private var imageURLsArray: [URL] = [URL]()
    
    var selectedCell: PlaceTableViewCell?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "PlaceTableViewCell", bundle: nil), forCellReuseIdentifier: "generalTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        loadData()
        loadNames()
        
        tableView.reloadData()
    }
    
    func loadData() {
        filterPlaces.append(contentsOf: sharedPlaces.places)
        filterPlaces.sort { c1, c2 in
            c1.name<c2.name
        }
    }
    
    func loadNames() {
        filterPlaces.forEach { place in
            placesNames.append(place.name)
        }
    }
    
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "generalTableViewCell", for: indexPath) as! PlaceTableViewCell
        //let place = places[indexPath.row]
        let place = filterPlaces[indexPath.row]
        
        cell.tag = indexPath.row
        
        if cell.tag == indexPath.row {
            cell.configureCellForSearchViewController(place: place)
        }
        
        
        return cell
    }
    
}


extension SearchViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCell = tableView.cellForRow(at: indexPath) as? PlaceTableViewCell
        presentSecondViewController(with: filterPlaces[indexPath.row], image: (selectedCell?.placeImage.image)!)
    }
    
    func presentSecondViewController(with data: Cafe, image: UIImage) {
        let secondViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailedViewController") as! DetailedViewController

        //secondViewController.transitioningDelegate = self
        secondViewController.sheetPresentationController?.detents = [.medium(), .large()]
        secondViewController.modalPresentationStyle = .popover
        secondViewController.firebasePlace = data
        secondViewController.placeImage = image
        present(secondViewController, animated: true)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty) {
            filterPlacesNames = placesNames
            loadData()
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
}
