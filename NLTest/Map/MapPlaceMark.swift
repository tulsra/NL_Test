//
//  MapPlaceMark.swift
//  DispatchTrack
//
//  Created by Badarinadh on 12/12/17.
//  Copyright © 2017 DispatchTrack. All rights reserved.
//

import UIKit
import MapKit

class MapPlaceMark: NSObject, MKAnnotation {
    
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var address: String!
    var image: UIImage!
    var serviceOrder: ServiceOrder!
    
    init(coordinate c: CLLocationCoordinate2D, title markTitle: String, subtitle markSubtitle: String, image img: UIImage,schdule order: ServiceOrder ) {
        coordinate = c
        title = markTitle
        address = markSubtitle
        serviceOrder = order
        image = img
    }

}
