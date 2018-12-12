import Foundation
import Firebase
import MapKit
import AVKit
import Photos

class EditViewController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Properties

    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var artistTextField: UITextField!
    @IBOutlet var locationTextField: UITextField!
    @IBOutlet var infoTextView: UITextView!
    @IBOutlet var noImageLabel: UILabel!
    @IBOutlet var artImage: UIImageView!
    @IBOutlet var changesSavedIndicator: UIView!
    @IBOutlet var doneButton: UIButton!

    var selectedArtwork: Artwork?
    var fullSizeImage: UIImage?
    var artworkViewControlelr: ArtworkViewController?
    var initialViewController: MapViewController?
    var favoritesViewController: FavoritesViewController?
    var shouldShowWarning = false
    let picker = UIImagePickerController()
    let dataRef = Database.database().reference(withPath: "Artworks")

    // MARK: View Controller Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        infoTextView.layer.cornerRadius = 5
        infoTextView.clipsToBounds = true
        if let currentArt = self.selectedArtwork {
            if currentArt.artTitle != "" && currentArt.artTitle != "[Add Title]" {
                titleTextField.text = currentArt.artTitle
            }

            if currentArt.artist != "" && currentArt.artist != "[Add Artist]" {
                artistTextField.text = currentArt.artist
            }

            if currentArt.address != "" && currentArt.address != "[Add Address]" {
                locationTextField.text = currentArt.address
            }

            if currentArt.info != "" && currentArt.info != "[Add Information]" {
                infoTextView.text = currentArt.info
            } else {
                infoTextView.text = "Add Additional Information"
                infoTextView.textColor = UIColor.lightGray
            }

            if let image = currentArt.image {
                artImage.image = image
                noImageLabel.isHidden = true
            }
        }

        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTapGesture(gesture:)))
        artImage.addGestureRecognizer(imageTapGesture)
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeGesture.direction = .down
        let exitEditingTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesutre))
        self.view.addGestureRecognizer(exitEditingTapRecognizer)
        self.view.addGestureRecognizer(swipeGesture)
        picker.delegate = self
    }

    // MARK: Gesture Recognizer Methods

    @objc func handleTapGesutre() {
        if titleTextField.isFirstResponder {
            titleTextField.resignFirstResponder()
        } else if artistTextField.isFirstResponder {
            artistTextField.resignFirstResponder()
        } else if locationTextField.isFirstResponder {
            locationTextField.resignFirstResponder()
        } else if infoTextView.isFirstResponder {
            infoTextView.resignFirstResponder()
        }
    }

    @objc func handleSwipe() {
        if infoTextView.isFirstResponder {
            infoTextView.resignFirstResponder()
        } else if titleTextField.isFirstResponder {
            titleTextField.resignFirstResponder()
        } else if artistTextField.isFirstResponder {
            artistTextField.resignFirstResponder()
        } else if locationTextField.isFirstResponder {
            locationTextField.resignFirstResponder()
        } else {
            perform(#selector(doneButtonPressed(sender:)), with: doneButton)
        }
    }

    // MARK: Saving Changes

    @IBAction func saveButtonPressed(sender: Any?) {
        shouldShowWarning = false
        if let artworkVC = artworkViewControlelr {
            artworkVC.shouldUpdate = true
        }
        if let currentArt = self.selectedArtwork {
            let currentRef = dataRef.child(String(currentArt.numID!))
            if let titleText = titleTextField.text {
                if titleText != "" {
                    currentArt.artTitle = titleText
                    currentRef.child("Title").setValue(titleText)
                }
            }

            if let artistText = artistTextField.text {
                if artistText != "" {
                    currentArt.artist = artistText
                    currentRef.child("Artist").setValue(artistText)
                }
            }

            if let locationText = locationTextField.text {
                if locationText != "" {
                    currentArt.address = locationText
                    currentRef.child("Location").setValue(locationText)
                }
            }

            if infoTextView.text != "Add Additional Information" {
                currentArt.info = infoTextView.text
                currentRef.child("Info").setValue(infoTextView.text!)
            }

            if let pic = self.fullSizeImage {
                currentArt.image = pic
                currentArt.thumbnail = resizeImage(image: pic, newWidth: 35)
                if let imageData = pic.pngData() {
                    self.uploadToFirebase(data: imageData)
                }
            }

            perform(#selector(handleTapGesutre))
            artworkViewControlelr?.selectedArtwork = currentArt
            artworkViewControlelr?.setLabels()
        }

        UIView.animate(withDuration: 0.3) {
            self.changesSavedIndicator.alpha = 1.0
            self.perform(#selector(self.changesSavedFadesOut), with: nil, afterDelay: 0.9)
        }
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

    // MARK: Actions

    @objc func changesSavedFadesOut() {
        UIView.animate(withDuration: 0.3) {
            self.changesSavedIndicator.alpha = 0.0
        }
    }

    @IBAction @objc func doneButtonPressed(sender: Any?) {
        if shouldShowWarning == true {
            let alert = UIAlertController(title: "Cancel without saving?", message: "Any changes will be lost.  Click Save to commit changes", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Leave", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Keep Editing", style: .default, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: Report an Entry

    @IBAction func reportButtonPressed(sender: Any?) {
        let reportRef = Database.database().reference(withPath: "Reports")
        let reportAlert = UIAlertController(title: "Report this entry", message: "Would you like to reprt this entry for review?", preferredStyle: .alert)
        let cancelAct = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let reportAction = UIAlertAction(title: "Report", style: .default) { (action) in
            let menuAlert = UIAlertController(title: "What would you like to report?", message: nil, preferredStyle: .alert)
            let noArtAction = UIAlertAction(title: "No art at location", style: .default, handler: { (action) in
                if let currentArt = self.selectedArtwork {
                    if let artID = currentArt.numID {
                        reportRef.child(String(artID)).setValue("No art at location")
                    }
                }
                let successAlert = UIAlertController(title: "Thank You", message: "Your resposne has been submitted and will be reviewed shortly", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                successAlert.addAction(okAction)
                self.present(successAlert, animated: true)
            })
            let contentAction = UIAlertAction(title: "Inappropriate content", style: .default, handler: { (action) in
                if let currentArt = self.selectedArtwork {
                    if let artID = currentArt.numID {
                        reportRef.child(String(artID)).setValue("Inappropriate Content")
                    }
                }
                let successAlert = UIAlertController(title: "Thank You", message: "Your resposne has been submitted and will be reviewed shortly", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                successAlert.addAction(okAction)
                self.present(successAlert, animated: true)
            })
            let otherAction = UIAlertAction(title: "Other", style: .default, handler: { (action) in
                let otherAlert = UIAlertController(title: "Type your report here", message: nil, preferredStyle: .alert)
                otherAlert.addTextField(configurationHandler: nil)
                let sendAction = UIAlertAction(title: "Send", style: .default, handler: { (action) in
                    if let currentArt = self.selectedArtwork {
                        if let artID = currentArt.numID {
                            if let reportText = otherAlert.textFields?[0].text {
                                reportRef.child(String(artID)).setValue(reportText)
                            }
                        }
                    }
                    let successAlert = UIAlertController(title: "Thank You", message: "Your resposne has been submitted and will be reviewed shortly", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    successAlert.addAction(okAction)
                    self.present(successAlert, animated: true)
                })
                otherAlert.addAction(sendAction)
                otherAlert.addAction(cancelAct)
                self.present(otherAlert, animated: true)
            })
            menuAlert.addAction(noArtAction)
            menuAlert.addAction(contentAction)
            menuAlert.addAction(otherAction)
            menuAlert.addAction(cancelAct)
            self.present(menuAlert, animated: true)
        }
        reportAlert.addAction(reportAction)
        reportAlert.addAction(cancelAct)
        self.present(reportAlert, animated: true)
    }

    // MARK: Editing the Image

    @objc func handleImageTapGesture(gesture: UITapGestureRecognizer) {
        let alert = UIAlertController(title: nil, message: "Edit image?", preferredStyle: .alert)
        let editAction = UIAlertAction(title: "Edit", style: .default) { (action) in
            let editAlert = UIAlertController(title: "Select Image", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let galleryAction = UIAlertAction(title: "Library", style: .default) { (action) in
                self.getGallaryPermission()
            }
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
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
                if AVCaptureDevice.authorizationStatus(for: .video) != .notDetermined {
                    let cameraSettingsAlert = UIAlertController(title: "Camera access not enabled", message: "You can configure your settings to allow camera access in Settings", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                        let settingsURL = URL(string: UIApplication.openSettingsURLString)
                        UIApplication.shared.open(settingsURL!, options: [:], completionHandler: nil)
                    })
                    cameraSettingsAlert.addAction(okAction)
                    cameraSettingsAlert.addAction(settingsAction)
                    self.present(cameraSettingsAlert, animated: true)
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
            if PHPhotoLibrary.authorizationStatus() != .notDetermined {
                let librarySettingsAlert = UIAlertController(title: "Photo Library access not enabled", message: "You can configure your settings to allow Library access in Settings", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                    let settingsURL = URL(string: UIApplication.openSettingsURLString)
                    UIApplication.shared.open(settingsURL!, options: [:], completionHandler: nil)
                })
                librarySettingsAlert.addAction(okAction)
                librarySettingsAlert.addAction(settingsAction)
                self.present(librarySettingsAlert, animated: true)
            }
        } else {
            openGallary()
        }
    }

    func openGallary() {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        } else {
            return
        }
    }

    func openCamera() {
        picker.sourceType = .camera
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        shouldShowWarning = true
        noImageLabel.isHidden = true
        fullSizeImage = selectedImage
        artImage.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
}

// MARK: Text View Delegate Methods

extension EditViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        let originalTransform = self.view.transform
        let translatedUp = originalTransform.translatedBy(x: 0, y: -215)
        UIView.animate(withDuration: 0.3, animations: {
            self.view.transform = translatedUp
        })
        if textView.text == "Add Additional Information" {
            textView.text = ""
            textView.textColor = UIColor.darkText
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        let originalTransform = self.view.transform
        let translatedDown = originalTransform.translatedBy(x: 0, y: 215)
        UIView.animate(withDuration: 0.3, animations: {
            self.view.transform = translatedDown
        })
        if textView.text == "" {
            textView.text = "Add Additional Information"
            textView.textColor = UIColor.lightGray
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        shouldShowWarning = true
    }
}

// MARK: Text Field Delegate Methods

extension EditViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        shouldShowWarning = true
    }
}
