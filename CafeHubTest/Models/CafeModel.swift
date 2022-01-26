//
//  CafeModel.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 07.11.21.
//

import Foundation
import UIKit
import FirebaseStorage
import CoreLocation

struct Cafe: Hashable {
    let name: String
    let address: String
    let zip: String
    let imageLink: String
    let type: [String]
    let rating: Double
    let placeDescription: String
    let openingHours: String
    var location: CLLocation? = nil
    
    //TODO: func for fetching rating from Google Maps?
    
    //TODO: function for calculating "match"
    //func calculateMatch(input??) -> Int {}
}

