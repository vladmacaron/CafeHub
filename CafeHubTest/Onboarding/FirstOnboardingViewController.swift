//
//  FirstOnboardingViewController.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 10.01.22.
//

import UIKit

class FirstOnboardingViewController: UIViewController {
    
    //TODO: loggin/register screen
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if let pageController = parent as? OnboardingPageViewController {
            pageController.pushNext()
        }
    }

}
