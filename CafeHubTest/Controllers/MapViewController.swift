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
    let db = Firestore.firestore()

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var savedPlacesButton: UIButton!
    let locationManager = CLLocationManager()
    let sharedPlaces = PlaceManager.shared
    
    private var checkButton = true
    var allPlacesLocation: [Cafe] = [Cafe]()
    var savedPlacesLocation: [Cafe] = [Cafe]()
    
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        checkLocationServices()
        loadPlaces()
        
        //TODO: fix getting correct current location
        if let currentLocation = locationManager.location {
            mapView.centerToLocation(currentLocation)
        } else {
            mapView.centerToLocation(CLLocation(latitude: 48, longitude: 16))
        }
        
        //TODO: change "center" to the center of Vienna
        let region = MKCoordinateRegion(center: locationManager.location!.coordinate, latitudinalMeters: 25000, longitudinalMeters: 25000)
        mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
        
        //locationManager.delegate = self
    }
    
    
    @IBAction func showSavedPlaces(_ sender: UIButton) {
        if checkButton {
            savedPlacesButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.loadAllSavedPlaces()
            self.checkButton = false
        } else {
            savedPlacesButton.setImage(UIImage(systemName: "heart"), for: .normal)
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.loadPlaces()
            self.checkButton = true
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
            //locationManager.startUpdatingLocation()
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
    
    func fetchAddressesOnMap(_ places: [Cafe]) {
        for place in places {
            self.getCoordinate(addressString: place.address) { coordinates, err in
                print(place.id)
                print(coordinates)
                let annotation = CustomAnnotation(id: place.id, title: place.name, subtitle: place.openingHours, coordinate: coordinates)
                self.mapView.addAnnotation(annotation)
            }
            //geocodeAddressString has a limit of calls to its API
            //therefore adding necessary time delay in a loop
            sleep(1)
        }
    }
    
    func getCoordinate( addressString : String, completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    
                    completionHandler(location.coordinate, nil)
                    return
                } else {
                    print("ERROR")
                }
                
            }
            
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    func loadPlaces() {
        self.fetchAddressesOnMap(self.sharedPlaces.places)
        
    }
    
    func loadAllSavedPlaces() {
        if let places = StorageManager.sharedManager.fetchAllSavedPlacesAsCafe() {
            savedPlacesLocation = places
            self.fetchAddressesOnMap(self.savedPlacesLocation)
        }
    }
    
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        if let annotation = annotation as? CustomAnnotation {
            let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "PlaceMarker")
            view.tag = Int(annotation.id)
            view.canShowCallout = true
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            view.markerTintColor = UIColor(named: "AccentColor")
            let placeType = sharedPlaces.places.first(where: {$0.id == annotation.id})?.type[0]
            switch placeType {
            case "Bars":
                view.glyphImage = UIImage(named: "Bar")
                break
            case "Restaurants":
                view.glyphImage = UIImage(named: "Restaurant")
                break
            case "Cafés":
                view.glyphImage = UIImage(named: "Cafe")
                break
            default:
                view.glyphImage = UIImage(named: "Restaurant")
            }
            
            return view
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        presentDetailedViewController(with: view.tag)
    }
    
    func presentDetailedViewController(with id: Int) {
        let secondViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailedViewController") as! DetailedViewController
        secondViewController.modalPresentationStyle = .popover
        secondViewController.firebasePlace = sharedPlaces.places.first(where: { place in
            place.id == id
        })
        self.present(secondViewController, animated: true)
    }
}

private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1500) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
