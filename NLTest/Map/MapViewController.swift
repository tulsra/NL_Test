//
//  MapViewController.swift
//  DTD-iOS
//
//  Created by Dispatchtrack on 03/04/19.
//  Copyright © 2019 Dispachtrack. All rights reserved.
//

import UIKit
import KRProgressHUD
import KRActivityIndicatorView
import MapKit

class MapViewController: BaseViewController {

    var markerOrder: MapPlaceMark!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var dateChangerView: DateChangeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dateChangerView.dateChanged = { (start, end) in
            self.loadSchedules(dates: (start, end), completionHandler: {
                let mapModel = MapViewModel(schedules: DBManager.shared.serviceOrdersAndEvents, mapView: self.mapView)
                mapModel.loadDetails()
            })
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dateChangerView.getDatesForCurrentSelectedDate()
    }
    
    override func refreshData() {
        dateChangerView.getDatesForCurrentSelectedDate()
    }

}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation
        {
            return nil
        }
        let mark: MapPlaceMark = annotation as! MapPlaceMark
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil{
            annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = false
         }
        else{
            annotationView?.annotation = annotation
        }
        annotationView?.image = mark.image
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView,
                 didSelect view: MKAnnotationView)
    {
        if view.annotation is MKUserLocation
        {
            return
        }
        let starbucksAnnotation = view.annotation as! MapPlaceMark
        markerOrder = starbucksAnnotation
        let views = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
        let calloutView = views?[0] as! CustomCalloutView
        calloutView.starbucksName.text = starbucksAnnotation.title
        calloutView.starbucksAddress.text = starbucksAnnotation.address
        
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
        calloutView.iconbtn.addTarget(self, action: #selector(popup), for: .touchUpInside)
        
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: AnnotationView.self)
        {
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
        }
    }
    
    
    @objc func popup(){
        MTPopUp(frame: (self.view.window?.frame)!).show(complete: { (index) in
            if index == 1{
                AppController.shared.loadOrderDetails(order: self.markerOrder.serviceOrder)
            }else if index == 2{
                Directions().navigate_to_map(order: self.markerOrder.serviceOrder)
            }
            
        }, view: (self.view.window)!, animationType: MTAnimation.TopToMoveCenter,  btnArray: ["Details","Directions","   "],strTitle: "Navigate To")
    }
    
}
