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

class HomeScreenController: UIViewController {
    let db = Firestore.firestore()
    let storage = Storage.storage()

    var places: [[Cafe]] = [[], []]
    var trendingList: [String] = []
    private var count = 0
    
    static let tableCellID: String = "tableViewCellID_section_#"
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    //let numberOfSections: Int = 2
    //let numberOfCollectionsForRow: Int = 1
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
        
        tableView.dataSource = self
        tableView.delegate = self
        //self.loadData()
        
        spinner.startAnimating()
        tableView.isHidden = true
        
        //self.loadTrendingPlaces()
        //self.loadPlaces()
        
        self.loadData()
    }
    
    func loadData() {
        //downloadind data for trending places
        let trendingList = db.collection("categories").document("trending")
        trendingList.getDocument { document, err in
            if let document = document, document.exists {
                let trendingPlaces = document.data()!["placesID"] as? [Any]
                for place in trendingPlaces! {
                    self.trendingList.append(place as! String)
                }
                self.db.collection("places").whereField(FieldPath.documentID(), in: self.trendingList).getDocuments { querySnapshot, err in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            let place = document.data()
                            self.places[0].append(Cafe(name: place["name"] as! String, address: place["address"] as! String, zip: place["zip"] as! String, imageLink: place["imageLink"] as! String, type: place["type"] as! [String], rating: place["rating"] as! Double, placeDescription: place["description"] as! String, openingHours: place["openingHours"] as! String))
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
        
        //downloading data for "You may like" places
        db.collection("places").limit(to: 10).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let place = document.data()
                    self.places[1].append(Cafe(name: place["name"] as! String, address: place["address"] as! String, zip: place["zip"] as! String, imageLink: place["imageLink"] as! String, type: place["type"] as! [String], rating: place["rating"] as! Double, placeDescription: place["description"] as! String, openingHours: place["openingHours"] as! String))
                }
                DispatchQueue.main.async {
               // DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    self.tableView.reloadData()
                    //self.spinner.stopAnimating()
                    //self.tableView.isHidden = false
                }
            }
        }
    }
    
    func presentSecondViewController(with data: Cafe, image: UIImage) {
        let secondViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailedViewController") as! DetailedViewController

        //secondViewController.transitioningDelegate = self

        secondViewController.modalPresentationStyle = .popover
        secondViewController.firebasePlace = data
        secondViewController.placeImage = image
        present(secondViewController, animated: true)
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

extension HomeScreenController: UITableViewDataSource {
    
    func numberOfSections(in _: UITableView) -> Int {
        return places.count
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
            return "Trending:"
        case 1:
            return "You may like:"
        case 2:
            return "Want to go:"
        case 3:
            return "Near me:"
        default:
            return "ERROR"
        }
    }
}

extension HomeScreenController: UITableViewDelegate {
    
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 180
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 25
    }

    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        return 0.0001
    }

    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell: CollectionTableViewCell = cell as? CollectionTableViewCell else {
            return
        }

        cell.setCollectionView(dataSource: self, delegate: self, indexPath: indexPath)
    }
    
    //custom Header View for Sections in TableView
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.black
        header.textLabel?.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        header.textLabel?.frame = header.bounds
    }
    
}

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
        
        cell.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.imageView.sd_imageIndicator?.startAnimatingIndicator()
        let imageRef = storage.reference(forURL: cafe.imageLink)
        imageRef.downloadURL { url, err in
            if let err = err {
                print("Failed generating url: \(err)")
            } else {
                cell.imageView.sd_imageIndicator?.stopAnimatingIndicator()
                cell.imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "Cafe_Menta_index"), options: .continueInBackground) {
                    _,_,_,_ in
                    //check if the first row finished downloading to present the table view
                    //TODO: improve
                    self.count += 1
                    if self.count == self.places.flatMap({ $0 }).count-1 {
                        self.spinner.stopAnimating()
                        self.tableView.isHidden = false
                    }
                    
                }
            }
        }
        
        //TODO: add every label
        cell.imageView.backgroundColor = .gray
        cell.titleLabel.text = cafe.name
        cell.zipLabel.text = cafe.zip
        
        /*for index in 0...1 {
            cell.tagListView.addTag(cafe.type[index])
        }
        
        if(cell.tagListView.intrinsicContentSize.height>20) {
            cell.tagListView.removeTag(cafe.type[0])
        }*/
        cell.tagListView.addTag(cafe.type[0])
        cell.ratingView.rating = cafe.rating
        
        return cell
    }
    
}

extension HomeScreenController: UICollectionViewDelegateFlowLayout {

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: collectionTopInset, left: collectionLeftInset, bottom: collectionBottomInset, right: collectionRightInset)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        //let tableViewCellHeight: CGFloat = tableView.rowHeight
        //let collectionItemWidth: CGFloat = tableViewCellHeight - (collectionLeftInset + collectionRightInset)
        //let collectionViewHeight: CGFloat = tableViewCellHeight
        let tableViewCellHeight: CGFloat = 180
        let collectionItemWidth: CGFloat = 250
        let collectionViewHeight: CGFloat = tableViewCellHeight - (collectionLeftInset + collectionRightInset)
        
        return CGSize(width: collectionItemWidth, height: collectionViewHeight)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 10
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }
}

extension HomeScreenController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as? IndexedCollectionViewCell
        guard let indexedCollectionView: IndexedCollectionView = collectionView as? IndexedCollectionView else {
            fatalError("UICollectionView must be of GLIndexedCollectionView type")
        }
        presentSecondViewController(with: places[indexedCollectionView.indexPath.section][indexPath.row], image: (selectedCell?.imageView.image)!)
    }
}
