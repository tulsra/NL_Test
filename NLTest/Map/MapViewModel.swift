//
//  MapViewModel.swift
//  DTD-iOS
//
//  Created by Tulasi on 30/04/19.
//  Copyright © 2019 Dispachtrack. All rights reserved.
//

import Foundation
import MapKit

enum Defualt_Map: String {
    case apple_map, google_map, sygic_map, waze_map
}

let Selected_Defualt_Map = "Defualt_Map"



struct  MapViewModel {

    var schedules : NSMutableArray?
    var mapView: MKMapView
    
    private let MINIMUM_ZOOM_ARC = 0.014
    private let ANNOTATION_REGION_PAD_FACTOR = 1.15
    private let MAX_DEGREES_ARC = 360.0
    

    
    func loadDetails() {
        let annotations : [MKAnnotation] = self.mapView.annotations
        for annotation in annotations{
            self.mapView.removeAnnotation(annotation)
        }
        
        if let kSchedules = self.schedules, kSchedules.count > 0 {
            for schedule in kSchedules {
                if schedule is ServiceOrder {
                    addAnnotationView(schedule: schedule as! ServiceOrder)
                }
            }
            showAllAnnotationViewsInMapView()
        }
    }
    
    private func addAnnotationView(schedule: ServiceOrder) {
        
            var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0);
        location.latitude = schedule.lat ?? 0
        location.longitude = schedule.lat ?? 0
            
            let center = location
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))
        mapView.setRegion(region, animated: true)
        var annatationImage = UIImage()
        if let number = schedule.stop_number{
            if number < 21 {
                annatationImage = UIImage(named: "images_count\(number)")!
            }
            else {
                annatationImage = UIImage(named: "images_count21")!
            }
            
            
         }
        else{
            
            annatationImage = UIImage(named: "images_count21")!
        }
        
        let header =  String(format:"%d . %@",schedule.stop_number ?? 0,schedule.job_name ?? "")
        let address = String(format:"%@",getFullAddress(schedule: schedule))
        let placeMark = MapPlaceMark(coordinate: location, title: header, subtitle: address, image: annatationImage, schdule: schedule)
        let annotation =  MKPinAnnotationView(annotation: placeMark, reuseIdentifier: "pin")
        mapView.addAnnotation(annotation.annotation!)
        
        
    }
    
    
    private func showAllAnnotationViewsInMapView() {
        
        // do {
        //ktr
        var zoomRect: MKMapRect = MKMapRect.null
        for annotation: Any in mapView.annotations {
            let annotationPoint: MKMapPoint = MKMapPoint((annotation as AnyObject).coordinate)
            let pointRect: MKMapRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1)
            if zoomRect.isNull {
                zoomRect = zoomRect.union(pointRect)
            }
            else {
                zoomRect = zoomRect.union(pointRect)
            }
        }
        mapView.setVisibleMapRect(zoomRect, animated: true)
        zoomMapView(animated: true)
     
    }
    
    
    // Used to zoom the mapview automatically to display all the stops on screen
    
    private func zoomMapView( animated: Bool) {
        
        let annotations = mapView.annotations
        let count: Int = mapView.annotations.count
        if count == 0 {
            return
        }
        
        var points = [MKMapPoint](repeating: MKMapPoint(), count: count)
        //C array of MKMapPoint struct
        for i in 0..<count {
            let coordinate: CLLocationCoordinate2D? = (annotations[i]).coordinate
            points[i] = MKMapPoint(coordinate!)
        }
        //create MKMapRect from array of MKMapPoint
        let mapRect: MKMapRect = MKPolygon(points: points, count: count).boundingMapRect
        //convert MKCoordinateRegion from MKMapRect
        var region: MKCoordinateRegion = MKCoordinateRegion(mapRect)
        //add padding so pins aren't scrunched on the edges
        region.span.latitudeDelta *= ANNOTATION_REGION_PAD_FACTOR
        region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR
        //but padding can't be bigger than the world
        if region.span.latitudeDelta > MAX_DEGREES_ARC {
            region.span.latitudeDelta = MAX_DEGREES_ARC
        }
        if region.span.longitudeDelta > MAX_DEGREES_ARC {
            region.span.longitudeDelta = MAX_DEGREES_ARC
        }
        //and don't zoom in stupid-close on small samples
        if region.span.latitudeDelta < MINIMUM_ZOOM_ARC {
            region.span.latitudeDelta = MINIMUM_ZOOM_ARC
        }
        if region.span.longitudeDelta < MINIMUM_ZOOM_ARC {
            region.span.longitudeDelta = MINIMUM_ZOOM_ARC
        }
        //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
        if count == 1 {
            region.span.latitudeDelta = MINIMUM_ZOOM_ARC
            region.span.longitudeDelta = MINIMUM_ZOOM_ARC
        }
        mapView.setRegion(region, animated: animated)
    }
    
    
    private func getFullAddress(schedule: ServiceOrder) -> String {
        
        if (schedule.address_line2) != nil {
            return String(format:"%@, %@, %@, %@-%@",schedule.address_line1 ?? "", schedule.address_line2 ?? "", schedule.city ?? "", schedule.state ?? "", schedule.zipcode ?? "")
        }
        else if (schedule.zipcode) != nil {
            return String(format:"%@, %@, %@-%@",schedule.address_line1 ?? "", schedule.city ?? "", schedule.state ?? "", schedule.zipcode ?? "")
        }
        else {
            return String(format:"%@, %@, %@",schedule.address_line1 ?? "", schedule.city ?? "", schedule.state ?? "")
        }
    }
}

struct Directions {
    //MARK: Return Home Backto ware house with out waypoints
    func navigate_to_map(latitude: String, longitude: String){
        let _lat = latitude, _long = longitude, selected_map = UserDefaults.standard.getData(key: Selected_Defualt_Map)
        
        switch selected_map {
        case Defualt_Map.apple_map.rawValue:
            self.open_maps(_lat: _lat, _long: _long)
        case Defualt_Map.google_map.rawValue:
            self.openDirections(_lat: _lat, _long: _long)
        case Defualt_Map.sygic_map.rawValue:
            self.showDirectionsinSygicApp(longitude: Double(_long)!, latitude: Double(_lat)!,waypoints: nil,routeId: nil)
        case Defualt_Map.waze_map.rawValue:
            self.open_waze(_lat: _lat, _long: _long)
        default:
            self.openDirections(_lat: _lat, _long: _long)
        }
        
    }
    
    //MARK: Directions
    
    func navigate_to_map(order: ServiceOrder){
        let _lat = "\(order.lat ?? 0)", _long = "\(order.lng ?? 0)", selected_map = UserDefaults.standard.getData(key: Selected_Defualt_Map)
        
        switch selected_map {
        case Defualt_Map.apple_map.rawValue:
            self.open_maps(_lat: _lat, _long: _long)
        case Defualt_Map.google_map.rawValue:
            self.openDirections(_lat: _lat, _long: _long)
        case Defualt_Map.sygic_map.rawValue:
            self.showDirectionsinSygicApp(longitude: Double(_long)!, latitude: Double(_lat)!,waypoints: order.waypoints,routeId: order.route_order_id)
        case Defualt_Map.waze_map.rawValue:
            self.open_waze(_lat: _lat, _long: _long)
        default:
            self.openDirections(_lat: _lat, _long: _long)
        }
        
    }
    
    // Waze map Config
    func open_waze(_lat: String, _long: String){
        
        if !UIApplication.shared.canOpenURL(URL(string:"waze://")!) {
            openURL(url: URL(string:"https://waze.com/ul?ll=\(_lat),\(_long)&navigate=yes")!)
         }
        else{
            openURL(url: URL(string:"http://itunes.apple.com/us/app/id323229106")!)
        }
        
    }
    
    // Apple Maps application Config
    func open_maps(_lat: String, _long: String){
        
        let urlStr = "http://maps.apple.com/maps?daddr=\(_lat),\(_long)"
        if UIApplication.shared.canOpenURL(URL(string:urlStr)!) {
            openURL(url: URL(string:urlStr)!)
         }
        else{
            openURL(url: URL(string:"https://itunes.apple.com/us/app/maps/id915056765?mt=8")!)
        }
    }
    
    //Sygic map Config
    func showDirectionsinSygicApp(longitude: Double, latitude: Double, waypoints: [waypoints]?,routeId: Int?) {
         var isSygicTruckGPSInstalled = false
         let appUrl = URL(string: "com.sygic.truck://app")
         if UIApplication.shared.canOpenURL(appUrl! as URL)
         {
         isSygicTruckGPSInstalled = true
         } else {
         isSygicTruckGPSInstalled = false
         }
         //Get the truck weight based on the order id
        let truck_weightString = DBManager.shared.getTruck_weight(RouteId: "\(routeId ?? 0)")
        
         let sygicApp: URL = URL(string: "com.sygic.aura://")!
        
         var URLL = ""
         var customeUrlString = "\(latitude),\(longitude)"
        if waypoints != nil && (waypoints?.count ?? 0) > 0 && isSygicTruckGPSInstalled{
            
            for i in 0..<(waypoints?.count ?? 0) {
                if let latString = waypoints?[i].lat , let longString = waypoints?[i].long {
                    customeUrlString.append("|\(longString)|\(latString)")
                }
            }
         URLL = #"com.sygic.aura://truckSettings|axw=\#(truck_weightString)&&&coordinate|\#(longitude)|\#(latitude)\#(customeUrlString)|drive"#
          }
        else{
         URLL = #"com.sygic.aura://truckSettings|axw=\#(truck_weightString)&&&coordinate|\#(longitude)|\#(latitude)|drive"#
         }
        
        
         if UIApplication.shared.canOpenURL(sygicApp) , let newURL = URL(string: ((URLL as NSString).addingPercentEscapes(using:String.Encoding.utf8.rawValue)) ?? "") {
         openURL(url: newURL)
         }else {
         openURL(url: (URL(string:"https://itunes.apple.com/us/app/sygic-truck-gps-navigation/id992127700?mt=8")!))
         }
    }
    
    //Google map Config
    func openDirections(_lat: String, _long: String) {
        let url = "comgooglemaps://?daddr=\(_lat),\(_long)&saddr=\("")&dir_action=navigate"
        
        let checkGoogleApp: URL = URL(string: "comgooglemaps://")!
        
        if UIApplication.shared.canOpenURL(checkGoogleApp) , let newURL = URL(string: ((url as NSString).addingPercentEscapes(using:String.Encoding.utf8.rawValue)) ?? "") {
            openURL(url: newURL)
         }
        else{
            openURL(url: URL(string:"https://itunes.apple.com/us/app/google-maps-gps-navigation/id585027354?mt=8")!)
        }
    }
    
    
    func openURL(url: URL){
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
