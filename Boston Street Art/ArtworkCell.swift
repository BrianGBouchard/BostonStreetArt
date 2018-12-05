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
        self.alpha = 0.0
        if let viewController = vc {
            viewController.activity.startAnimating()
        }
    }
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

