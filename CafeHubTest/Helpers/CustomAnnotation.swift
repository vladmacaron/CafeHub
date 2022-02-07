//
//  CustomAnnotation.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 07.02.22.
//

import Foundation
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    var id: Int16!
    
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let subtitle: String?
    
    init(
        id: Int16,
        title: String?,
        subtitle: String?,
        coordinate: CLLocationCoordinate2D
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
        super.init()
    }

}
