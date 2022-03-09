//
//  SearchViewController.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 08.02.22.
//

import UIKit
import TagListView
import SDWebImage
import FirebaseFirestore
import FirebaseStorage

class SearchViewController: UIViewController {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var lastDocument: QueryDocumentSnapshot?

    private var initialPlaces: [Cafe] = [Cafe]()
    private var filterPlaces: [Cafe] = [Cafe]()
    private var placesNames: [String] = [String]()
    private var filterPlacesNames: [String] = [String]()
    private var imageURLsArray: [URL] = [URL]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
}
