//
//  ArtAnnotation.swift
//  Boston Street Art
//
//  Created by Brian Bouchard on 11/9/18.
//  Copyright © 2018 Brian Bouchard. All rights reserved.
//

import Foundation
import MapKit

class Artwork: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var artist: String?
    var address: String?
    var info: String?
    var image: UIImage?

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
