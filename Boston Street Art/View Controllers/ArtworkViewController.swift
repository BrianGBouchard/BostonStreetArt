import Foundation
import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class ArtworkViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: Properties

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
    var shouldUpdate = false

    // MARK: View Controller Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        addImageLabel.isHidden = true
        activity.hidesWhenStopped = true
        activity.startAnimating()
        setLabels()

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(gesture:)))
        swipeGesture.direction = .down
        self.view.addGestureRecognizer(swipeGesture)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: self)
        if let currentArt = self.selectedArtwork {
            if let editVC = segue.destination as? EditViewController {
                editVC.selectedArtwork = currentArt
                editVC.artworkViewControlelr = self
            }
        }
    }

    // MARK: Setting up VC appearance

    func setLabels() {
        if let artUnwrapped = self.selectedArtwork {
            if artUnwrapped.artTitle != "[Add Title]" {
                self.titleLabel.text! = artUnwrapped.artTitle
            }

            if artUnwrapped.artist != "[Add Artist]" {
                self.artistLabel.text! = artUnwrapped.artist
            }

            if artUnwrapped.address != "[Add Address]" {
                self.addressLabl.text! = artUnwrapped.address
            }

            if artUnwrapped.info != "[Add Information]" {
                self.artworkInfo.text = artUnwrapped.info
            }
            
            if let pic = self.selectedArtwork!.image {
                self.imageView.image = pic
                self.addImageLabel.isHidden = true
                self.activity.stopAnimating()
            } else {
                self.addImageLabel.isHidden = false
                self.activity.stopAnimating()
            }
        }
    }

    // MARK: Gesture Recognizer Methods

    @objc func handleSwipeGesture(gesture: UISwipeGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: Actions

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

    @IBAction func doneButtonPressed(sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: Delete Button method, if need be

    /*
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
    */
}
