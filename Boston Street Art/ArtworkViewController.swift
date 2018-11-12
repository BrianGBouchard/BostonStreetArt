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

    let picker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        activity.hidesWhenStopped = true
        picker.delegate = self
        let imageref = Storage.storage().reference(withPath: "image1")
        imageref.getData(maxSize: 100000000) { (imagedata, error) in
            self.activity.startAnimating()
            if let data = imagedata {
                self.imageView.image = UIImage(data: data)
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
        statusBar.backgroundColor = nil
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
        let imageRef = ref.child("image1")
        imageRef.putData(data)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        if let imageData = selectedImage.pngData() {
            uploadToFirebase(data: imageData)
        }
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
