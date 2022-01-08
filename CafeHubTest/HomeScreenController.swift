//
//  HomeScreenController.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 07.11.21.
//

import UIKit

class HomeScreenController: UIViewController {

    let cafes: [[Cafe]] = [[Cafe(name: "Name1", address: "address street one city name", zip: "1010", image: "Cafe_Menta_index", type: "Asian", rating: 4.1),
                            Cafe(name: "Name2", address: "address street one city name", zip: "1010", image: "Cafe_Menta_index", type: "Asian", rating: 3.5),
                            Cafe(name: "Name3", address: "address street one city name", zip: "1010", image: "Cafe_Menta_index", type: "Asian", rating: 4.1),
                            Cafe(name: "Name4", address: "address street one city name", zip: "1010", image: "Cafe_Menta_index", type: "Russian", rating: 4.1),
                            Cafe(name: "Name5", address: "address street one city name", zip: "1010", image: "Cafe_Menta_index", type: "Asian", rating: 4.1),
                            Cafe(name: "Name6", address: "address street one city name", zip: "1010", image: "Cafe_Menta_index", type: "Asian", rating: 4.1)],
                           [Cafe(name: "differentName1", address: "address street one city name", zip: "1010", image: "Cafe_Menta_index", type: "Asian", rating: 4.1),
                            Cafe(name: "differentName2", address: "address street one city name", zip: "1010", image: "Cafe_Menta_index", type: "Asian", rating: 4.1),
                            Cafe(name: "differentName3", address: "address street one city name", zip: "1010", image: "Cafe_Menta_index", type: "Asian", rating: 4.1)]]
    
    static let tableCellID: String = "tableViewCellID_section_#"
    @IBOutlet weak var tableView: UITableView!
    
    let numberOfSections: Int = 2
    //let numberOfCollectionsForRow: Int = 1
    let numberOfCollectionItems: Int = 20
    
    /// Set true to enable UICollectionViews scroll pagination
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
        return numberOfSections
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
            return "Recently Visited:"
        case 2:
            return "Saved Places:"
        default:
            return "Default Section (FIX)"
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
        //header.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        //header.textLabel?.font = UIFont.systemFont(ofSize: 18)
        header.textLabel?.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        header.textLabel?.frame = header.bounds
        //header.textLabel?.textAlignment = .center
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
        return cafes[indexedCollectionView.indexPath.section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: IndexedCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: IndexedCollectionViewCell.identifier, for: indexPath) as? IndexedCollectionViewCell else {
            fatalError("UICollectionViewCell must be of GLIndexedCollectionViewCell type")
        }

        guard let indexedCollectionView: IndexedCollectionView = collectionView as? IndexedCollectionView else {
            fatalError("UICollectionView must be of GLIndexedCollectionView type")
        }
        
        let cafe = cafes[indexedCollectionView.indexPath.section][indexPath.row]
        
        //TODO: add every label
        cell.imageView.backgroundColor = .yellow
        cell.titleLabel.text = cafe.name
        cell.zipLabel.text = cafe.zip
        cell.typeLabel.text = cafe.type
        cell.imageView.image = UIImage(named: cafe.image)
        
        //TODO: find correct color for titles dependant in the image
        cell.titleLabel.textColor = .tertiarySystemBackground
        
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
    
    func collectionView(_: UICollectionView, didSelectItemAt _: IndexPath) {
    }
    
}
