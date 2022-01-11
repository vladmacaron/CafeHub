//
//  LandscapeManager.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 10.01.22.
//

import Foundation

class LandscapeManager {
    static let shared = LandscapeManager()
    
    var isFirstLaunch: Bool {
        get {
            !UserDefaults.standard.bool(forKey: #function)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: #function)
        }
    }
}
