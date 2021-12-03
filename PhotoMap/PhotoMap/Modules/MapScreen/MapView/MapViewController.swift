//
//  MapViewController.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/2/21.
//

import UIKit
import CoreLocation
import MapKit

protocol MapViewInput: AnyObject {
    
}

class MapViewController: UIViewController {
    
    var viewModel: MapViewModelProtocol!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        print(mapView.userLocation.location?.coordinate.latitude)
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
    }
}

extension MapViewController: MapViewInput {
    
}
