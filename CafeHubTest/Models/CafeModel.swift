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
    //let description: String
    //let openingHours: String
    lazy var imageURL: URL? = {
        var resURL: URL?
        let imageRef = Storage.storage().reference(forURL: imageLink)
        imageRef.downloadURL { url, err in
            if let err = err {
                print("Failed generating url: \(err)")
            } else {
                resURL = url
            }
        }
        return resURL
    }()
    
    //TODO: func for fetching rating from Google Maps?
    func getRating() -> Int {
        return name.hashValue
    }
    
    //TODO: function for calculating "match"
    //func calculateMatch(input??) -> Int {}
}
