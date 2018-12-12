import Foundation
import MapKit

class Artwork: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var artTitle: String = "[Add Title]"
    var artist: String = "[Add Artist]"
    var address: String = "[Add Address]"
    var info: String = "[Add Information]"
    var image: UIImage?
    var thumbnail: UIImage?
    var numID: UInt32?

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
}
