//
//  CafeModel.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 07.11.21.
//

import Foundation
import UIKit
import FirebaseStorage

struct Cafe: Codable {
    let name: String
    let address: String
    let zip: String
    let imageLink: String
    let type: [String]
    let rating: Double
    let placeDescription: String
    let openingHours: String
    
    //TODO: func for fetching rating from Google Maps?
    func getRating() -> Int {
        return name.hashValue
    }
    
    //TODO: function for calculating "match"
    //func calculateMatch(input??) -> Int {}
}
