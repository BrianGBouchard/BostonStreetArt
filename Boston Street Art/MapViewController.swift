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

    var artIDlist: Array<String> = []

    let dataRef = Database.database().reference().child("Artworks")
    let ref = Storage.storage().reference(withPath: "Images")

    let blueColor = UIColor(red: 0.1294, green: 0.549, blue: 0.960, alpha: 1.0)

    // MARK: View Controller Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        let urlString = "https://boston-street-art.firebaseio.com/Artworks.json?print=pretty"
        let url = URL(string: urlString)!

        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "EuphemiaUCAS-Bold", size: 10.0)!], for: UIControl.State.normal)

        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
            return
        }
        var preferredStatusBarStyle: UIStatusBarStyle {
            return UIStatusBarStyle.lightContent
        }


        bostonMap.mapType = .mutedStandard
        createMap()

        let divider = UIView(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 1))
        divider.backgroundColor = UIColor.lightGray
        divider.alpha = 1.0
        //view.addSubview(divider)
        let divider2 = UIView(frame: CGRect(x: 0, y: statusBar.frame.height+49, width: self.view.frame.width, height: 1))
        divider2.backgroundColor = UIColor.lightGray
        divider2.alpha = 1.0
        //view.addSubview(divider2)
        let divider3 = UIView(frame: CGRect(x: 0, y: statusBar.frame.height+98, width: self.view.frame.width, height: 1))
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

        do {
            try getData()
        } catch {
            print(error.localizedDescription)
        }
    }

    func getData() throws {
        /*let urlString = "https://boston-street-art.firebaseio.com/Artworks.json?print=pretty"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)*/

        dataRef.observeSingleEvent(of: .value) { (snapshot) in
            let children = snapshot.children.allObjects as! [DataSnapshot]
            for child in children {
                let artID = child.key
                let artCoordinatesLat = child.childSnapshot(forPath: "Coordinates").childSnapshot(forPath: "Latitude").value as? Double
                let artCoordinatesLong = child.childSnapshot(forPath: "Coordinates").childSnapshot(forPath: "Longitude").value as? Double
                let artTitle = child.childSnapshot(forPath: "Title").value as? String
                let artArtist = child.childSnapshot(forPath: "Artist").value as? String
                let artLocation = child.childSnapshot(forPath: "Location").value as? String
                let artInfo = child.childSnapshot(forPath: "Info").value as? String
                let newArt = Artwork(coordinate: CLLocationCoordinate2D(latitude: artCoordinatesLat!, longitude: artCoordinatesLong!))
                newArt.address = artLocation!
                newArt.artTitle = artTitle!
                newArt.artist = artArtist!
                newArt.info = artInfo!
                newArt.numID = UInt32(artID)
                Storage.storage().reference(withPath: artID).getData(maxSize: 1000000000, completion: { (data, error) in
                    if let imageData = data {
                        newArt.image = UIImage(data: imageData)
                        newArt.thumbnail = resizeImage(image: UIImage(data: imageData)!, newWidth: 35)
                        self.bostonMap.addAnnotation(newArt)
                        self.bostonMap.reloadInputViews()
                    } else {
                        self.bostonMap.addAnnotation(newArt)
                        self.bostonMap.reloadInputViews()
                    }
                })

            }
        }

        /*let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    for item in json {
                        self.artIDlist.append(item.key)
                        if let coordinates = (item.value as! [String: Any])["Coordinates"] {
                            let latitude = (coordinates as! [String: Any])["Latitude"]
                            let longitude = (coordinates as! [String: Any])["Longitude"]
                            let art = Artwork(coordinate: CLLocationCoordinate2D(latitude: latitude as! Double, longitude: longitude as! Double))
                            art.numID = UInt32(item.key)
                            self.dataRef.child(item.key).observe(.value, with: { (snapshot) in
                                art.artTitle = snapshot.childSnapshot(forPath: "Title").value as! String
                                art.artist = snapshot.childSnapshot(forPath: "Artist").value as! String
                                art.address = snapshot.childSnapshot(forPath: "Location").value as! String
                                art.info = snapshot.childSnapshot(forPath: "Info").value as! String
                            })
                            DispatchQueue.main.async {
                                Storage.storage().reference(withPath: item.key).getData(maxSize: 100000000000, completion: { (data, error) in
                                    if let data = data {
                                        art.image = UIImage(data: data)
                                        art.thumbnail = resizeImage(image: UIImage(data: data)!, newWidth: 35)
                                        self.bostonMap.addAnnotation(art)
                                    } else {
                                        self.bostonMap.addAnnotation(art)
                                    }
                                })
                            }
                        }
                    }
                } catch { print(error.localizedDescription) }
            }
        }
        let group = DispatchGroup()
        group.enter()
        task.resume()
        group.leave()
        group.notify(queue: .main) {
            self.bostonMap.reloadInputViews()
        }
        */
    }

    // MARK: Gesture Recognizers

    @objc func handlePress(gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.location(in: bostonMap)
        let coordinate = bostonMap.convert(location, toCoordinateFrom: bostonMap)
        let alert = UIAlertController(title: nil, message: "Create marker at this location?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            let newAnnotation = Artwork(coordinate: coordinate)
            var newID = arc4random()
            //CHECK FOR DUPLICATES
            if self.artIDlist.contains(String(newID)) {
                while self.artIDlist.contains(String(newID)) {
                    newID = arc4random()
                    if self.artIDlist.contains(String(newID)) == false {
                        newAnnotation.numID = newID
                    self.dataRef.child(String(newID)).child("Coordinates").child("Latitude").setValue(Double(coordinate.latitude))
                    self.dataRef.child(String(newID)).child("Coordinates").child("Longitude").setValue(Double(coordinate.longitude))
                        self.dataRef.child(String(newID)).child("Title").setValue(newAnnotation.artTitle)
                        self.dataRef.child(String(newID)).child("Artist").setValue(newAnnotation.artist)
                        self.dataRef.child(String(newID)).child("Location").setValue(newAnnotation.address)
                        self.dataRef.child(String(newID)).child("Info").setValue(newAnnotation.info)

                        self.bostonMap.addAnnotation(newAnnotation)
                        if let newView = self.mapView(self.bostonMap, viewFor: newAnnotation) {
                            self.mapView(self.bostonMap, didSelect: newView)
                        }
                    }
                }
            } else {
                newAnnotation.numID = newID
                self.dataRef.child(String(newID)).child("Coordinates").child("Latitude").setValue(Double(coordinate.latitude))
                self.dataRef.child(String(newID)).child("Coordinates").child("Longitude").setValue(Double(coordinate.longitude))
                self.bostonMap.addAnnotation(newAnnotation)
                self.dataRef.child(String(newID)).child("Title").setValue(newAnnotation.artTitle)
                self.dataRef.child(String(newID)).child("Artist").setValue(newAnnotation.artist)
                self.dataRef.child(String(newID)).child("Location").setValue(newAnnotation.address)
                self.dataRef.child(String(newID)).child("Info").setValue(newAnnotation.info)
                if let newView = self.mapView(self.bostonMap, viewFor: newAnnotation) {
                    self.mapView(self.bostonMap, didSelect: newView)
                }
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
        newView.initialViewController = self
        if let annotationForView = view.annotation as! Artwork? {
            newView.selectedArtwork = annotationForView
        }
        view.isSelected = false
        bostonMap.deselectAnnotation(view.annotation, animated: true)
        self.present(newView, animated: true, completion: nil)
        
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView()
        annotationView.alpha = 0.0
        annotationView.annotation = annotation
        if (annotation as! Artwork).thumbnail != nil {
            annotationView.image = (annotation as! Artwork).thumbnail!
        } else {
            annotationView.image = UIImage(named: "NeedsImage")
        }
        annotationView.isEnabled = true
        annotationView.canShowCallout = false
        annotationView.layer.borderWidth = 1.0
        annotationView.layer.borderColor = UIColor.black.cgColor
        annotationView.layer.cornerRadius = 17.5
        annotationView.clipsToBounds = true
        UIView.animate(withDuration: 0.5) {
            annotationView.alpha = 1.0
        }
        return annotationView
    }
}


