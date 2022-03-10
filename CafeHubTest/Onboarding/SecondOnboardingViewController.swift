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
    var tags: [String] = [String]()
    var selectedTags: [String] = [String]()
    
    @IBOutlet weak var tagList: TagListView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tagList.textFont = UIFont.systemFont(ofSize: 20)
        tagList.delegate = self
    
        loadTags()
    }
    
    func loadTags() {
        if let pageController = parent as? OnboardingPageViewController {
            tags.append(contentsOf: pageController.tags)
        }
        self.tagList.addTags(tags)
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
