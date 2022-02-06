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

/*struct Cafe: Hashable {
    let name: String
    let address: String
    let zip: String
    let imageLink: String
    let type: [String]
    let rating: Double
    let placeDescription: String
    let openingHours: String
    var location: CLLocation? 
    
    //TODO: func for fetching rating from Google Maps?
    func getCoordinate(completionHandler: @escaping(CLLocation, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?.first {
                    let locationCL = placemark.location!
                    completionHandler(locationCL, nil)
                    return
                }
            }
        }
    }
    //TODO: function for calculating "match"
    //func calculateMatch(input??) -> Int {}
}*/


class Cafe {
    let id: Int16
    let name: String
    let address: String
    let zip: String
    let imageLink: String
    let type: [String]
    let rating: Double
    let openingHours: String
    var location: CLLocation?
    
    let defaults = UserDefaults.standard
    
    init(id: Int16, name: String, address: String, zip: String, imageLink: String, type: [String], rating: Double, openingHours: String) {
        self.id = id
        self.name = name
        self.address = address
        self.zip = zip
        self.imageLink = imageLink
        self.type = type
        self.rating = rating
        self.openingHours = openingHours
    }
    
    func getCoordinate(completionHandler: @escaping(CLLocation, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?.first {
                    let locationCL = placemark.location!
                    completionHandler(locationCL, nil)
                    return
                }
            }
        }
    }
    //TODO: function for calculating "match"
    func calculateMatch() -> Int {
        if let savedTypes = (defaults.array(forKey: "PlaceTypeList") as? [String]) {
            var count: Int = 0
            
            type.forEach { typeName in
                if savedTypes.contains(typeName) {
                    count += 1
                }
            }
            if count == 0 {
                return 0
            } else {
                return (count/type.count)*100
            }
        } else {
            return 0
        }
    }
}

