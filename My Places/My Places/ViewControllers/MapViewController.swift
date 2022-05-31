//
//  MapViewController.swift
//  My Places
//
//  Created by Alexander Popov on 26.05.2022.
//

import UIKit
import MapKit
import CoreLocation

@objc protocol MapViewControllerDelegate{
    @objc optional func getAddress( _ address: String?)
}

class MapViewController: UIViewController {
    
    let mapManager = MapManager()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    var incomeSegueIdentifier = ""
    let annotationIdentifier = "annotationIdentifier"
    
    var previousLocation: CLLocation? {
        didSet{
            mapManager.startTrackingUserLocation(for: mapView, and: previousLocation) { currentLocation in
                self.previousLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now()+3){
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
        }
    }
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = ""
        mapView.delegate = self
        setupMapView()

    }
    
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress?(addressLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func goButtonPressed() {
        mapManager.getDirections(for: mapView, previousLocation: {(location) in self.previousLocation = location}, distanceLabel: distanceLabel,timeLabel: timeLabel)
    }
    
    @IBAction func findMe() {
        mapManager.showUserLocation(mapView: mapView)
    }
     
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    private func setupMapView(){
        
        goButton.isHidden = true
        self.distanceLabel.isHidden = true
        self.timeLabel.isHidden = true
        
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifier){
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueIdentifier == "showMap"{
            mapManager.setupPlacemark(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }
}

extension MapViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else {return nil}
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData{
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data:imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomeSegueIdentifier == "showMap" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: mapView)
            }
        }
        
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(center) { placemarks, error in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else {return}
            
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil{
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil{
                    self.addressLabel.text = "\(streetName!)"
                }
                else {
                    self.addressLabel.text = ""
                }
            }
            
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .systemBlue
        
        return render
    }
}


extension MapViewController: CLLocationManagerDelegate{
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        mapManager.checkLocationAuthorization(mapView: mapView, segueIdentifier: incomeSegueIdentifier)
    }
}
