//
//  ViewController.swift
//  GettMobileDelivery
//
//  Created by Gett on 5/5/21.
//

import UIKit
import RxSwift
import RxCocoa
import GoogleMaps

class MainViewController: UIViewController {
    
    @IBOutlet weak var btn: UIButton!
    var viewModel: MainViewModelType!
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var map: UIView!
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var preciseLocationZoomLevel: Float = 15.0
    var approximateLocationZoomLevel: Float = 10.0
    
    var targetMarker: GMSMarker?
    var path: GMSPath!
    var polyline: GMSPolyline!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = viewModel.locationManager
        locationManager.delegate = self
        
        let defaultLocation = CLLocation(latitude: 32.071813, longitude: 34.775485)
        
        let targetLocation = CLLocation(latitude: 32.069803005741484, longitude: 34.7715155846415)
        
        
        // Create a map.
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: map.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        targetMarker = GMSMarker()
                
        self.map.addSubview(mapView)
        
      //  bindRx()
        //test()
    }
    
    func bindRx() {
        btn.backgroundColor = .gray
        let myLocation = locationManager.location
        
        let navigationPayload = viewModel.bindRx(defaultLocation: myLocation!)(btn.rx.tap.asObservable())
        
        btn.rx.tap.subscribe(onNext: {
            
            
        })
        
        navigationPayload
            .payload
            .subscribe(onNext:{ item in
                self.statusLbl.text = item.type.rawValue
                self.addressLbl.text = item.geo.address
            })
            .disposed(by: disposeBag)
        
        navigationPayload
            .payload
            .bind(to: viewModel.selectedItem)
            .disposed(by: disposeBag)
        
        navigationPayload
            .routes
            .subscribe(onNext: { route in
                self.mapView.clear()
                for step in route.routes[0].legs[0].steps {
                    self.drawPath(from: step.polyline.points)
                }
            })
            .disposed(by: disposeBag)

        
    }
    
    func drewMarker() {
        targetMarker? = viewModel.targetMarker
        targetMarker?.map = mapView
    }
    
    func drawPath(from polyStr: String) {
        path = GMSPath(fromEncodedPath: polyStr)!
        polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3.0
        polyline.map = mapView // Google MapView
        
//        let defaultLocation = CLLocation(latitude: 32.071813, longitude: 34.775485)
//
//        let targetLocation = CLLocation(latitude: 32.069803005741484, longitude: 34.7715155846415)
        
//        let cameraUpdate = GMSCameraUpdate.fit(GMSCoordinateBounds(coordinate:  CLLocationCoordinate2D(latitude: defaultLocation.coordinate.latitude, longitude: defaultLocation.coordinate.longitude), coordinate:  CLLocationCoordinate2D(latitude: targetLocation.coordinate.latitude, longitude: targetLocation.coordinate.longitude)))
//        mapView.moveCamera(cameraUpdate)
        let currentZoom = mapView.camera.zoom
        mapView.animate(toZoom: currentZoom)
        drewMarker()
    }

    
    //MARK:- Draw Path line

    
}
// Delegates to handle events for the location manager.
extension MainViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let camera = GMSCameraPosition.camera(withLatitude: 32.026037,
                                              longitude: 34.801008,
                                              zoom: zoomLevel)
        mapView.camera = camera
        
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Check accuracy authorization
        let accuracy = manager.accuracyAuthorization
        switch accuracy {
        case .fullAccuracy:
            print("Location accuracy is precise.")
        case .reducedAccuracy:
            print("Location accuracy is not precise.")
        @unknown default:
            fatalError()
        }
        
        // Handle authorization status
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            bindRx()
            print("Location status is OK.")
        @unknown default:
            fatalError()
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
