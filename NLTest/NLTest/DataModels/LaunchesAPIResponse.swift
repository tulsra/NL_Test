//
//  LaunchesAPIResponse.swift
//  NLTest
//
//  Created by Tulasi on 01/08/19.
//  Copyright © 2019 Assignment. All rights reserved.
//

import Foundation

class LaunchesAPIResponse: NSObject, Mappable, Codable {
    
    var flight_number: Int?
    var mission_name: String?
    var mission_id: [String]?
    var launch_date_unix: Int?
    var launch_year: String?
    var links: Links?
    
    override init() {
        super.init()
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        flight_number <- map["flight_number"]
        mission_name <- map["mission_name"]
        mission_id <- map["mission_id"]
        launch_date_unix <- map["launch_date_unix"]
        launch_year <- map["launch_year"]
        links <- map["links"]
    }
}

class Links: NSObject, Mappable, Codable {

    var flickr_images:[String]?
    
    override init() {
        super.init()
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
   
        flickr_images <- map["flickr_images"]
    }
    
}
