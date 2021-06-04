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
        
        bindRx()
        //test()
    }
    
    func bindRx() {
        let navigationPayload = viewModel.bindRx(trigger: btn.rx.tap.asObservable())
        
        navigationPayload
            .debug(": 🚘 oncoming_automobile: payload")
            .bind(to: viewModel.selectedItem)
            .disposed(by: disposeBag)
        drewMarker()
        
    }
    
    func drewMarker() {
        targetMarker? = viewModel.targetMarker
        targetMarker?.map = mapView
//        test()
    }
    
    func test() {
        
        let defaultLocation = CLLocation(latitude: 32.071813, longitude: 34.775485)
        
        let targetLocation = CLLocation(latitude: 32.069803005741484, longitude: 34.7715155846415)
        
        
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(defaultLocation.coordinate.latitude),\(defaultLocation.coordinate.longitude)&destination=\(targetLocation.coordinate.latitude),\(targetLocation.coordinate.longitude)&sensor=false&mode=driving&key=AIzaSyBq2Z7qOER7IH0dtzYyzE4NCV8BNUTuUa8")!
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] else {
                
                print("error in JSONSerialization")
                return
                
            }
            
            
            
            guard let routes = jsonResult["routes"] as? [Any] else {
                return
            }
            
            guard let route = routes[0] as? [String: Any] else {
                return
            }
            
            guard let legs = route["legs"] as? [Any] else {
                return
            }
            
            guard let leg = legs[0] as? [String: Any] else {
                return
            }
            
            guard let steps = leg["steps"] as? [Any] else {
                return
            }
            for item in steps {
                
                guard let step = item as? [String: Any] else {
                    return
                }
                
                guard let polyline = step["polyline"] as? [String: Any] else {
                    return
                }
                
                guard let polyLineString = polyline["points"] as? String else {
                    return
                }
                
                //Call this method to draw path on map
                DispatchQueue.main.async {
                    self.drawPath(from: polyLineString)
                }
                
            }
        })
        task.resume()
    }
    
    //MARK:- Draw Path line
    func drawPath(from polyStr: String){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3.0
        polyline.map = mapView // Google MapView
        
        let defaultLocation = CLLocation(latitude: 32.071813, longitude: 34.775485)
        
        let targetLocation = CLLocation(latitude: 32.069803005741484, longitude: 34.7715155846415)
        
        let cameraUpdate = GMSCameraUpdate.fit(GMSCoordinateBounds(coordinate:  CLLocationCoordinate2D(latitude: defaultLocation.coordinate.latitude, longitude: defaultLocation.coordinate.longitude), coordinate:  CLLocationCoordinate2D(latitude: targetLocation.coordinate.latitude, longitude: targetLocation.coordinate.longitude)))
        mapView.moveCamera(cameraUpdate)
        let currentZoom = mapView.camera.zoom
        mapView.animate(toZoom: currentZoom - 1.4)
    }
    
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
