//
//  ViewController.swift
//  Boston Street Art
//
//  Created by Brian Bouchard on 11/7/18.
//  Copyright © 2018 Brian Bouchard. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import AVKit
import Photos
import MapKit

class MapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate {

    // MARK: Properties
    
    @IBOutlet var satelliteTab: UILabel!
    @IBOutlet var mapTab: UILabel!
    @IBOutlet var bostonMap: MKMapView!

    var annotationList: Array<Artwork> = []

    let dataRef = Database.database().reference().child("Artworks")
    let ref = Storage.storage().reference(withPath: "Images")

    let blueColor = UIColor(red: 0.1294, green: 0.549, blue: 0.960, alpha: 1.0)

    // MARK: View Controller Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "EuphemiaUCAS-Bold", size: 10.0)!], for: UIControl.State.normal)

        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
            return
        }
        var preferredStatusBarStyle: UIStatusBarStyle {
            return UIStatusBarStyle.lightContent
        }
        statusBar.backgroundColor = UIColor.black
        setNeedsStatusBarAppearanceUpdate()


        bostonMap.mapType = .mutedStandard
        createMap()

        let divider = UIView(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 1))
        divider.backgroundColor = UIColor.lightGray
        divider.alpha = 1.0
        //view.addSubview(divider)
        let divider2 = UIView(frame: CGRect(x: 0, y: 69, width: self.view.frame.width, height: 1))
        divider2.backgroundColor = UIColor.lightGray
        divider2.alpha = 1.0
        view.addSubview(divider2)
        let divider3 = UIView(frame: CGRect(x: 0, y: 118, width: self.view.frame.width, height: 1))
        divider3.backgroundColor = UIColor.lightGray
        divider3.alpha = 1.0
        view.addSubview(divider3)
        let divider4 = UIView(frame: CGRect(x: 0, y: self.view.frame.height-50, width: self.view.frame.width, height: 1))
        divider4.backgroundColor = UIColor.lightGray
        divider4.alpha = 1.0
        view.addSubview(divider4)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.handlePress(gestureRecognizer:)))
        longPress.delegate = self
        bostonMap.addGestureRecognizer(longPress)

        let satellitePress = UITapGestureRecognizer(target: self, action: #selector(handleSatellitePress(gestureRecognizer:)))
        satellitePress.delegate = self
        satelliteTab.addGestureRecognizer(satellitePress)
        let mapPress = UITapGestureRecognizer(target: self, action:#selector(handleMapPress(gestureRecognizer:)))
        mapPress.delegate = self
        mapTab.addGestureRecognizer(mapPress)

        let modicaWay = Artwork(coordinate: CLLocationCoordinate2D(latitude: 42.3650, longitude: -71.10))
        bostonMap.addAnnotation(modicaWay)

        for item in annotationList {
            bostonMap.addAnnotation(item)
        }

    }

    // MARK: Gesture Recognizers

    @objc func handlePress(gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.location(in: bostonMap)
        let coordinate = bostonMap.convert(location, toCoordinateFrom: bostonMap)
        let alert = UIAlertController(title: nil, message: "Create marker at this location?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            let newAnnotation = Artwork(coordinate: coordinate)
            
            self.bostonMap.addAnnotation(newAnnotation)
            self.annotationList.append(newAnnotation)
            if let newView = self.mapView(self.bostonMap, viewFor: newAnnotation) {
                self.mapView(self.bostonMap, didSelect: newView)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    @objc func handleSatellitePress(gestureRecognizer: UITapGestureRecognizer) {
        satelliteTab.textColor = self.blueColor
        mapTab.textColor = UIColor.white
        bostonMap.mapType = .satellite
    }

    @objc func handleMapPress(gestureRecognizer: UITapGestureRecognizer) {
        satelliteTab.textColor = UIColor.white
        mapTab.textColor = self.blueColor
        bostonMap.mapType = .standard
    }

    // MARK: Map Methods

    func createMap() {
        let center = CLLocationCoordinate2D(latitude: 42.355527, longitude: -71.093976)
        let span = MKCoordinateSpan(latitudeDelta: 0.13, longitudeDelta: 0.13)
        let region = MKCoordinateRegion(center: center, span: span)
        bostonMap.setRegion(region, animated: true)
    }

    @objc func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let newView = storyboard?.instantiateViewController(withIdentifier: "artwork") as! ArtworkViewController
        view.isSelected = false
        bostonMap.deselectAnnotation(view.annotation, animated: true)
        self.present(newView, animated: true, completion: nil)
        
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView()
        annotationView.annotation = annotation
        let icon = #imageLiteral(resourceName: "MapLogo")
        annotationView.image = icon
        annotationView.isEnabled = true
        annotationView.canShowCallout = false
        return annotationView
    }
}


