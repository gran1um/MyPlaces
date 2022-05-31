//
//  MapManager.swift
//  My Places
//
//  Created by Alexander Popov on 27.05.2022.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    private let regionInMeters = 1_000.00
    private var placeCoordinate: CLLocationCoordinate2D?
    private var directionsArray: [MKDirections] = []
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    func setupPlacemark(place: Place, mapView: MKMapView){
        
        guard let location = place.location else {return}
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { placemarks, error in
            
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else {return}
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> (), distanceLabel:UILabel!, timeLabel:UILabel!){
        
        guard let location = locationManager.location?.coordinate else {showAlert(title: "Error", message: "Currernt location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsRequest(from: location) else {showAlert(title: "Error", message: "Destination is not found")
            return}
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions, mapView: mapView)
        
        directions.calculate { response, error in
            
            if let error = error {
                self.showAlert(title: "Error", message: "Direction is not Available")
                return
            }
            
            guard let response = response else {self.showAlert(title: "Error", message: "Direction is not Available")
                return
            }
            
            for route in response.routes {
                mapView.addOverlay(route.polyline)
                
                var regionRect = route.polyline.boundingMapRect
                let wPadding = regionRect.size.width * 0.75
                let hPadding = regionRect.size.height * 0.75
                //Add padding to the region
                regionRect.size.width += wPadding
                regionRect.size.height += hPadding
                //Center the region on the line
                regionRect.origin.x -= wPadding / 2
                regionRect.origin.y -= hPadding / 2

                mapView.setRegion(MKCoordinateRegion(regionRect), animated: true)
                
                
                let distance = String(format: "%.1f", route.distance/1000)
                let timeInterval = String(format: "%.0f", route.expectedTravelTime/60)
                distanceLabel.isHidden = false
                timeLabel.isHidden = false
                distanceLabel.text = "Расстояние до места: \(distance) км."
                timeLabel.text = "Время в пути составит: \(timeInterval) мин."
            }
        }
    }
    
    
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()){
        if CLLocationManager.locationServicesEnabled(){
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        }
        else{
            DispatchQueue.main.asyncAfter(deadline: .now()+1){
                self.showAlert(title: "Location Services are Disabled", message: "To enable it go: Settings -> Privacy -> Location Services and turn On")
            }
            
        }
    }
    
    func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress"{
                DispatchQueue.main.asyncAfter(deadline: .now()+0.01){
                    self.showUserLocation(mapView: mapView)
                }
            }
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now()+1){
                self.showAlert(title: "Your Location is not Available", message: "To give permission Go to: Settings -> MyPlaces -> Location")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("new case is available")
        }
    }
    
    func showUserLocation(mapView: MKMapView){
        
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()){
        guard let location = location else {
            return
        }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else {return}
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            self.showUserLocation(mapView: mapView)
        }
        
        closure(center)
    }
    
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView){
        
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel()}
        directionsArray.removeAll()
        
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation{
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
        
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request?{
        guard let destinationCoordinate = placeCoordinate else {return nil}
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    func showAlert(title: String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
    }
    
}
