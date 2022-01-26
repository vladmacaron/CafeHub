//
//  PlaceManager.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 26.01.22.
//

import Foundation

class PlaceManager {
    static let shared = PlaceManager()
    
    var places: [Cafe] = []
    
    private init(){}
}
