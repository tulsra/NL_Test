//
//  APIWrapperExtention.swift
//  DTD-iOS
//
//  Created by DISPATCHTRACK on 21/06/19.
//  Copyright © 2019 Dispachtrack. All rights reserved.
//

import Foundation
import UIKit

extension APIWrapper {
    
    func getSchedules(dates: (Double, Double), completion: @escaping (_ resopnse: Any?,_ error: String?)->())  {
        var parm1 = ParameterDetail()
        
        parm1.business_code = DBManager.shared.getBusinessCode()
        parm1.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm1.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        parm1.start_date = "\(Int(dates.0))"
        parm1.end_date = "\(Int(dates.1))"
        parm1.account_id = ""
        parm1.order_info = ""
        parm1.offset = "0"
        parm1.date = ""
        parm1.lat = "\(AppController.shared.delegate().userLatitude)"
        parm1.lng = "\(AppController.shared.delegate().userLongitude)"
        parm1.timestamp = "\(Int(Date().timeIntervalSince1970))"
        parm1.client_version = UserDefaults.standard.getData(key: "VERSION_ID")
        
        let cacheKey = UserDefaults.standard.getData(key: SERVER_CACHE_KEY)
        if !cacheKey.isEmpty{
            parm1.cache_key = cacheKey
        }
        if let dict = parm1.dictionary {
            NetworkManager().req(method: .schedule, parameters: dict) { (response, error) in
                completion(response, error)
            }
        }
    }
    
    func upEventStatus(params: (Int, String), completion: @escaping (_ resopnse: Any?,_ error: String?)->())  {
        var parm1 = ParameterDetail()
                
        parm1.business_code = DBManager.shared.getBusinessCode()
        parm1.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm1.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        parm1.lat = "\(AppController.shared.delegate().userLatitude)"
        parm1.lng = "\(AppController.shared.delegate().userLongitude)"
        parm1.timestamp = "\(timeStamp)"
        parm1.client_version = UserDefaults.standard.getData(key: "VERSION_ID")
        parm1.service_route_id = "\(params.0)"
        parm1.event_type = params.1
        let cacheKey = UserDefaults.standard.getData(key: SERVER_CACHE_KEY)
        if !cacheKey.isEmpty{
            parm1.cache_key = cacheKey
        }
        if let dict = parm1.dictionary {
            NetworkManager().req(method: .route_event, parameters: dict) { (response, error) in
                completion(response, error)
            }
        }
    }
    
    func getServiceOrderDetails(orderNumber: String, completion: @escaping (_ resopnse: Any?,_ error: String?)->())  {
        var parm1 = ParameterDetail()
        
        parm1.business_code = DBManager.shared.getBusinessCode()
        parm1.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm1.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        parm1.order_number = orderNumber
     
        parm1.lat = "\(AppController.shared.delegate().userLatitude)"
        parm1.lng = "\(AppController.shared.delegate().userLongitude)"
        parm1.timestamp = "\(Int(Date().timeIntervalSince1970))"
        parm1.client_version = UserDefaults.standard.getData(key: "VERSION_ID")
        let cacheKey = UserDefaults.standard.getData(key: SERVER_CACHE_KEY)
        if !cacheKey.isEmpty{
            parm1.cache_key = cacheKey
        }
        if let dict = parm1.dictionary {
            NetworkManager().req(method: .service_order_detail, parameters: dict) { (response, error) in
                completion(response, error)
            }
        }
    }
    
    func getMessages(dates: (Double, Double), completion: @escaping (_ resopnse: Any?,_ error: String?)->())  {
        var parm1 = ParameterDetail()
        parm1.business_code = DBManager.shared.getBusinessCode()
        parm1.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm1.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        parm1.start_time = "\(Int(dates.0))"
        parm1.end_time = "\(Int(dates.1))"
        
        
        if let dict = parm1.dictionary {
            NetworkManager().post(method: .GET_MESSAGES, parameters: dict, isJSON: false) { (response, error) in
                completion(response, error)
            }
        } else { completion(nil, "Error: Parameters are not appeneded properly")}
    }
    

    func getSubmittedDVIRforms(method: Method, dates: (Double, Double), completion: @escaping (_ resopnse: Any?,_ error: String?)->())  {
        var parm1 = ParameterDetail()
        
        parm1.business_code = DBManager.shared.getBusinessCode()
        parm1.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm1.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        parm1.start_date = "\(Int(dates.0))"
        parm1.end_date = "\(Int(dates.1))"
        
        
        let cacheKey = UserDefaults.standard.getData(key: SERVER_CACHE_KEY)
        if !cacheKey.isEmpty{
            parm1.cache_key = cacheKey
        }
        if let dict = parm1.dictionary {
            NetworkManager().req(method: method, parameters: dict) { (response, error) in
                completion(response, error)
            }
        }
    }
    
    func getDVIRForms(completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        
        var parm = ParameterDetail()
        parm.business_code = DBManager.shared.getBusinessCode()
        parm.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        parm.name =  "dvir_form"
        
        if let dict = parm.dictionary {
            
            NetworkManager().req(method: .form_templates, parameters: dict) { (response, error) in
                completion(response, error)
            }
        } else { completion(nil, "Error: Parameters are not appeneded properly")}
        
    }
   
    
     func uploadNote(note:Service_Order_Notes_Buffer, pingTime: String,completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        
        var parm = ParameterDetail()
        parm.business_code = DBManager.shared.getBusinessCode()
        parm.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        
        parm.service_order_id = "\(Int(truncating: note.orderId!))"
        parm.job_notes = note.message ?? ""
        parm.job_followup = ""
        parm.lat = "\(Double(truncating: note.latitude ?? NSNumber(value: 0)))"
        parm.lng = "\(Double(truncating: note.longitude ?? NSNumber(value: 0)))"
        parm.timestamp = "\(Int(truncating: note.timeStamp ?? NSNumber(value: Int(Date().unixString()) ?? 0)))"
        
        parm.ping_TimeStamp = pingTime
        parm.client_version = UserDefaults.standard.getData(key: "VERSION_ID")
        
        
        if let yesterDayLogin = UserDefaults.standard.getLoginModel()?.isEnableYesteradyDriverLogin(), yesterDayLogin == true {
            
            parm.internal_login = ""//Modify
        }
        
        if let dict = parm.dictionary {
            
            NetworkManager().req(method: .service_order_update, parameters: dict) { (response, error) in
                completion(response, error)
            }
        } else { completion(nil, "Error: Parameters are not appeneded properly")}
    }
    
    
    func uploadLineItem(ServiceOrderBuffer:Service_Order_Services_Buffer, pingTime: String,completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        
        var parm = ParameterDetail()
        parm.business_code = DBManager.shared.getBusinessCode()
        parm.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        parm.client_version = UserDefaults.standard.getData(key: "VERSION_ID")
        parm.lat = "\(AppController.shared.delegate().userLatitude)"
        parm.lng = "\(AppController.shared.delegate().userLongitude)"
        parm.timestamp = pingTime
        parm.order_number = ServiceOrderBuffer.orderNumber ?? ""
        parm.service_order_items = ServiceOrderBuffer.itemsIds ?? ""
        parm.service_order_delivery_details = ServiceOrderBuffer.itemsDetails ?? ""
        
        if UserDefaults.standard.getLoginModel()?.isEnableYesteradyDriverLogin() ?? false{
            parm.internal_login = UserDefaults.standard.getData(key: INTERNALLOGINVALUE)
        }
        
        
        if let dict = parm.dictionary {
            
            NetworkManager().post(method: .service_order_items_delivered, parameters: dict, isJSON: false) { (response, error) in
                completion(response, error)
            }
        } else { completion(nil, "Error: Parameters are not appeneded properly")}
    }
    
    
    func uploadSurvey(survey:Service_Order_Survey_Buffer, pingTime: String,completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        
        var parm = ParameterDetail()
        parm.business_code = DBManager.shared.getBusinessCode()
        parm.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        
        parm.service_order_id = "\(Int(truncating: survey.orderId!))"
        
        parm.lat = "\(Double(truncating: survey.latitude ?? NSNumber(value: 0)))"
        parm.lng = "\(Double(truncating: survey.longitude ?? NSNumber(value: 0)))"
        parm.timestamp = "\(Int(truncating: survey.timeStamp ?? NSNumber(value: Int(Date().unixString()) ?? 0)))"
        
        parm.ping_TimeStamp = pingTime
        parm.client_version = UserDefaults.standard.getData(key: "VERSION_ID")
        
        
        if let yesterDayLogin = UserDefaults.standard.getLoginModel()?.isEnableYesteradyDriverLogin(), yesterDayLogin == true {
            parm.internal_login = ""//Modify
        }
        
        var method: Method = .post_survey
        if let type = survey.surveyType {
            if type == "Declined" {
                method = .survey_decline
            }
            else if type == "MailSent" {
                method = .survey_email
                parm.customer_email = survey.answerOrEmail
            }
            else {
                method = .post_survey
                parm.answers = survey.answerOrEmail
            }
        }
        else {
            method = .post_survey
            parm.answers = survey.answerOrEmail
        }
        
        if let dict = parm.dictionary {
            NetworkManager().req(method: method, parameters: dict) { (response, error) in
                completion(response, error)
            }
        } else { completion(nil, "Error: Parameters are not appeneded properly")}
    }
    
    func getETAforOrder(orderId: Int, completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        
        var parm = ParameterDetail()
        parm.business_code = DBManager.shared.getBusinessCode()
        parm.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        parm.order_id =  "\(orderId)"
        parm.lat = "\(AppController.shared.delegate().userLatitude)"
        parm.lng = "\(AppController.shared.delegate().userLongitude)"
        parm.timestamp = Date().unixString()
        parm.client_version = UserDefaults.standard.getData(key: "VERSION_ID")
        
        if let dict = parm.dictionary {
            
            NetworkManager().req(method: .eta_at_order, parameters: dict) { (response, error) in
                completion(response, error)
            }
        } else { completion(nil, "Error: Parameters are not appeneded properly")}
        
    }
    
    func reqCallAhead(inMinutes min: Int, orderId: Int, completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        var parm = ParameterDetail()
        parm.business_code = DBManager.shared.getBusinessCode()
        parm.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        parm.order_id =  "\(orderId)"
        parm.num_minutes = "\(min)"
        
        parm.lat = "\(AppController.shared.delegate().userLatitude)"
        parm.lng = "\(AppController.shared.delegate().userLongitude)"
        parm.timestamp = Date().unixString()
        parm.client_version = UserDefaults.standard.getData(key: "VERSION_ID")
        
        if let dict = parm.dictionary {
            NetworkManager().req(method: .call_ahead, parameters: dict) { (response, error) in
                completion(response, error)
            }
        } else { completion(nil, "Error: Parameters are not appeneded properly")}
    }
    
    func updateOrderEventStatus(eventOrderObject:Service_Order_Event_Buffer, pingTime: String,completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        
        var parm = ParameterDetail()
        parm.business_code = DBManager.shared.getBusinessCode()
        parm.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        parm.lat = "\(AppController.shared.delegate().userLatitude)"
        parm.lng = "\(AppController.shared.delegate().userLongitude)"
        parm.timestamp = Date().unixString()
        parm.client_version = UserDefaults.standard.getData(key: "VERSION_ID")
        parm.ping_TimeStamp = pingTime
        
        var method: Method = .event_status
        
        if eventOrderObject.eventType?.caseInsensitiveCompare("ScheduledEvent") == .orderedSame {
            
            parm.event_id = "\(eventOrderObject.orderId?.intValue ?? 0)"
            parm.status = eventOrderObject.eventTypeToServer
            parm.actual_start_time = ""
            parm.actual_end_time = ""
            
            if eventOrderObject.eventTypeToServer?.caseInsensitiveCompare("Started") == .orderedSame {
                parm.actual_start_time = "\(eventOrderObject.timeStamp?.intValue ?? 0)"
            }
            else if eventOrderObject.eventTypeToServer?.caseInsensitiveCompare("Finished") == .orderedSame  {
                parm.actual_end_time = "\(eventOrderObject.timeStamp?.intValue ?? 0)"
            }
            else { }
            
            if let yesterDayLogin = UserDefaults.standard.getLoginModel()?.isEnableYesteradyDriverLogin(), yesterDayLogin == true {
                parm.internal_login = ""//Modify
                parm.actual_start_time = ""
                parm.actual_end_time = ""
            }
           
        }
        else {
//            if DBManager.shared.getSignatureFromBuffer(OrderID: "\(eventOrderObject.orderId ?? 0)") &&  eventOrderObject.eventTypeToServer?.lowercased() == "finish" {
//                continue
//            }
            
            parm.service_order_id = "\(eventOrderObject.orderId?.intValue ?? 0)"
            parm.event_type = eventOrderObject.eventTypeToServer
            parm.lat = "\(eventOrderObject.latitude?.doubleValue ?? 0.0)"
            parm.lng = "\(eventOrderObject.longitude?.doubleValue ?? 0.0)"
            parm.timestamp = "\(eventOrderObject.timeStamp?.intValue ?? 0)"
            
            if let notes = eventOrderObject.notes, notes.count > 0 {
                parm.notes = notes
            }
            
            if let yesterDayLogin = UserDefaults.standard.getLoginModel()?.isEnableYesteradyDriverLogin(), yesterDayLogin == true {
                parm.internal_login = ""//Modify
            }
            
            method = .order_status
            
        }      
        
        if let dict = parm.dictionary {
            NetworkManager().post(method: method, parameters: dict, isJSON: false) { (response, error) in
                completion(response, error)
            }
        } else { completion(nil, "Error: Parameters are not appeneded properly")}
        
    }
    
    
    
    func uploadLineItem(lineItem:Service_Order_Line_Item_Buffer, pingTime: String,completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        
        var parm = ParameterDetail()
        parm.business_code = DBManager.shared.getBusinessCode()
        parm.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        
        let model = UserDefaults.standard.getLoginModel()
        
        parm.order_number = lineItem.order_number
        parm.serial_number = lineItem.serial_number
        parm.quantity = lineItem.quantity
        parm.description = lineItem.itemDescription
        parm.amount = lineItem.amount
        
        if lineItem.isAddCandidate != 1 {
            parm.id = lineItem.item_id
        }
        if let enable_line_item_number = model?.enableLineItemNumber, enable_line_item_number == true {
            parm.number = lineItem.number
        }
   
        parm.lat = "\(Double(truncating: lineItem.latitude ?? NSNumber(value: 0)))"
        parm.lng = "\(Double(truncating: lineItem.longitude ?? NSNumber(value: 0)))"
        parm.timestamp = "\(Int(truncating: lineItem.timestamp ?? NSNumber(value: Int(Date().unixString()) ?? 0)))"
        parm.ping_TimeStamp = pingTime
        parm.client_version = UserDefaults.standard.getData(key: "VERSION_ID")
        
        
        if let yesterDayLogin = UserDefaults.standard.getLoginModel()?.isEnableYesteradyDriverLogin(), yesterDayLogin == true {
            
            parm.internal_login = UserDefaults.standard.getData(key: INTERNALLOGINVALUE)
        }
        
        if let dict = parm.dictionary {
            
            NetworkManager().post(method: .add_line_items, parameters: dict, isJSON: false) { (response, error) in
                completion(response, error)
            }
        } else { completion(nil, "Error: Parameters are not appeneded properly")}
    }
    
    //Custom Fields Uploading
    func uploadCustomFields(customField:Custom_Field_Buffer, pingTime: String,completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        
        var parm = ParameterDetail()
        parm.business_code = DBManager.shared.getBusinessCode()
        parm.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        parm.ping_TimeStamp = pingTime
        parm.client_version = UserDefaults.standard.getData(key: "VERSION_ID")
        parm.lat = "\(customField.latitude ?? 0)"
        parm.lng = "\(customField.longitude ?? 0)"
        parm.custom_fields = "\(customField.answerAndId ?? "")"
        parm.service_order_id = customField.orderId
        
        if let yesterDayLogin = UserDefaults.standard.getLoginModel()?.isEnableYesteradyDriverLogin(), yesterDayLogin == true {
            parm.internal_login = UserDefaults.standard.getData(key: INTERNALLOGINVALUE)
        }
        
        if let dict = parm.dictionary {
            
            NetworkManager().post(method: .save_custom_fields, parameters: dict, isJSON: true) { (response, error) in
                completion(response, error)
            }
        } else { completion(nil, "Error: Parameters are not appeneded properly")}
    }
    
    func updateDriverCheckedItemsWithDetails(allLineItems:[ServiceOrder], pingTime: String,completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        
        var parm = ParameterDetail()
        parm.business_code = DBManager.shared.getBusinessCode()
        parm.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        parm.client_version = UserDefaults.standard.getData(key: "VERSION_ID")
        parm.lat = "\(AppController.shared.delegate().userLatitude)"
        parm.lng = "\(AppController.shared.delegate().userLongitude)"
        parm.timestamp = pingTime
        
        var parameters = parm.dictionary
        
        for i in 0..<allLineItems.count{
            
            let orderCheck: ServiceOrder = allLineItems[i]
            
            if orderCheck.status == "Scheduled" {
                for j in 0..<(orderCheck.service_order_items?.count ?? 0) {
                    if let itemObject: ServiceOrderItem = orderCheck.service_order_items?[j] {
                        
                        let commonKey = "service_orders[\(orderCheck.number!)][service_order_items][\(itemObject.id!)]"
                        
                        parameters?.updateValue(Int(truncating: NSNumber(value:itemObject.checked_quantity!)), forKey: "\(commonKey)[checked_quantity]")
                        
                        if isValidString(string: itemObject.driver_notes ?? "") {
                            parameters?.updateValue(itemObject.driver_notes!, forKey: "\(commonKey)[notes]")
                        }else {
                            parameters?.updateValue("", forKey: "\(commonKey)[notes]")
                        }
                        if isValidString(string: itemObject.driver_return_code ?? "") {
                            parameters?.updateValue(itemObject.driver_return_code!, forKey: "\(commonKey)[return_code]")
                        }else{
                            parameters?.updateValue("", forKey: "\(commonKey)[return_code]")
                        }
                    }
                }
            }
        }
        
   
        
        if let dict = parameters {
            
            NetworkManager().post(method: .service_order_items_checked, parameters: dict, isJSON: false) { (response, error) in
                completion(response, error)
            }
        } else { completion(nil, "Error: Parameters are not appeneded properly")}
    }
    
        
    func logout(completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        
        var parm = ParameterDetail()
        parm.business_code = DBManager.shared.getBusinessCode()
        parm.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm.session_id = UserDefaults.standard.getLoginModel()?.sessionId
       
        parm.phonenumber =  UIDevice.current.identifierForVendor!.uuidString
        parm.lat = "\(AppController.shared.delegate().userLatitude)"
        parm.lng = "\(AppController.shared.delegate().userLongitude)"
        parm.timestamp = Date().unixString()
        
        parm.ping_TimeStamp = Date().unixString()
        parm.client_version = UserDefaults.standard.getData(key: "VERSION_ID")
        
        
        if let yesterDayLogin = UserDefaults.standard.getLoginModel()?.isEnableYesteradyDriverLogin(), yesterDayLogin == true {
            
            parm.internal_login = ""//Modify
        }
        
        if let dict = parm.dictionary {
            
            NetworkManager().req(method: .logout, parameters: dict) { (response, error) in
                completion(response, error)
            }
        } else { completion(nil, "Error: Parameters are not appeneded properly")}
        
    }

    func update_MandatoryRouteTable(routeObject: Mandatory_Route_Buffer?, isValid_startLocation: Bool, isValid_EndLocation: Bool){
        UserDefaults.standard.removeObject(forKey: SERVER_CACHE_KEY)
        
        let mandatory_new: Route = Route()
        mandatory_new.device_enabled = routeObject?.device_enabled
        mandatory_new.date = routeObject?.route_date!
        mandatory_new.route_finished = routeObject?.route_finished
        mandatory_new.route_started = routeObject?.route_started
        mandatory_new.route_type = routeObject?.route_type!
        mandatory_new.id = Int(routeObject?.service_route_id ?? "0")
        mandatory_new.timestamp = "\(routeObject?.timestamp ?? 0)".IntValue
        mandatory_new.route_valid_start_location = isValid_startLocation
        mandatory_new.route_valid_finish_location = isValid_EndLocation
        
        DBManager.shared.delete_MandatoryRouteObjects(route_date: routeObject?.route_date ?? "0", routeId: Int(routeObject?.service_route_id ?? "0") ?? 0)
        
        DBManager.shared.insert_MandatoryRoute(mandatoryRoute: mandatory_new)
        
        DBManager.shared.deleteMandatoryRouteBufferObjectsFromCoreData(route_type: "\((routeObject?.route_type)!)", service_route_id: routeObject?.service_route_id?.IntValue ?? 0)
    }
    
    func updateLocation(trackObject:TrackServiceBuffer, pingTime: String,completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        
        var parm = ParameterDetail()
        parm.business_code = DBManager.shared.getBusinessCode()
        parm.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        parm.client_version = UserDefaults.standard.getData(key: "VERSION_ID")
        parm.lat = "\(AppController.shared.delegate().userLatitude)"
        parm.lng = "\(AppController.shared.delegate().userLongitude)"
        parm.timestamp = "\(trackObject.timeStamp)"
        
        parm.accuracy = "\(trackObject.accuracy)"
        parm.altitude = "\(trackObject.altitude)"
        parm.speed = "\(trackObject.speed)"
        parm.bearing = "\(trackObject.accuracy)"
        parm.stale = "\(trackObject.stale)"
        parm.type = trackObject.networkType
        parm.gps_status = "\(trackObject.gpsStatus)"
        
        if !pingTime.isEmpty {
            parm.ping_TimeStamp = pingTime
            if let yesterDayLogin = UserDefaults.standard.getLoginModel()?.isEnableYesteradyDriverLogin(), yesterDayLogin == true {
                
                parm.internal_login = ""
            }
        }
        
        if let dict = parm.dictionary {
            NetworkManager().req(method: .track, parameters: dict) { (response, error) in
                completion(response, error)
            }
        } else { completion(nil, "Error: Parameters are not appeneded properly")}
        
    }
}
