import Foundation
import Firebase
import MapKit
import AVKit

class EditViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var artistTextField: UITextField!
    @IBOutlet var locationTextField: UITextField!
    @IBOutlet var infoTextView: UITextView!
    @IBOutlet var noImageLabel: UILabel!
    @IBOutlet var artImage: UIImageView!

    var selectedArtwork: Artwork?
    var initialViewController: MapViewController?
    var favoritesViewController: FavoritesViewController?

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
        }

        let exitEditingTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesutre))
        self.view.addGestureRecognizer(exitEditingTapRecognizer)
    }

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

    @IBAction func doneButtonPressed(sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension EditViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Add Additional Information" {
            textView.text = ""
            textView.textColor = UIColor.darkText
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        if textView.text == "" {
            textView.text = "Add Additional Information"
            textView.textColor = UIColor.lightGray
        }
    }
}

extension EditViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
