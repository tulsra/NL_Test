//
//  APIWrappers.swift
//  DTD-iOS
//
//  Created by DISPATCHTRACK on 20/06/19.
//  Copyright © 2019 Dispachtrack. All rights reserved.
//

import Foundation

enum UpdateModules:String,CaseIterable {
    case notes = "notes"
    case documents = "documents"
    case pictures = "pictures"
    case survey = "survey"
    case signatures = "signature"
    case eventStatus = "eventStatus"
    case lineItems = "lineItems"
    case serviceRoute = "serviceRoute"
    case sendMandatoryRoute = "mandatoryRoutes"
    case DVIRforms = "DVIRforms"
    case releaseForms = "releaseForms"
    case track = "track"
    case customFieldBuffer = "customFieldBuffer"
    case sendTrackServiceBufferData = "sendTrackServiceBufferData"
}

enum CommonResponseModule:String {
    case notes = "notes"
    case documents = "documents"
    case pictures = "pictures"
    case survey = "survey"
    case eventStatus = "eventStatus"
    case surveySignature = "surveySignature"
    case orderSignature = "orderSignature"
    case lineItems = "lineItems"
    case route_EventStatus = "route_event"
    case mandatory_route_EventStatus = "mandatory_route_event"
    case DVIRforms = "DVIRforms"
    case releaseForms = "releaseForms"
    case track = "track"
    case customFields = "customFields"
    case line_items_delivered = "line_items_delivered"
}


class APIWrapper {
     static let shared = APIWrapper()
     private init(){}
    
    var isSuccess = true
    var isInSyncProgress = false
    var pingTime = Date().unixString()
    var tobeUpdateModules: [UpdateModules] = []
    var comletionHandler:()->Void = {
        
    }
    var dvirFormsUploadNotify:()->Void = {
    
    }

    
    private func getBasicParmeters() -> ParameterDetail {
        var parm = ParameterDetail()
        parm.business_code = DBManager.shared.getBusinessCode()
        parm.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        return parm
    }
    
    @objc func uploadData(completion:@escaping ()->Void) {
        
        if Connectivity.isConnectedToNetwork() && !self.isInSyncProgress{
            self.comletionHandler = completion
            self.pingTime = Date().unixString()
            self.isSuccess = true
            self.isInSyncProgress = true
            self.tobeUpdateModules.removeAll()
            self.tobeUpdateModules = UpdateModules.allCases
            print("============ UPLOADING START ============")
            //Uplosding Notes
           self.checkStatusAndUpload()
            
        } else { completion() }
    }
    
    private func checkStatusAndUpload() {
        if Connectivity.isConnectedToNetwork() && self.isSuccess {
            if self.tobeUpdateModules.count > 0 {
                
                let module = self.tobeUpdateModules.first
                guard let position =  self.tobeUpdateModules.index(of: module!) else { return }
                self.tobeUpdateModules.remove(at: position)
                
                switch module {
                case .notes?:
                    self.uploadNotes()
                case .sendTrackServiceBufferData?:
                    self.uploadServiceOrderLineItems()
                case .documents?:
                    self.uploadDocumnets()
                case .pictures?:
                    self.uploadPictures()
                case .signatures?:
                    self.uploadSignatures()
                case .survey?:
                    self.uploadSurveyDetails()
                case .eventStatus?:
                    self.uploadOrderEventStatus()
                case .lineItems?:
                    self.uploadLineItems()
                case .serviceRoute?:
                    self.serviceRouteBuffer()
                case .sendMandatoryRoute?:
                    self.mandatoryRouteBuffer()
                case .DVIRforms?:
                    self.uploadDVIRforms()
                case .releaseForms?:
                    self.uploadReleaseForms()
                case .customFieldBuffer?:
                    self.sendCustomFieldBuffer()
                case .track?:
                    self.uploadTrack()
                case .none:
                    print("Module not identified === \(String(describing: module?.rawValue))")
                }
            }
            else {
                self.isInSyncProgress = false
                self.comletionHandler()
            }
        } else {
            self.isInSyncProgress = false
            self.comletionHandler()
        }
    }
    
    private func uploadNotes() {
        
        print("============ UPLOADING Notes ============")
        let notes = DBManager.shared.retrieveAllUnSynchedNotesFromCoreData()
        if notes.count > 0 {
            self.isInSyncProgress = true
            let notesDispatchGroup = DispatchGroup()
            for note in notes {
                
                let notesObject: Service_Order_Notes_Buffer = note as! Service_Order_Notes_Buffer
                notesDispatchGroup.enter()
                print("========== ENTER NOTE \(notesObject.timeStamp?.intValue ?? 0) ========")
                
                self.uploadNote(note: notesObject, pingTime: self.pingTime) { (response, error) in
                    self.handleCommonApiResponse(dispatchGroup: notesDispatchGroup, response: response, error: error, obj: notesObject, module: .notes)
                }
            }
            
            notesDispatchGroup.notify(queue: DispatchQueue.main) {
                print("========== NOTES SYNC NOTIFY ========")
                self.checkStatusAndUpload()
            }
        }
        else {
            self.checkStatusAndUpload()
        }
    }
    
    private func uploadServiceOrderLineItems(){
    
        print("============ UPLOADING SERVICE ORDER LINE ITEMS ============")
       
        if let arrayServiceBufferObjects = DBManager.shared.retrieveAllUnSynchedServicesBufferObjectsFromCoreData(), arrayServiceBufferObjects.count > 0 {
            self.isInSyncProgress = true
            let LineItemDispatchGroup = DispatchGroup()
            for serviceObject: Service_Order_Services_Buffer in arrayServiceBufferObjects {
                
                if(serviceObject.itemsDetails?.contains(":::|") ?? false){
                    return
                }
                
                LineItemDispatchGroup.enter()
                print("========== ENTER ITEM \(serviceObject.timeStamp?.intValue ?? 0) ========")
                
                self.uploadLineItem(ServiceOrderBuffer: serviceObject, pingTime: self.pingTime) { (response, error) in
                    self.handleCommonApiResponse(dispatchGroup: LineItemDispatchGroup, response: response, error: error, obj: serviceObject, module: .line_items_delivered)
                }
            }
            
            LineItemDispatchGroup.notify(queue: DispatchQueue.main) {
                print("========== ITEM SYNC NOTIFY ========")
                self.checkStatusAndUpload()
            }
        }
        else {
            self.checkStatusAndUpload()
        }
        
        
        
    }
    
    private func uploadDocumnets() {
        print("============ UPLOADING Documents============")
        let docs = DBManager.shared.retrieveAllUnSynchedDocsBufferObjectsFromCoreData()
        if docs.count > 0 {
            self.isInSyncProgress = true
            let docsDispatchGroup = DispatchGroup()
            for doc in docs {
                
                let docObject: Docs_Images_Buffer = doc as! Docs_Images_Buffer
                
                docsDispatchGroup.enter()
                print("========== ENTER IMAGE \(docObject.timeStamp?.intValue ?? 0) ========")
                
                self.uploadDocumentFile(docObj: docObject, pingTime: self.pingTime){ (response, error) in
                    self.handleCommonApiResponse(dispatchGroup: docsDispatchGroup, response: response, error: error, obj: doc, module: .documents)
                }
            }
            
            docsDispatchGroup.notify(queue: DispatchQueue.main) {
                print("========== IMAGE SYNC NOTIFY ========")
                self.checkStatusAndUpload()
            }
        }
        else {
            self.checkStatusAndUpload()
        }
        
    }
    
    private func uploadPictures() {
        print("============ UPLOADING Pictures ============")
        
        let images = DBManager.shared.retrieveAllUnSynchedImageBufferObjectsFromCoreData()
        if images.count > 0 {
            self.isInSyncProgress = true
            let imagesDispatchGroup = DispatchGroup()
            for image in images {
                
                let imageObject: Service_Order_Image_Buffer = image as! Service_Order_Image_Buffer
                //Upload consisting video files only on Wifix
                if !(imageObject.imageCacheFileName!.contains(".mp4") && !Common.shared.isConnectedToWifi()){
                    
                    imagesDispatchGroup.enter()
                    print("========== ENTER IMAGE \(imageObject.timeStamp?.intValue ?? 0) ========")
                    
                    self.uploadImageFile(image: imageObject, pingTime: self.pingTime){ (response, error) in
                        self.handleCommonApiResponse(dispatchGroup: imagesDispatchGroup, response: response, error: error, obj: image, module: .pictures)
                    }
                }
            }
            
            imagesDispatchGroup.notify(queue: DispatchQueue.main) {
                print("========== IMAGE SYNC NOTIFY ========")
                self.checkStatusAndUpload()
            }
        }
        else {
            self.checkStatusAndUpload()
        }
    }
    
    private func uploadSignatures(){
        print("============ UPLOADING Signatures ============")
        
        let signatureBuffer = DBManager.shared.retrieveAllUnSynchedSignatureBufferObjectsFromCoredata()
        if signatureBuffer.count > 0 {
            self.isInSyncProgress = true
            let imagesDispatchGroup = DispatchGroup()
            for image in signatureBuffer {
                
                let signatureObject: Service_Order_Signature_Buffer = image as! Service_Order_Signature_Buffer
                
                    imagesDispatchGroup.enter()
                print("========== ENTER signature \(signatureObject.timeStamp ?? 0) ========")
                    
                self.uploadSignatureFile(surveyObj: signatureObject, pingTime: self.pingTime){ (response, error) in
                        self.handleCommonApiResponse(dispatchGroup: imagesDispatchGroup, response: response, error: error, obj: image, module: .orderSignature)
                    }
            }
            
            imagesDispatchGroup.notify(queue: DispatchQueue.main) {
                print("========== Signature SYNC NOTIFY ========")
                self.checkStatusAndUpload()
            }
        }
        else {
            self.checkStatusAndUpload()
        }
    }
    
    private func uploadSurveyDetails() {
        print("============ UPLOADING Survey Details ============")
        
        let surveyObjects = DBManager.shared.retrieveAllUnSynchedSurveysBufferObjectsFromCoreData()
        if surveyObjects.count > 0 {
            self.isInSyncProgress = true
            let surveyDispatchGroup = DispatchGroup()
            for survey in surveyObjects {
                
                let surveyObject: Service_Order_Survey_Buffer = survey as! Service_Order_Survey_Buffer
                
                surveyDispatchGroup.enter()
                print("========== ENTER SURVEY ========")
                self.uploadSurvey(survey: surveyObject, pingTime: self.pingTime) { (response, error) in
                    self.handleCommonApiResponse(dispatchGroup: surveyDispatchGroup, response: response, error: error, obj: surveyObject, module: .survey)
                    
                }
            }
            
            surveyDispatchGroup.notify(queue: DispatchQueue.main) {
                print("========== SURVEY SYNC NOTIFY ========")
                self.checkStatusAndUpload()
            }
        }
        else {
            self.checkStatusAndUpload()
        }
    }
    
    private func uploadSurveySignature(surveyObject: Service_Order_Survey_Buffer, surveyDispatchGroup: DispatchGroup) {
        APIWrapper.shared.uploadServeySignatureFile(surveyObj: surveyObject, pingTime: self.pingTime, completion: { (response, error) in
            self.handleCommonApiResponse(dispatchGroup: surveyDispatchGroup, response: response, error: error, obj: surveyObject, module: .surveySignature)
        })
    }
    
    private func uploadOrderEventStatus() {
        print("============ UPLOADING Event Status============")
        
        if let events = DBManager.shared.retrieveAllUnSynchedEventStatusBufferObjectsFromCoreData(withOrderId: 0), events.count > 0 {
            self.isInSyncProgress = true
            let eventDispatchGroup = DispatchGroup()
            for event in events {
                
                let eventObject: Service_Order_Event_Buffer = event as! Service_Order_Event_Buffer
                
                eventDispatchGroup.enter()
                print("========== ENTER EVENT \(eventObject.timeStamp?.intValue ?? 0) ========")
                
                self.updateOrderEventStatus(eventOrderObject: eventObject, pingTime: self.pingTime) { (response, error) in
                    self.handleCommonApiResponse(dispatchGroup: eventDispatchGroup, response: response, error: error, obj: eventObject, module: .eventStatus)
                }
            }
            
            eventDispatchGroup.notify(queue: DispatchQueue.main) {
                print("========== Event Status SYNC NOTIFY ========")
                self.checkStatusAndUpload()
            }
        }
        else {
            self.checkStatusAndUpload()
        }
    }

    private func uploadLineItems() {
        print("============ UPLOADING Line Items============")
        
        if let items = DBManager.shared.retrieveAllUnSynchedLineItems(), items.count > 0 {
            self.isInSyncProgress = true
            let lineItemDispatchGroup = DispatchGroup()
            for item in items {
                
                let lineItemObject: Service_Order_Line_Item_Buffer = item as! Service_Order_Line_Item_Buffer
                
                lineItemDispatchGroup.enter()
                print("========== ENTER LINE ITEM \(lineItemObject.timestamp?.intValue ?? 0) ========")
                
                self.uploadLineItem(lineItem: lineItemObject, pingTime: self.pingTime) { (response, error) in
                    self.handleCommonApiResponse(dispatchGroup: lineItemDispatchGroup, response: response, error: error, obj: lineItemObject, module: .lineItems)
                    self.checkStatusAndUpload()
                }
            }
            
            lineItemDispatchGroup.notify(queue: DispatchQueue.main) {
                print("========== Line Item SYNC NOTIFY ========")
            }
        }else {
            self.checkStatusAndUpload()
        }
    }
    private func serviceRouteBuffer() {
        print("============ UPLOADING serviceRouteBuffer Status============")
        
        if let routes = DBManager.shared.retrieveAllUnSynchedServiceRouteObjectsFromCoreData(), routes.count > 0 {
            self.isInSyncProgress = true
            let eventDispatchGroup = DispatchGroup()
            for routeObj in routes {
                
                let eventObject: Service_Route = routeObj
                
                eventDispatchGroup.enter()
                print("========== ENTER serviceRouteBuffer ========")
                self.upEventStatus(params: (Int(eventObject.routeId ?? "0")!, "finish"))
                 { (response, error) in
                    self.handleCommonApiResponse(dispatchGroup: eventDispatchGroup, response: response, error: error, obj: eventObject, module: .route_EventStatus)
                }
                
            }
            
            eventDispatchGroup.notify(queue: DispatchQueue.main) {
                print("========== serviceRouteBuffer Status SYNC NOTIFY ========")
                self.checkStatusAndUpload()
            }
        }
        else {
            self.checkStatusAndUpload()
        }
    }
    
    func mandatoryRouteBuffer(){
        print("============ UPLOADING mandatoryRouteBuffer Status   ============")
        if let routes = DBManager.shared.fetchAllUnSynchedMandatoryRouteBufferObjects(), routes.count > 0 {
            self.isInSyncProgress = true
            let eventDispatchGroup = DispatchGroup()
            for routeObj in routes {
                
                let eventObject: Mandatory_Route_Buffer = routeObj
                
                eventDispatchGroup.enter()
                print("========== ENTER mandatoryRouteBuffer ========")
                self.upEventStatus(params: (Int(eventObject.service_route_id ?? "0")!, eventObject.route_type ?? ""))
                { (response, error) in
                    self.handleCommonApiResponse(dispatchGroup: eventDispatchGroup, response: response, error: error, obj: eventObject, module: .mandatory_route_EventStatus)
                }
                
            }
            
            eventDispatchGroup.notify(queue: DispatchQueue.main) {
                print("========== mandatoryRouteBuffer Status SYNC NOTIFY ========")
                self.checkStatusAndUpload()
            }
        }
        else {
            self.checkStatusAndUpload()
        }
    }

    private func uploadDVIRforms() {
        print("============ UPLOADING DVIR Form============")
        
        let arrayDVIRForms = DBManager.shared.retrieveAllUnSynchedDVIRFormBufferObjectsFromCoreData()
        
        if arrayDVIRForms.count > 0 {
            self.isInSyncProgress = true
            let dvirDispatchGroup = DispatchGroup()
            
            let dvirObject: Service_Order_DVIR_Forms_Buffer = arrayDVIRForms[0] as! Service_Order_DVIR_Forms_Buffer
            
            dvirDispatchGroup.enter()
            print("========== ENTER DVIR \(dvirObject.timeStamp?.intValue ?? 0) ========")
            
            self.uploadDVIRFile(dvirObj: dvirObject, pingTime: self.pingTime, completion: { (response, error) in
                self.handleCommonApiResponse(dispatchGroup: dvirDispatchGroup, response: response, error: error, obj: dvirObject, module: .DVIRforms)
            })
            
            dvirDispatchGroup.notify(queue: DispatchQueue.main) {
                print("========== DVIR SYNC NOTIFY ========")
                self.checkStatusAndUpload()
            }
        }
        else {
            self.checkStatusAndUpload()
        }
    }
    
    private func uploadReleaseForms() {
        print("============ UPLOADING Release Form============")
        let arrayReleaseForms = DBManager.shared.retrieveAllUnSynchedFormBufferObjectsFromCoreData()
        
        if arrayReleaseForms.count > 0 {
            self.isInSyncProgress = true
            let releseDispatchGroup = DispatchGroup()
            
            let formObject: Service_Order_Forms_Buffer = arrayReleaseForms[0] as! Service_Order_Forms_Buffer
            
            releseDispatchGroup.enter()
            print("========== ENTER Release Form \(formObject.timeStamp?.intValue ?? 0) ========")
            
            self.uploadReleaseForm(formObj: formObject, pingTime: self.pingTime, completion: { (response, error) in
                self.handleCommonApiResponse(dispatchGroup: releseDispatchGroup, response: response, error: error, obj: formObject, module: .releaseForms)
            })
            
            releseDispatchGroup.notify(queue: DispatchQueue.main) {
                print("========== RELEASE FORM SYNC NOTIFY ========")
                self.checkStatusAndUpload()
            }
        }
        else {
            self.checkStatusAndUpload()
        }
    }
    
    
    
    private func uploadTrack() {
        print("============ UPLOADING Track ============")
        let arrayTrackObjects = DBManager.shared.retrieveAllUnSynchedTrackServiceBufferObjectsFromCoreData()
        
        if arrayTrackObjects.count > 0 {
            let trackDispatchGroup = DispatchGroup()
            
            for  i in 0..<arrayTrackObjects.count {
                
                let trackObject: TrackServiceBuffer = arrayTrackObjects[i] as! TrackServiceBuffer
                if trackObject.latitude == 0.0 && trackObject.longitude == 0.0 {
                    print(DBManager.shared.deleteTrackServiceBufferObjectFromCoreData(withTimeStamp: trackObject.timeStamp))
                }
                else {
                    self.isInSyncProgress = true
                    
                    trackDispatchGroup.enter()
                    print("========== ENTER Track \(trackObject.timeStamp) ========")
                    
                    self.updateLocation(trackObject: trackObject, pingTime: self.pingTime) { (response, error) in
                        self.handleCommonApiResponse(dispatchGroup: trackDispatchGroup, response: response, error: error, obj: trackObject, module: .track)
                    }
                }
            }
            trackDispatchGroup.notify(queue: DispatchQueue.main) {
                print("========== TRACK SYNC NOTIFY ========")
                self.checkStatusAndUpload()
            }
        }
        else {
            self.checkStatusAndUpload()
        }
    }
    
    //Custom fileds Syncing to server
    private func sendCustomFieldBuffer(){
        print("============ UPLOADING CUSTOMFIELDSS ============")
       if let arrayCustomFields = DBManager.shared.retrieveAllPendingSentCustomFieldBufferObjectsFromCoreData(),  arrayCustomFields.count > 0
        {
            self.isInSyncProgress = true
            let customFieldDispatchGroup = DispatchGroup()
            for fileds in arrayCustomFields {
                
                
                customFieldDispatchGroup.enter()
                
                self.uploadCustomFields(customField: fileds as! Custom_Field_Buffer, pingTime: self.pingTime) { (response, error) in
                    self.handleCommonApiResponse(dispatchGroup: customFieldDispatchGroup, response: response, error: error, obj: fileds, module: .customFields)
                    self.checkStatusAndUpload()
                }
            }
            
            customFieldDispatchGroup.notify(queue: DispatchQueue.main) {
                print("========== CUSTOMFIELDSS SYNC NOTIFY ========")
            }
        }
        else {
            self.checkStatusAndUpload()
        }
    }
    
    
    private func handleCommonApiResponse(dispatchGroup:DispatchGroup, response: Any?,error: String?, obj:Any?,module:CommonResponseModule) {
        DispatchQueue.main.async {
            if error == nil, let apiResp = response as? CommonApiResponse, let success = apiResp.success, success == true {
                
                if let validLogin = apiResp.is_user_logged_in, validLogin == false {
                    self.isSuccess = false
                }
                
                switch module {
                case .notes:
                    print("Notes common api response handling")
                    let notesObject: Service_Order_Notes_Buffer = obj as! Service_Order_Notes_Buffer
                    DBManager.shared.updateSyncFlagInNotesMessage(to: true, withOrderID: Int(truncating: notesObject.orderId!), forTimeStamp: Int(truncating: notesObject.timeStamp!), pendingSent: true, pendingEventTimeStamp: notesObject.pendingEventTimeStamp as! Int64)
                    
                case .documents:
                    print("Documents common api response handling")
                    let docObject: Docs_Images_Buffer = obj as! Docs_Images_Buffer
                    DBManager.shared.updateDocsSyncStatuswithCoreData(orderID: Int(truncating: docObject.orderId!), timeStamp: Int(truncating: docObject.timeStamp!), isImageSynched: true, isPendingSent: true, eventTimeStamp: docObject.pendingEventTimeStamp as! Int64)
                case .pictures:
                    print("Images common api response handling")
                    let imageObject: Service_Order_Image_Buffer = obj as! Service_Order_Image_Buffer
                    DBManager.shared.updateImageSyncStatuswithCoreData(orderID: Int(truncating: imageObject.orderId!), timeStamp: Int(truncating: imageObject.timeStamp!), isImageSynched: true, isPendingSent: true, eventTimeStamp: imageObject.pendingEventTimeStamp as! Int64)
                case .survey:
                    print("Survey common api response handling")
                    let surveyObject: Service_Order_Survey_Buffer = obj as! Service_Order_Survey_Buffer
                    DBManager.shared.updateSurveysStatusinCoreData(orderID: surveyObject.orderId as! Int, isSurveySynch: true, isPendingSent: true, eventTimeStamp: surveyObject.pendingEventTimeStamp as! Int64)
                    
                    if let type = surveyObject.surveyType, type == "Declined" || type == "MailSent" {
                    }
                    else {
                        //Upload signature image
                        if let model = UserDefaults.standard.getLoginModel(), model.enableSignatureOnSurvey == 1 {
                            self.uploadSurveySignature(surveyObject: surveyObject, surveyDispatchGroup: dispatchGroup)
                            return
                        }
                    }
                case .surveySignature:
                    print("Survey Signature common api response handling")
                    let surveyObject: Service_Order_Survey_Buffer = obj as! Service_Order_Survey_Buffer
                    removeImageFromLocalCache(atPath: surveyObject.signaturePath ?? "")
                case .eventStatus:
                    print("Event/Order status common api response handling")
                    let eventObject: Service_Order_Event_Buffer = obj as! Service_Order_Event_Buffer
                    DBManager.shared.updateEventStatusSyncStatuswithCoreData(orderID: Int(truncating: eventObject.orderId!), timeStamp: eventObject.timeStamp as! Int, isEventSynched: true, isPendingSent: true, pendingEventTimeStamp: (eventObject.pendingEventTimeStamp != nil))
                case .orderSignature:
                    print("Order Signature common api response handling")
                    let signObject: Service_Order_Signature_Buffer = obj as! Service_Order_Signature_Buffer
                    DBManager.shared.deleteSignatureBufferObjectFromCoreData(withTimeStamp: signObject.timeStamp as! Int)
                //                            removeImageFromLocalCache(atPath: signObject.signaturePath ?? "")
                case .lineItems:
                    print("Line Items common api response handling")
                    let lineItemObject: Service_Order_Line_Item_Buffer = obj as! Service_Order_Line_Item_Buffer
                    let itemId = apiResp.item_id ?? 0
                    DBManager.shared.updateLineItemBufferObjectSyncStatusInCoreData(withOrderID: lineItemObject.orderIdString!, timeStamp: lineItemObject.timestamp as! Int, synchedState: true, pendingSent: true, pendingEventTimeStamp: lineItemObject.pendingEventTimeStamp as! Int64, itemId: "\(itemId)")
                case .route_EventStatus:
                    print("Route Event Status common api response handling")
                    let routeObj = obj as? Service_Route
                    DBManager.shared.updateServiceRouteSynchStateInCoreData(serviceRouteID: routeObj?.routeId ?? "0", isSynched: true, isPendingSent: false, eventTimeStamp: routeObj?.pendingEventTimeStamp as! Int64)
                case .mandatory_route_EventStatus:
                    print("Mandatory Route Event Status common api response handling")
                    let mandatoryRoteObj = obj as? Mandatory_Route_Buffer
                    self.update_MandatoryRouteTable(routeObject: mandatoryRoteObj, isValid_startLocation: apiResp.route_valid_start_location ?? false, isValid_EndLocation: apiResp.route_valid_finish_location ?? false)
                case .DVIRforms:
                    print("DVIR Form common api response handling")
                    let dvirFormObject: Service_Order_DVIR_Forms_Buffer = obj as! Service_Order_DVIR_Forms_Buffer
                    DBManager.shared.updateDVIRFormsSynchStateInCoreData(withTimeStamp: dvirFormObject.timeStamp as! Int, forFormID: dvirFormObject.formId ?? "", synchStatus: true, pendingSent: true, pendingEventTimeStamp: dvirFormObject.pendingEventTimeStamp as! Int64, formType: dvirFormObject.rowType ?? "")
                    self.dvirFormsUploadNotify()
                    
                case .releaseForms:
                    print("Release Form common api response handling")
                    let formObject: Service_Order_Forms_Buffer = obj as! Service_Order_Forms_Buffer
                    DBManager.shared.updateFormsSynchStateinCoreData(orderID: formObject.orderId as! Int, formid: formObject.id456 as! Int, syncStatus: true, isPendingSent: true, eventTimeStamp: formObject.pendingEventTimeStamp as! Int64)
                case .track:
                    print("Track common api response handling")
                    let trackObject: TrackServiceBuffer = obj as! TrackServiceBuffer
                    DBManager.shared.updateTrackServiceBufferObjectSyncStatusInCoreData(withTimeStamp: trackObject.timeStamp, syncStatus: true, pendingSent: true)
                case .customFields:
                    print("Combined custom field response handling")
                    if let customFieldObject: Custom_Field_Buffer = obj as? Custom_Field_Buffer{
                        DBManager.shared.updateCustomFieldBufferObjectSyncStatusInCoreDatawithTimeStamp(timeStamp: Int(truncating: customFieldObject.timeStamp ?? 0), orderID: "\(customFieldObject.orderId ?? "0")".IntValue, isSynchedWithServer: true)
                    }
                case .line_items_delivered:
                    print("Line Items Sync response handling")
                    if let serviceObject: Service_Order_Services_Buffer = obj as? Service_Order_Services_Buffer{
                        DBManager.shared.updateServicesObjectSyncFlagInCoreData(orderID: serviceObject.orderId ?? 0, timeStamp: serviceObject.timeStamp ?? 0, isSynchedWithServer: true)
                    }
                }
                
            }
            else { self.isSuccess = false }
            
            dispatchGroup.leave()
            print("========== LEAVE ========")
        }
    }
    
}

