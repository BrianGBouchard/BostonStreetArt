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
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var editButton: UIButton!

    var selectedArtwork: Artwork?
    var initialViewController: MapViewController?
    var favoritesViewController: FavoritesViewController?
    let dataRef = Database.database().reference(withPath: "Artworks")
    let picker = UIImagePickerController()
    var shouldUpdate = false

    override func viewDidLoad() {
        super.viewDidLoad()
        addImageLabel.isHidden = true
        activity.hidesWhenStopped = true
        picker.delegate = self
        activity.startAnimating()
        doneButton.backgroundColor = UIColor.black
        doneButton.layer.cornerRadius = 5
        doneButton.layer.shadowColor = UIColor.lightGray.cgColor
        doneButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        doneButton.layer.shadowRadius = 2
        doneButton.layer.shadowOpacity = 1
        editButton.backgroundColor = UIColor.black
        editButton.layer.cornerRadius = 5
        editButton.layer.shadowColor = UIColor.lightGray.cgColor
        editButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        editButton.layer.shadowRadius = 2
        editButton.layer.shadowOpacity = 1
        
        setLabels()

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(gesture:)))
        swipeGesture.direction = .down
        self.view.addGestureRecognizer(swipeGesture)

        /*let titleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTitleTapGesture(gesture:)))
        self.titleLabel.addGestureRecognizer(titleTapGesture)

        let artistTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleArtistTapGesture(gesture:)))
        self.artistLabel.addGestureRecognizer(artistTapGesture)

        let addressTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAddressTapGesture(gesture:)))
        self.addressLabl.addGestureRecognizer(addressTapGesture)

        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTapGesture(gesture:)))
        imageView.addGestureRecognizer(imageTapGesture)

        let artInfoTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleInfoTapGesture(gesture:)))
        artworkInfo.addGestureRecognizer(artInfoTapGesture)
        */
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if shouldUpdate == true {
            if let mapViewController = self.initialViewController {
                for item in mapViewController.bostonMap.annotations {
                    if let artItem = item as? Artwork {
                        if let artItemID = artItem.numID {
                            if artItemID == self.selectedArtwork?.numID {
                                mapViewController.bostonMap.removeAnnotation(item)
                                mapViewController.bostonMap.addAnnotation(self.selectedArtwork!)
                            }
                        }
                    }
                }
            }

            if let favoritesVC = self.favoritesViewController {
                favoritesVC.needsUpdating = true
            }

            if let tabVC = self.initialViewController?.tabBarController {
                if let viewControllers = tabVC.viewControllers {
                    if let favVC = viewControllers[1] as? FavoritesViewController {
                        favVC.needsUpdating = true
                    }
                }
            }
        }
    }

    func setLabels() {
        if let artUnwrapped = self.selectedArtwork {
            self.titleLabel.text! = artUnwrapped.artTitle
            self.artistLabel.text! = artUnwrapped.artist
            self.addressLabl.text! = artUnwrapped.address
            self.artworkInfo.text = artUnwrapped.info
            if let pic = self.selectedArtwork!.image {
                self.imageView.image = pic
                self.activity.stopAnimating()
            } else {
                self.addImageLabel.isHidden = false
                self.activity.stopAnimating()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: self)
        if let currentArt = self.selectedArtwork {
            if let editVC = segue.destination as? EditViewController {
                editVC.selectedArtwork = currentArt
                editVC.artworkViewControlelr = self
            }
        }
    }

    @objc func handleSwipeGesture(gesture: UISwipeGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }

    /*@objc func handleTitleTapGesture(gesture: UITapGestureRecognizer) {
        let alert = UIAlertController(title: nil, message: "Would you like to edit the artwork title?", preferredStyle: .alert)
        let edit = UIAlertAction(title: "Edit", style: .default) { (action) in
            let editAlert = UIAlertController(title: nil, message: "Enter a title", preferredStyle: .alert)
            editAlert.addTextField(configurationHandler: { (textfield) in
                if self.titleLabel.text == "[Add Title]" {
                    textfield.text! = ""
                } else {
                    textfield.text! = self.titleLabel.text!
                }
            })
            let editOK = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                if editAlert.textFields![0].text != nil && editAlert.textFields![0].text != "" {
                    self.dataRef.child(String(self.selectedArtwork!.numID!)).child("Title").setValue(editAlert.textFields![0].text!)
                    if let favoritesVC = self.favoritesViewController {
                        favoritesVC.needsUpdating = true
                    }
                    if let tabVC = self.initialViewController?.tabBarController {
                        if let viewControllers = tabVC.viewControllers {
                            if let favVC = viewControllers[1] as? FavoritesViewController {
                                favVC.needsUpdating = true
                            }
                        }
                    }
                    self.selectedArtwork?.artTitle = editAlert.textFields![0].text!
                    if let mapViewController = self.initialViewController {
                        for item in mapViewController.bostonMap.annotations {
                            if let artItem = item as? Artwork {
                                if let artItemID = artItem.numID {
                                    if artItemID == self.selectedArtwork?.numID {
                                        mapViewController.bostonMap.removeAnnotation(item)
                                        mapViewController.bostonMap.addAnnotation(self.selectedArtwork!)
                                    }
                                }
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
                if self.artistLabel.text == "[Add Artist]" {
                    textfield.text! = ""
                } else {
                    textfield.text! = self.artistLabel.text!
                }
            })
            let editOK = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                if editAlert.textFields![0].text != nil && editAlert.textFields![0].text != "" {
                    self.dataRef.child(String(self.selectedArtwork!.numID!)).child("Artist").setValue(editAlert.textFields![0].text!)
                    if let favoritesVC = self.favoritesViewController {
                        favoritesVC.needsUpdating = true
                    }
                    if let tabVC = self.initialViewController?.tabBarController {
                        if let viewControllers = tabVC.viewControllers {
                            if let favVC = viewControllers[1] as? FavoritesViewController {
                                favVC.needsUpdating = true
                            }
                        }
                    }
                    self.selectedArtwork!.artist = editAlert.textFields![0].text!
                    if let mapViewController = self.initialViewController {
                        for item in mapViewController.bostonMap.annotations {
                            if let artItem = item as? Artwork {
                                if let artItemID = artItem.numID {
                                    if artItemID == self.selectedArtwork?.numID {
                                        mapViewController.bostonMap.removeAnnotation(item)
                                        mapViewController.bostonMap.addAnnotation(self.selectedArtwork!)
                                    }
                                }
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
                if self.addressLabl.text == "[Add Address]" {
                    textfield.text! = ""
                } else {
                    textfield.text! = self.addressLabl.text!
                }
            })
            let editOK = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                if editAlert.textFields![0].text != nil && editAlert.textFields![0].text != "" {
                    self.dataRef.child(String(self.selectedArtwork!.numID!)).child("Location").setValue(editAlert.textFields![0].text!)
                    if let favoritesVC = self.favoritesViewController {
                        favoritesVC.needsUpdating = true
                    }
                    if let tabVC = self.initialViewController?.tabBarController {
                        if let viewControllers = tabVC.viewControllers {
                            if let favVC = viewControllers[1] as? FavoritesViewController {
                                favVC.needsUpdating = true
                            }
                        }
                    }
                    self.selectedArtwork!.address = editAlert.textFields![0].text!
                    if let mapViewController = self.initialViewController {
                        for item in mapViewController.bostonMap.annotations {
                            if let artItem = item as? Artwork {
                                if let artItemID = artItem.numID {
                                    if artItemID == self.selectedArtwork?.numID {
                                        mapViewController.bostonMap.removeAnnotation(item)
                                        mapViewController.bostonMap.addAnnotation(self.selectedArtwork!)
                                    }
                                }
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
                if self.artworkInfo.text == "[Add Information]" {
                    textfield.text! = ""
                } else {
                    textfield.text! = self.artworkInfo.text!
                }
            })
            let editOK = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                if editAlert.textFields![0].text != nil && editAlert.textFields![0].text != "" {
                    self.dataRef.child(String(self.selectedArtwork!.numID!)).child("Info").setValue(editAlert.textFields![0].text!)
                    if let favoritesVC = self.favoritesViewController {
                        favoritesVC.needsUpdating = true
                    }
                    if let tabVC = self.initialViewController?.tabBarController {
                        if let viewControllers = tabVC.viewControllers {
                            if let favVC = viewControllers[1] as? FavoritesViewController {
                                favVC.needsUpdating = true
                            }
                        }
                    }
                    self.selectedArtwork!.info = editAlert.textFields![0].text!
                    if let mapViewController = self.initialViewController {
                        for item in mapViewController.bostonMap.annotations {
                            if let artItem = item as? Artwork {
                                if let artItemID = artItem.numID {
                                    if artItemID == self.selectedArtwork?.numID {
                                        mapViewController.bostonMap.removeAnnotation(item)
                                        mapViewController.bostonMap.addAnnotation(self.selectedArtwork!)
                                    }
                                }
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
                let imageRef = ref.child(String(num))
                imageRef.putData(data)
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let favoritesVC = self.favoritesViewController {
            favoritesVC.needsUpdating = true
        }
        if let tabVC = self.initialViewController?.tabBarController {
            if let viewControllers = tabVC.viewControllers {
                if let favVC = viewControllers[1] as? FavoritesViewController {
                    favVC.needsUpdating = true
                }
            }
        }
        let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        if let imageData = selectedImage.pngData() {
            self.selectedArtwork!.image = UIImage(data: imageData)
            uploadToFirebase(data: imageData)
            if let mapViewController = initialViewController {
                if mapViewController.bostonMap.annotations.contains(where: { (MKAnnotation) -> Bool in
                    (MKAnnotation as? Artwork)!.numID == self.selectedArtwork?.numID }) {
                    for item in mapViewController.bostonMap.annotations {
                        if let artItem = item as? Artwork {
                            if let artItemID = artItem.numID {
                                if artItemID == selectedArtwork!.numID! {
                                    mapViewController.bostonMap.removeAnnotation(item)
                                    self.selectedArtwork?.thumbnail = resizeImage(image: UIImage(data: imageData)!, newWidth: 35)
                                    mapViewController.bostonMap.addAnnotation(self.selectedArtwork!)
                                }
                            }
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
                //self.openGallary()
                self.getGallaryPermission()
            }
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
                //self.openCamera()
                self.getCameraPermission()
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
    } */

    @IBAction func button(sender: Any?) {
        if let currentUser = Auth.auth().currentUser?.uid, let currentArt = self.selectedArtwork?.numID {
            let userRef = Database.database().reference(withPath: "Users").child(currentUser)
            userRef.child("Favorites").child(String(currentArt)).observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.value as? Bool == true {
                    let alert = UIAlertController(title: "Edit Favorites List", message: "Remove this artwork from your favorites?", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Remove", style: .default, handler: { (action) in
                        userRef.child("Favorites").child(String(currentArt)).removeValue()
                        if let favoritesVC = self.favoritesViewController {
                            favoritesVC.needsUpdating = true
                        }
                        if let tabVC = self.initialViewController?.tabBarController {
                            if let viewControllers = tabVC.viewControllers {
                                if let favVC = viewControllers[1] as? FavoritesViewController {
                                    favVC.needsUpdating = true
                                }
                            }
                        }
                    })
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alert.addAction(action)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true)
                } else {
                    let alert = UIAlertController(title: "Edit Favorites List", message: "Add this artwork to your favorites?", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Add", style: .default, handler: { (action) in
                        userRef.child("Favorites").child(String(currentArt)).setValue(true)
                        if let favoritesVC = self.favoritesViewController {
                            favoritesVC.needsUpdating = true
                        }
                        if let tabVC = self.initialViewController?.tabBarController {
                            if let viewControllers = tabVC.viewControllers {
                                if let favVC = viewControllers[1] as? FavoritesViewController {
                                    favVC.needsUpdating = true
                                }
                            }
                        }
                    })
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alert.addAction(action)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true)
                }
            }
        }
    }

    @IBAction func deleteButtonPressed(sender: Any?) {
        if let favoritesVC = self.favoritesViewController {
            favoritesVC.needsUpdating = true
        }
        if let tabVC = self.initialViewController?.tabBarController {
            if let viewControllers = tabVC.viewControllers {
                if let favVC = viewControllers[1] as? FavoritesViewController {
                    favVC.needsUpdating = true
                }
            }
        }
        let alert = UIAlertController(title: "Delete this artwork from the map?", message: "This change will be permanent and cannot be undone.  These changes will affect all users, so please be courteous", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (action) in
            self.dataRef.child(String(self.selectedArtwork!.numID!)).removeValue()
            Storage.storage().reference().child(String(self.selectedArtwork!.numID!)).delete(completion: nil)
            for item in self.initialViewController!.bostonMap.annotations {
                if let artworkItem = item as? Artwork {
                    if artworkItem.numID == self.selectedArtwork?.numID {
                        self.initialViewController?.bostonMap.removeAnnotation(item)
                        self.dismiss(animated: true, completion: nil)
                        Database.database().reference(withPath: "Users").observeSingleEvent(of: .value, with: { (snapshot) in
                            for user in (snapshot.children.allObjects as! [DataSnapshot]) {
                                Database.database().reference(withPath: "Users").child(user.key).child("Favorites").observeSingleEvent(of: .value, with: { (favoritesSnapshot) in
                                    for favorite in (favoritesSnapshot.children.allObjects as! [DataSnapshot]) {
                                        if favorite.key == String(self.selectedArtwork!.numID!) {
                                            Database.database().reference(withPath: "Users").child(user.key).child("Favorites").child(favorite.key).removeValue()
                                        }
                                    }
                                })
                            }
                        })
                    }
                }
            }
        }
        let cancelACtion = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelACtion)
        self.present(alert, animated: true)
    }

    @IBAction func doneButtonPressed(sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
}
