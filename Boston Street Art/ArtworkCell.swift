//
//  ArtworkCell.swift
//  Boston Street Art
//
//  Created by Brian Bouchard on 11/12/18.
//  Copyright © 2018 Brian Bouchard. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ArtworkCell: UICollectionViewCell {


    @IBOutlet weak var titleLabel: UILabel!

    var idString: String?
    var vc: FavoritesViewController?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        if let viewController = vc {
            viewController.activity.startAnimating()
        }
    }
        /*let activity = UIActivityIndicatorView(frame: CGRect(x: collection.frame.width / 2, y: collection.frame.height / 2, width: 20, height: 20))
        activity.style = .whiteLarge
        collection.addSubview(activity)
        activity.startAnimating()*/

    /*func getInfo() {
        self.alpha = 0.0
        Database.database().reference(withPath: "Artworks").child(self.idString!).child("Title").observeSingleEvent(of: .value) { (data) in
            self.titleLabel.text = data.value as! String
            Storage.storage().reference(withPath: self.idString!).getData(maxSize: 1000000, completion: { (data, error) in
                if let imageData = data {
                    let image = UIImage(data: imageData)
                    let thumbnail = resizeImage(image: image!, newWidth: self.frame.width)
                    let imageView = UIImageView(image: thumbnail!)
                    self.addSubview(imageView)
                    self.fadeTransition(1.0)
                }
            })
        }

    }*/
}

extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        self.alpha = 0.0
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
        self.alpha = 1.0
    }

    func fadeOutTransition(_ duration: CFTimeInterval) {
        self.alpha = 0.0
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
        self.alpha = 1.0
    }
}

