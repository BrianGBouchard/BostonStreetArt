//
//  imageviewcontroller.swift
//  Boston Street Art
//
//  Created by Brian Bouchard on 11/7/18.
//  Copyright © 2018 Brian Bouchard. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import Firebase
import FirebaseDatabase
import AVKit
import Photos


class ArtworkViewController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var addressLabl: UILabel!
    @IBOutlet var artworkInfo: UITextView!
    @IBOutlet var addImageLabel: UILabel!

    var selectedArtwork: Artwork?
    var initialViewController: MapViewController?
    let dataRef = Database.database().reference(withPath: "Artworks")

    let picker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        addImageLabel.isHidden = true
        activity.hidesWhenStopped = true
        picker.delegate = self
        activity.startAnimating()
        if let artUnwrapped = self.selectedArtwork {
            self.titleLabel.text! = artUnwrapped.artTitle
            self.artistLabel.text! = artUnwrapped.artist
            self.addressLabl.text! = artUnwrapped.address
            self.artworkInfo.text = artUnwrapped.info
            /*if let num = artUnwrapped.numID {
                let imageref = Storage.storage().reference(withPath: "\(num)")
                imageref.getData(maxSize: 100000000) { (imagedata, error) in
                    if let data = imagedata {
                        self.imageView.image = UIImage(data: data)
                        self.activity.stopAnimating()
                    } else {
                        self.addImageLabel.isHidden = false
                        self.activity.stopAnimating()
                    }
                }
            }*/
            if let pic = self.selectedArtwork!.image {
                self.imageView.image = pic
                self.activity.stopAnimating()
            } else {
                self.addImageLabel.isHidden = false
                self.activity.stopAnimating()
            }
        }

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(gesture:)))
        swipeGesture.direction = .down
        self.view.addGestureRecognizer(swipeGesture)

        let titleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTitleTapGesture(gesture:)))
        self.titleLabel.addGestureRecognizer(titleTapGesture)

        let artistTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleArtistTapGesture(gesture:)))
        self.artistLabel.addGestureRecognizer(artistTapGesture)

        let addressTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAddressTapGesture(gesture:)))
        self.addressLabl.addGestureRecognizer(addressTapGesture)

        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTapGesture(gesture:)))
        imageView.addGestureRecognizer(imageTapGesture)

        let artInfoTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleInfoTapGesture(gesture:)))
        artworkInfo.addGestureRecognizer(artInfoTapGesture)
    }

    @objc func handleSwipeGesture(gesture: UISwipeGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func handleTitleTapGesture(gesture: UITapGestureRecognizer) {
        let alert = UIAlertController(title: nil, message: "Would you like to edit the artwork title?", preferredStyle: .alert)
        let edit = UIAlertAction(title: "Edit", style: .default) { (action) in
            let editAlert = UIAlertController(title: nil, message: "Enter a title", preferredStyle: .alert)
            editAlert.addTextField(configurationHandler: { (textfield) in
                textfield.text! = self.titleLabel.text!
            })
            let editOK = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                if editAlert.textFields![0].text != nil && editAlert.textFields![0].text != "" {
                    self.dataRef.child(String(self.selectedArtwork!.numID!)).child("Title").setValue(editAlert.textFields![0].text!)
                    self.selectedArtwork?.artTitle = editAlert.textFields![0].text!
                    if let mapViewController = self.initialViewController {
                        for item in mapViewController.bostonMap.annotations {
                            if (item as! Artwork).numID == self.selectedArtwork?.numID {
                                mapViewController.bostonMap.removeAnnotation(item)
                                mapViewController.bostonMap.addAnnotation(self.selectedArtwork!)
                            }
                        }
                    }
                    self.titleLabel.text = editAlert.textFields![0].text!
                } else {
                    return
                }
            })
            let editCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            editAlert.addAction(editOK)
            editAlert.addAction(editCancel)
            self.present(editAlert, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(edit)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    @objc func handleArtistTapGesture(gesture: UITapGestureRecognizer) {
        let alert = UIAlertController(title: nil, message: "Would you like to edit the Artist info?", preferredStyle: .alert)
        let edit = UIAlertAction(title: "Edit", style: .default) { (action) in
            let editAlert = UIAlertController(title: nil, message: "Enter artist name", preferredStyle: .alert)
            editAlert.addTextField(configurationHandler: { (textfield) in
                textfield.text! = self.artistLabel.text!
            })
            let editOK = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                if editAlert.textFields![0].text != nil && editAlert.textFields![0].text != "" {
                    self.dataRef.child(String(self.selectedArtwork!.numID!)).child("Artist").setValue(editAlert.textFields![0].text!)
                    self.selectedArtwork!.artist = editAlert.textFields![0].text!
                    if let mapViewController = self.initialViewController {
                        for item in mapViewController.bostonMap.annotations {
                            if (item as! Artwork).numID == self.selectedArtwork?.numID {
                                mapViewController.bostonMap.removeAnnotation(item)
                                mapViewController.bostonMap.addAnnotation(self.selectedArtwork!)
                            }
                        }
                    }
                    
                    self.artistLabel.text = editAlert.textFields![0].text!
                } else {
                    return
                }
            })
            let editCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            editAlert.addAction(editOK)
            editAlert.addAction(editCancel)
            self.present(editAlert, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(edit)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    @objc func handleAddressTapGesture(gesture: UITapGestureRecognizer) {
        let alert = UIAlertController(title: nil, message: "Would you like to edit the Address/Location info?", preferredStyle: .alert)
        let edit = UIAlertAction(title: "Edit", style: .default) { (action) in
            let editAlert = UIAlertController(title: nil, message: "Enter address/location", preferredStyle: .alert)
            editAlert.addTextField(configurationHandler: { (textfield) in
                textfield.text! = self.addressLabl.text!
            })
            let editOK = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                if editAlert.textFields![0].text != nil && editAlert.textFields![0].text != "" {
                    self.dataRef.child(String(self.selectedArtwork!.numID!)).child("Location").setValue(editAlert.textFields![0].text!)
                    self.selectedArtwork!.address = editAlert.textFields![0].text!
                    if let mapViewController = self.initialViewController {
                        for item in mapViewController.bostonMap.annotations {
                            if (item as! Artwork).numID == self.selectedArtwork?.numID {
                                mapViewController.bostonMap.removeAnnotation(item)
                                mapViewController.bostonMap.addAnnotation(self.selectedArtwork!)
                            }
                        }
                    }
                    self.addressLabl.text = editAlert.textFields![0].text!
                } else {
                    return
                }
            })
            let editCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            editAlert.addAction(editOK)
            editAlert.addAction(editCancel)
            self.present(editAlert, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(edit)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    @objc func handleInfoTapGesture(gesture: UITapGestureRecognizer) {
        let alert = UIAlertController(title: nil, message: "Would you like to edit the additional info?", preferredStyle: .alert)
        let edit = UIAlertAction(title: "Edit", style: .default) { (action) in
            let editAlert = UIAlertController(title: nil, message: "Enter info", preferredStyle: .alert)
            editAlert.addTextField(configurationHandler: { (textfield) in
                textfield.text! = self.artworkInfo.text!
            })
            let editOK = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                if editAlert.textFields![0].text != nil && editAlert.textFields![0].text != "" {
                    self.dataRef.child(String(self.selectedArtwork!.numID!)).child("Info").setValue(editAlert.textFields![0].text!)
                    self.selectedArtwork!.info = editAlert.textFields![0].text!
                    if let mapViewController = self.initialViewController {
                        for item in mapViewController.bostonMap.annotations {
                            if (item as! Artwork).numID == self.selectedArtwork?.numID {
                                mapViewController.bostonMap.removeAnnotation(item)
                                mapViewController.bostonMap.addAnnotation(self.selectedArtwork!)
                            }
                        }
                    }
                    self.artworkInfo.text = editAlert.textFields![0].text!
                } else {
                    return
                }
            })
            let editCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            editAlert.addAction(editOK)
            editAlert.addAction(editCancel)
            self.present(editAlert, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(edit)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
            return
        }
        setNeedsStatusBarAppearanceUpdate()
    }

    func getGallaryPermission() {
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == PHAuthorizationStatus.authorized {
                    print("access granted")
                    self.openGallary()
                } else {
                    return
                }
            }
        } else {
            openGallary()
        }
    }

    func openGallary() {
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }

    func getCameraPermission() {
        if (UIImagePickerController .isSourceTypeAvailable(.camera)) {
            if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
                AVCaptureDevice.requestAccess(for: .video) { (authorization) in
                    if authorization == true {
                        self.openCamera()
                    } else {
                        return
                    }
                }
            } else {
                openCamera()
            }
        } else {
            let cameraWarning = UIAlertController(title: "Error", message: "Camera unavailable", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            cameraWarning.addAction(okAction)
            self.present(cameraWarning, animated: true, completion: nil)
        }
    }

    func openCamera() {
        picker.sourceType = .camera
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }

    func uploadToFirebase(data: Data) {
        let ref = Storage.storage().reference()
        if let selectedImageUnwrapped = self.selectedArtwork {
            if let num = selectedImageUnwrapped.numID {
                let imageRef = ref.child(String(self.selectedArtwork!.numID!))
                imageRef.putData(data)
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        if let imageData = selectedImage.pngData() {
            uploadToFirebase(data: imageData)
            self.selectedArtwork!.image = UIImage(data: imageData)
            if let mapViewController = initialViewController {
                if mapViewController.bostonMap.annotations.contains(where: { (MKAnnotation) -> Bool in
                    (MKAnnotation as! Artwork).numID == self.selectedArtwork?.numID }) {
                    for item in mapViewController.bostonMap.annotations {
                        if (item as! Artwork).numID == self.selectedArtwork?.numID {
                            mapViewController.bostonMap.removeAnnotation(item)
                            self.selectedArtwork?.thumbnail = resizeImage(image: UIImage(data: imageData)!, newWidth: 35)
                            mapViewController.bostonMap.addAnnotation(self.selectedArtwork!)
                        }
                    }
                } else {
                    self.selectedArtwork?.thumbnail = resizeImage(image: UIImage(data: imageData)!, newWidth: 35)
                    mapViewController.bostonMap.addAnnotation(self.selectedArtwork!)
                }
            }
        }
        self.addImageLabel.isHidden = true
        imageView.image = selectedImage
        dismiss(animated: true, completion: nil)
    }

    @objc func handleImageTapGesture(gesture: UITapGestureRecognizer) {
        let alert = UIAlertController(title: nil, message: "Edit image?", preferredStyle: .alert)
        let editAction = UIAlertAction(title: "Edit", style: .default) { (action) in
            let editAlert = UIAlertController(title: "Select Image", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let galleryAction = UIAlertAction(title: "Library", style: .default) { (action) in
                self.openGallary()
            }
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
                self.openCamera()
            }
            editAlert.addAction(cancelAction)
            editAlert.addAction(galleryAction)
            editAlert.addAction(cameraAction)
            self.present(editAlert, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(editAction)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    
}
