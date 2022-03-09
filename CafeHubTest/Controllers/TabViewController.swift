//
//  TabViewController.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 20.01.22.
//

import UIKit

class TabViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //loadData()
        
        self.delegate = self
    }
}

extension TabViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
}
