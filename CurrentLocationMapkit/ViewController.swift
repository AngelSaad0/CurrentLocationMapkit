//
//  ViewController.swift
//  CurrentLocationMapkit
//
//  Created by Engy on 11/5/24.
//
//Privacy - Location When In Use Usage Description
//Privacy - Location Always and When In Use Usage Description
import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupTapGesture()
    }

    func setupLocationManager() {
        // Setup CLLocationManager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()

        // Setup MKMapView
        mapView.showsUserLocation = true
        mapView.delegate = self
    }

    func setupTapGesture() {

        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationAtTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
    }

    @objc func addAnnotationAtTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)

        // Create and configure the annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate


        // Reverse geocode to set title and subtitle
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { placemarks, error in
            if let placemark = placemarks?.first {
                annotation.title = placemark.name ?? "Unknown Location"
                annotation.subtitle = [placemark.locality,placemark.administrativeArea,placemark.country].compactMap{$0}.joined(separator: ", ")

            } else {
                annotation.title = "Custom Location"
                annotation.subtitle = "You tapped here"
            }
            self.mapView.addAnnotation(annotation)
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    // CLLocationManagerDelegate method - called when the location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else{return}

        // Update map to show current location
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }

}
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "UserLocation")
        annotationView.markerTintColor = .green
        annotationView.titleVisibility =  .visible
        annotationView.subtitleVisibility = .visible
        annotationView.glyphImage = UIImage(systemName: "star.fill")

        return annotationView

    }

}

