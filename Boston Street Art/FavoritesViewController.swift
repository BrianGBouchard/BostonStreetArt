import Foundation
import UIKit
import MapKit
import CoreData
import FirebaseStorage
import Firebase
import FirebaseDatabase

class FavoritesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var collection: UICollectionView!
    @IBOutlet var activity: UIActivityIndicatorView!

    var favoritesIDList: Array<SavedArtwork> = []
    var artList: Array<Artwork> = []
    let storageRef = Storage.storage().reference()
    let dataRef = Database.database().reference(withPath: "Artworks")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        let divider = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 1 - tabBarController!.tabBar.frame.height, width: self.view.frame.width, height: 1))
        divider.backgroundColor = UIColor.lightGray
        self.view.addSubview(divider)
        activity.hidesWhenStopped = true
    }

    override func viewDidAppear(_ animated: Bool) {
        activity.startAnimating()
        super.viewDidAppear(true)
        artList = []
        collection.isHidden = false
        if let currentUser = Auth.auth().currentUser?.uid {
            let favoritesRef = Database.database().reference(withPath: "Users").child(currentUser).child("Favorites")
            favoritesRef.observeSingleEvent(of: .value) { (snapshot) in
                let favoritesList = snapshot.children.allObjects as! [DataSnapshot]
                for item in favoritesList {
                    let itemID = item.key
                    self.dataRef.child(itemID).observeSingleEvent(of: .value, with: { (itemSnapshot) in
                        let artCoordinates = CLLocationCoordinate2D(latitude: itemSnapshot.childSnapshot(forPath: "Coordinates").childSnapshot(forPath: "Latitude").value as! Double, longitude: itemSnapshot.childSnapshot(forPath: "Coordinates").childSnapshot(forPath: "Longitude").value as! Double)
                        let artTitle = itemSnapshot.childSnapshot(forPath: "Title").value as! String
                        let artArtist = itemSnapshot.childSnapshot(forPath: "Artist").value as! String
                        let artLocation = itemSnapshot.childSnapshot(forPath: "Location").value as! String
                        let artInfo = itemSnapshot.childSnapshot(forPath: "Info").value as! String
                        let newArt = Artwork(coordinate: artCoordinates)
                        newArt.artTitle = artTitle
                        newArt.artist = artArtist
                        newArt.info = artInfo
                        newArt.address = artLocation
                        newArt.numID = UInt32(itemID)
                        self.storageRef.child(itemID).getData(maxSize: 10000000000, completion: { (data, error) in
                            if let imageData = data {
                                newArt.image = UIImage(data: imageData)
                                newArt.thumbnail = resizeImage(image: newArt.image!, newWidth: 35)
                                self.artList.append(newArt)
                                self.collection.reloadData()

                            } else {
                                self.artList.append(newArt)
                                self.collection.reloadData()
                            }
                        })
                    })
                }
            }
        }
        /*let ann1 = Artwork(coordinate: CLLocationCoordinate2D(latitude: 42.3471, longitude: -71.0825))
        ann1.image = UIImage(named: "NeedsImage")
        collection.reloadData()*/
    }

    override func viewWillDisappear(_ animated: Bool) {
        for item in collection.subviews {
            item.alpha = 0.0
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return artList.count
        } else {
            return 3
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ArtworkCell
        UIView.animate(withDuration: 0.3) {
            cell.alpha = 0.0
        }
        cell.vc = self
        let id = String(artList[indexPath.item].numID!)
        cell.idString = id
        if artList[indexPath.item].artTitle != "[Add Title]" {
            cell.titleLabel.text! = artList[indexPath.item].artTitle
        } else {
            cell.titleLabel.text! = "[No Title]"
        }
        if let image = artList[indexPath.item].image {
            let background = UIImageView(image: resizeImage(image: #imageLiteral(resourceName: "NoImage"), newWidth: cell.frame.width+4))
            cell.addSubview(background)
            let thumbnail = resizeImage(image: image, newWidth: cell.frame.width)
            let imageView = UIImageView(image: thumbnail!)
            cell.addSubview(imageView)
            UIView.animate(withDuration: 0.3) {
                cell.alpha = 1.0
            }
            return cell
        } else {
            let imageView = UIImageView(image: resizeImage(image: #imageLiteral(resourceName: "NoImage"), newWidth: cell.frame.width+3))
            cell.addSubview(imageView)
            UIView.animate(withDuration: 0.3) {
                cell.alpha = 1.0
                self.activity.stopAnimating()
            }
            return cell
        }
    }

    @objc func stopActInd() {
        activity.stopAnimating()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width - 80)/2
        let height = width + 40
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newView = storyboard?.instantiateViewController(withIdentifier: "artwork") as! ArtworkViewController
        newView.initialViewController = self.tabBarController!.viewControllers![0] as! MapViewController
        self.collection.isHidden = true
        newView.selectedArtwork = artList[indexPath.item]
        collection.deselectItem(at: indexPath, animated: true)
        self.present(newView, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.perform(#selector(self.stopActInd), with: nil, afterDelay: 0.4)
    }
}
