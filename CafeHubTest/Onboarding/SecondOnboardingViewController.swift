//
//  SecondOnboardingViewController.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 10.01.22.
//

import UIKit
import TagListView
import FirebaseFirestore

class SecondOnboardingViewController: UIViewController {

    let db = Firestore.firestore()
    let defaults = UserDefaults.standard
    private var tags: [String] = [String]()
    var selectedTags: [String] = [String]()
    
    @IBOutlet weak var tagList: TagListView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tagList.textFont = UIFont.systemFont(ofSize: 20)
        tagList.delegate = self
    
        loadTags()
        
    }
    
    func loadTags() {
        db.collection("places").order(by: "name").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let place = document.data()
                    self.tags.append(contentsOf: place["type"] as! [String])
                }
                DispatchQueue.main.async {
                    self.tagList.addTags(Array(Set(self.tags)))
                }
            }
        }
    }
    
}

extension SecondOnboardingViewController: TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        tagView.isSelected = !tagView.isSelected
        guard let tagName = tagView.titleLabel?.text else {
            return
        }
        if tagView.isSelected {
            selectedTags.append(tagName)
            defaults.set(selectedTags, forKey: "PlaceTypeList")
        } else {
            selectedTags.removeAll { s in
                s == tagName
            }
            defaults.set(selectedTags, forKey: "PlaceTypeList")
        }
    }
}
