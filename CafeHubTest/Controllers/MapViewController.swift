//
//  MapViewController.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 25.01.22.
//

import UIKit
import MapKit
import FirebaseFirestore

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let db = Firestore.firestore()
    var allPlacesLocation: [String: String] = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLocationServices()
        //TODO: fix getting correct current location
        if let currentLocation = locationManager.location {
            mapView.centerToLocation(currentLocation)
        } else {
            mapView.centerToLocation(CLLocation(latitude: 48, longitude: 16))
        }
        
        loadPlacesNames()
        
        let region = MKCoordinateRegion(
            center: locationManager.location!.coordinate,
            latitudinalMeters: 25000,
            longitudinalMeters: 25000)
        mapView.setCameraBoundary(
            MKMapView.CameraBoundary(coordinateRegion: region),
            animated: true)
        
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
        
        
        locationManager.delegate = self
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            mapView.showsUserLocation = true
        case .restricted, .denied: // Show an alert letting them know what’s up
            break
        case .authorizedAlways:
            break
        @unknown default:
            fatalError("location access error")
        }
    }
    
    func fetchAddressesOnMap(_ addresses: [String: String]) {
        for (name, address) in addresses {
            let annotations = MKPointAnnotation()
            annotations.title = name
            self.getCoordinate(addressString: address) { coordinates, err in
                annotations.coordinate = coordinates
            }
            //annotations.coordinate = CLLocationCoordinate2D(latitude:
            //                                                    stadium.lattitude, longitude: stadium.longtitude)
            mapView.addAnnotation(annotations)
        }
    }
    
    func getCoordinate( addressString : String,
            completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                        
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
                
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    func loadPlacesNames() {
        db.collection("places").order(by: "name").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let place = document.data()
                    self.allPlacesLocation[place["name"] as! String] = (place["address"] as! String)
                    //print(self.allPlacesLocation[place["name"] as! String])
                }
                DispatchQueue.main.async {
                    self.fetchAddressesOnMap(self.allPlacesLocation)
                }
            }
        }
    }

}

extension MapViewController: CLLocationManagerDelegate {
    
}

private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 1000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}
