//
//  DocumentViewController.swift
//  assign4
//
//  Created by Gabe Lavarte on 4/7/20.
//  Copyright © 2020 Gabe Lavarte. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class BikingController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var document: BikingDocument?
    var locationManager = CLLocationManager();
    var previousLocation: CLLocation?
    var initialLocation: CLLocation?
    
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var distanceTraveledLabel: UILabel!
    @IBOutlet weak var mapTypeSwitch: UISegmentedControl!
    
    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        switch mapTypeSwitch.selectedSegmentIndex {
        case 0:
            map.mapType = .standard
        case 1:
            map.mapType = .satellite
        default:
            break
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        map.delegate = self
        //locationManager.allowsBackgroundLocationUpdates = true
        
        //following starts tracking data upon opening a new BikingDocument.
        //can move this to start tracking later.
        if CLLocationManager.authorizationStatus() == .authorizedAlways ||
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            startTracking()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        map.showsUserLocation = true
        
        
    }
    
    //MAP FUNCTIONS
    func centerMap(loc: CLLocationCoordinate2D) {
        let radius:CLLocationDistance = 300
        let region = MKCoordinateRegion(center: loc, latitudinalMeters: radius, longitudinalMeters: radius)
        map.setRegion(region, animated: true)
    }
    
    //poly line render funciton
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let poly = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(overlay: poly)
            renderer.lineWidth = 3
            renderer.strokeColor = .red
            return renderer
        }
        else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Access the document
        document?.open(completionHandler: { (success) in
            if success {
                // Display the content of the document, e.g.:
                //self.documentNameLabel.text = self.document?.fileURL.lastPathComponent
                // Need to change the placeholder text based on the Biking Document
            } else {
                // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
            }
        })
    }
    
    func startTracking() {
        locationManager.startUpdatingLocation()
    }
    
    //delegate methods for location tracking.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways ||
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            startTracking()
        }
    }
    
    //upon updating locations we want to update the current look of the map on this spot. We get the initial one, but it does not continue to update the map's view.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        if let loc = initialLocation {
            //for distance label
            let totalDistInMeters = loc.distance(from: latest)
            let totalDistInMiles = totalDistInMeters * 3.28 / 5280
            
            //for speed label.
            let duration = latest.timestamp.timeIntervalSince(previousLocation!.timestamp)
            let shortDist = previousLocation?.distance(from: latest)
            let distInMiles = shortDist! * 3.28 / 5280
            let speed = distInMiles * (3600 / duration)
            
            //Update distance traveled in meters from the initial spot. then mark the current location on the map.
            distanceTraveledLabel.text = String(format: "%@ %.1f %@","Distance:" ,totalDistInMiles, "Miles")
            speedLabel.text = String(format: "%@ %.1f %@", "Speed:" ,speed, "MPH")
            let coordinate = latest.coordinate
            centerMap(loc: coordinate)
            
            //we use previous Location to draw a line between all the locations in locations array.
            let coords = [previousLocation!.coordinate] + locations.map { $0.coordinate }
            let poly = MKPolyline(coordinates: coords, count: coords.count)
            map.addOverlay(poly)
            
            
            previousLocation = latest

        } else {
            initialLocation = latest
            previousLocation = latest
            distanceTraveledLabel.text = "Distance: 0 miles"
            speedLabel.text = "Speed: 0 MPH"
            //other initial behaviors for start of ride.
        }
        
    }
    //present alert that will provide file saving option.
    @IBAction func prepareToCloseDoc(_ sender: UIButton) {
        let alert = UIAlertController(title: "Save Trip", message: "enter filename to be saved", preferredStyle: .alert)
    
        alert.addTextField { (textField) in
            let currFileName = self.document?.fileURL.lastPathComponent.replacingOccurrences(of: ".gpx436", with: "")
            textField.text = String(currFileName!)
            textField.textColor = .black
        }
        //make a save action.
        let save = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            //if textField is not empty, we save the file with that textfield's name.
            if textField.text != "" {
                if let fileName = textField.text, let doc = self.document {
                    let fileURL = doc.fileURL.deletingLastPathComponent().appendingPathComponent(fileName).appendingPathExtension("gpx436")
                    doc.save(to: fileURL, for: .forCreating)
                    self.dismissDocumentViewController()
                }
            }
        }
        
        //does nothing but close the alert.
        let cancel = UIAlertAction(title: "Cancel", style: .destructive)

        alert.addAction(save)
        alert.addAction(cancel)
        //make a cancel action.
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func dismissDocumentViewController() {
        
        dismiss(animated: true) {
            //I try to save the document's placeholder text for reopening.
            //self.document?.updateChangeCount(.done)
            //with the new name for document already set, we just need to update changes in the document.
            self.document?.updateChangeCount(.done)
            self.document?.close(completionHandler: nil)
        }
    }
}
