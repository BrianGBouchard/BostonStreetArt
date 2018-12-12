import Foundation
import UIKit

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
}

