//
//  FileUploadManager.swift
//  DTD-iOS
//
//  Created by DISPATCHTRACK on 24/06/19.
//  Copyright © 2019 Dispachtrack. All rights reserved.
//

import Foundation
import UIKit
import CoreServices

extension APIWrapper {
    
    private func createRequest(url:String, parm:Parameters,filePath:String, fileName: String, data: Data, mimeType:String) throws -> URLRequest {
        let parameters = parm  // build your dictionary however appropriate
        
        let boundary = generateBoundaryString()
        
        let url = URL(string: url)!
        
        print(url.absoluteString)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try createBody(with: parameters as! [String : String], filePath: filePath, fileName: fileName, data: data, mimeType: mimeType, boundary: boundary)
        
        return request
    }
    
    private func createBody(with parameters: [String: String],filePath:String, fileName: String, data: Data, mimeType:String , boundary: String) throws -> Data {
        var body = Data()
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
        
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(filePath)\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.append("\r\n")
        
        body.append("--\(boundary)--\r\n")
        return body
    }
   
    private func createRequestForMultipleFiles(url:String, parm:Parameters,filesDict:Parameters) throws -> URLRequest {
        let parameters = parm  // build your dictionary however appropriate
        
        let boundary = generateBoundaryString()
        
        let url = URL(string: url)!
        
        print(url.absoluteString)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try createBodyForMultipleFiles(with: parameters as! [String : String], filesDict: filesDict as! [String : String], boundary: boundary)
        
        return request
    }
    
    
    private func createBodyForMultipleFiles(with parameters: [String: String],filesDict:[String: String] , boundary: String) throws -> Data {
        var body = Data()
        
        let fileName = "image.jpg"
        let mimeType = "image/jpg"
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
        
        for (key, value) in filesDict {
            
            var image: UIImage? = _returnImage(withName: value)
            if image == nil {
                image = returnImage(withName: value)
            }
            let imageData = image?.jpegData(compressionQuality: 0.8) ?? Data()
            
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(fileName)\"\r\n")
            body.append("Content-Type: \(mimeType)\r\n\r\n")
            body.append(imageData)
            body.append("\r\n")
        }
        
        
        
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    
    private func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    private func mimeType(for path: String) -> String {
        let url = URL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    
    private func getBasuURL() -> String{
        if appDelegate.isActivationBaseURL == true {
            return "https://manage.dispatchtrack.com/api/"
        }
        else {
            let url = DBManager.shared.getServerURL()
            if url == "" {
                return "https://manage.dispatchtrack.com/api/"
            }
            else {
                return "https://\(url)/api/"
            }
        }
    }
    
    
    private func fileUploadTask(request: URLRequest,completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            
            if let response = response as? HTTPURLResponse {
                print("=========== Image upload response =========\n" + " StatusCode : \(response.statusCode)" + "===========================================")
                
                if response.statusCode == 200 {
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    let jsonString = String(data: responseData, encoding: String.Encoding.utf8) ?? ""
                    
                    print(jsonString)
                    
                    let apiResponse = CommonApiResponse(JSONString: jsonString)
                    completion(apiResponse, nil)
                    
                    print("============================================")
                }
                else {
                    completion(nil, "Status code not 200")
                }
            }
            else {
                completion(nil, error?.localizedDescription)
            }
        }
        task.resume()
    }
    
    func uploadImageFile(image:Service_Order_Image_Buffer, pingTime: String,completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        
        var parm = ParameterDetail()
        parm.business_code = DBManager.shared.getBusinessCode()
        parm.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        parm.image_title = image.imageName
        parm.order_number = image.orderNumber
        parm.lat = "\(Double(truncating: image.latitude ?? NSNumber(value: 0)))"
        parm.lng = "\(Double(truncating: image.longitude ?? NSNumber(value: 0)))"
        parm.timestamp = "\(Int(truncating: image.timeStamp ?? NSNumber(value: Int(Date().unixString()) ?? 0)))"
        
        parm.ping_TimeStamp = pingTime
        parm.client_version = UserDefaults.standard.getData(key: "VERSION_ID")
        
        var imageData = Data()
        
        if image.imageCacheFileName!.contains(".mp4") {
            imageData = returnVideoData(withName: image.imageCacheFileName ?? "dsndskjdncckdckkj")
        }
        else {
            var imageFile: UIImage? = _returnImage(withName: image.imageCacheFileName ?? "skdckjcdsmnmsdkjddc")
            if imageFile == nil {
                imageFile = returnImage(withName: image.imageCacheFileName!)
            }
            imageData = imageFile?.jpegData(compressionQuality: 0.8) ?? Data()
        }
        
        if imageData.count == 0 {
            completion(nil, "Error: File not able to load properly from local storage")
            return
        }
        
        
        if let yesterDayLogin = UserDefaults.standard.getLoginModel()?.isEnableYesteradyDriverLogin(), yesterDayLogin == true {
            
            parm.internal_login = ""//Modify
        }
        
        if let dict = parm.dictionary {
            
            let url = getBasuURL() + Method.save_image.rawValue
            let filepath = "uploaded_data"
            var fileName = "image.jpg"
            var mimeType = "image/jpg"
            
            if image.imageCacheFileName!.contains(".mp4") {
                fileName = parm.timestamp!
                mimeType = "video/mp4"
            }
            
            let request: URLRequest
            
            do {
                request = try createRequest(url: url, parm: dict, filePath: filepath, fileName: fileName, data: imageData ?? Data(), mimeType: mimeType)
                
               fileUploadTask(request: request, completion: completion)
                
            } catch {
                print(error)
                completion(nil, error.localizedDescription)
            }
       
        } else { completion(nil, "Error: Parameters are not appeneded properly")}
    }
    
    func uploadServeySignatureFile(surveyObj:Service_Order_Survey_Buffer, pingTime: String,completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        
        var parm = ParameterDetail()
        parm.business_code = DBManager.shared.getBusinessCode()
        parm.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        parm.service_order_id = "\(surveyObj.orderId?.intValue ?? 0)"
        parm.lat = "\(Double(truncating: surveyObj.latitude ?? NSNumber(value: 0)))"
        parm.lng = "\(Double(truncating: surveyObj.longitude ?? NSNumber(value: 0)))"
        parm.timestamp = "\(Int(truncating: surveyObj.timeStamp ?? NSNumber(value: Int(Date().unixString()) ?? 0)))"
        
        parm.ping_TimeStamp = pingTime
        parm.client_version = UserDefaults.standard.getData(key: "VERSION_ID")
        
        
        var imageFile: UIImage? = _returnImage(withName: surveyObj.signaturePath!)
        if imageFile == nil {
            imageFile = returnImage(withName: surveyObj.signaturePath!)
        }
        
        let imageData = imageFile?.jpegData(compressionQuality: 0.8)
        
        
        if let yesterDayLogin = UserDefaults.standard.getLoginModel()?.isEnableYesteradyDriverLogin(), yesterDayLogin == true {
            
            parm.internal_login = ""//Modify
        }
        
        if let dict = parm.dictionary {
            
            let url = getBasuURL() + Method.save_survey_signature.rawValue
            let filepath = "uploaded_data"
            let fileName = "image.jpg"
            let mimeType = "image/jpg"
            
            let request: URLRequest
            
            do {
                request = try createRequest(url: url, parm: dict, filePath: filepath, fileName: fileName, data: imageData ?? Data(), mimeType: mimeType)
                
                fileUploadTask(request: request, completion: completion)
                
            } catch {
                print(error)
                completion(nil, error.localizedDescription)
            }            
            
        } else { completion(nil, "Error: Parameters are not appeneded properly")}
    }
    
    func uploadSignatureFile(surveyObj:Service_Order_Signature_Buffer, pingTime: String,completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        
        var parm = ParameterDetail()
        parm.business_code = DBManager.shared.getBusinessCode()
        parm.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        parm.order_number = surveyObj.orderNumber
        parm.signature_name = surveyObj.customerName
        parm.email = surveyObj.customerMail
        parm.lat = "\(Double(truncating: surveyObj.latitude ?? NSNumber(value: 0)))"
        parm.lng = "\(Double(truncating: surveyObj.longitude ?? NSNumber(value: 0)))"
        parm.timestamp = "\(Int(truncating: surveyObj.timeStamp ?? NSNumber(value: Int(Date().unixString()) ?? 0)))"
        parm.sendreceipt = (surveyObj.shouldSendReceipt?.boolValue ?? false) ? "1" : "0"
        parm.ping_TimeStamp = pingTime
        parm.client_version = UserDefaults.standard.getData(key: "VERSION_ID")
        
        
        var imageFile: UIImage? = _returnImage(withName: surveyObj.signaturePath!)
        if imageFile == nil {
            imageFile = returnImage(withName: surveyObj.signaturePath!)
        }
        
        let imageData = imageFile?.jpegData(compressionQuality: 0.8)
        
        
        if let yesterDayLogin = UserDefaults.standard.getLoginModel()?.isEnableYesteradyDriverLogin(), yesterDayLogin == true {
            
            parm.internal_login = ""
        }
        
        if let dict = parm.dictionary {
            
            let url = getBasuURL() + Method.save_signature.rawValue
            let filepath = "uploaded_data"
            let fileName = "image.jpg"
            let mimeType = "image/jpg"
            
            let request: URLRequest
            
            do {
                request = try createRequest(url: url, parm: dict, filePath: filepath, fileName: fileName, data: imageData ?? Data(), mimeType: mimeType)
                
                fileUploadTask(request: request, completion: completion)
                
            } catch {
                print(error)
                completion(nil, error.localizedDescription)
            }
            
        } else { completion(nil, "Error: Parameters are not appeneded properly")}
    }
    
    func uploadDocumentFile(docObj:Docs_Images_Buffer, pingTime: String,completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        
        var parm = ParameterDetail()
        parm.business_code = DBManager.shared.getBusinessCode()
        parm.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        parm.image_title = docObj.docTitle ?? ""
        parm.order_number = docObj.orderNumber
        parm.lat = "\(Double(truncating: docObj.latitude ?? NSNumber(value: 0)))"
        parm.lng = "\(Double(truncating: docObj.longitude ?? NSNumber(value: 0)))"
        parm.timestamp = "\(Int(truncating: docObj.timeStamp ?? NSNumber(value: Int(Date().unixString()) ?? 0)))"
        
        parm.ping_TimeStamp = pingTime
        parm.client_version = UserDefaults.standard.getData(key: "VERSION_ID")
        
        
        var imageFile: UIImage? = _returnImage(withName: docObj.docCacheFileName!)
        if imageFile == nil {
            imageFile = returnImage(withName: docObj.docCacheFileName!)
        }
        
        let imageData = imageFile?.jpegData(compressionQuality: 0.8)
        
        
        if let yesterDayLogin = UserDefaults.standard.getLoginModel()?.isEnableYesteradyDriverLogin(), yesterDayLogin == true {
            
            parm.internal_login = ""
        }
        
        if let dict = parm.dictionary {
            
            let url = getBasuURL() + Method.save_signature.rawValue
            let filepath = "uploaded_data"
            let fileName = "image.jpg"
            let mimeType = "image/jpg"
            
            let request: URLRequest
            
            do {
                request = try createRequest(url: url, parm: dict, filePath: filepath, fileName: fileName, data: imageData ?? Data(), mimeType: mimeType)
                
                fileUploadTask(request: request, completion: completion)
                
            } catch {
                print(error)
                completion(nil, error.localizedDescription)
            }
            
        } else { completion(nil, "Error: Parameters are not appeneded properly")}
    }
    
    func uploadDVIRFile(dvirObj:Service_Order_DVIR_Forms_Buffer, pingTime: String,completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        
        let truckNumber = UserDefaults.standard.getData(key:"TRUCK_NUMBER")
        
        let senderDictionary = NSMutableDictionary()
        senderDictionary.setValue(dvirObj.templateId, forKey: "form_template_id")
        
        let allObj  = convertStringToDictionary(text: dvirObj.allValues!)
        senderDictionary.setValue(allObj, forKey: "values")
        
        let form_submission: String = notPrettyString(from: senderDictionary as Any)!
        
        var filesObj: Parameters = Dictionary<String, Any>()
        var allTimeStamps:NSArray? = NSArray()
        
        if dvirObj.allImagesTimeStamps != nil {
            allTimeStamps =  convertStringToDictionary(text: dvirObj.allImagesTimeStamps!) as? NSArray
            if allTimeStamps == nil {
                let timesStampsArray: NSArray = dvirObj.allImagesTimeStamps?.components(separatedBy: ",") as! NSArray
                
                for i in 0..<timesStampsArray.count{
                    filesObj[timesStampsArray[i] as! String] = timesStampsArray[i]
                }
            }
            else {
                allTimeStamps = (convertStringToDictionary(text: dvirObj.allImagesTimeStamps!) as! NSArray)
                for i in 0..<(allTimeStamps?.count)! {
                    
                    let dic = allTimeStamps![i] as! NSDictionary
                    for (key , value) in dic{
                        filesObj[key as! String] = value
                    }
                }
            }
        }
        
        var parm = ParameterDetail()
        parm.business_code = DBManager.shared.getBusinessCode()
        parm.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        
        parm.form_submission = form_submission
        parm.form_type = dvirObj.rowType ?? ""
        parm.truck_number = truckNumber
        
        parm.ping_TimeStamp = pingTime
        parm.client_version = UserDefaults.standard.getData(key: "VERSION_ID")
    
        
        if let yesterDayLogin = UserDefaults.standard.getLoginModel()?.isEnableYesteradyDriverLogin(), yesterDayLogin == true {
            
            parm.internal_login = ""
        }
        
        if let dict = parm.dictionary {
            
            let url = getBasuURL() + Method.dvir_form_submission.rawValue
            
            let request: URLRequest
            
            do {
                request = try createRequestForMultipleFiles(url: url, parm: dict, filesDict: filesObj)
                
                fileUploadTask(request: request, completion: completion)
                
            } catch {
                print(error)
                completion(nil, error.localizedDescription)
            }
            
        } else { completion(nil, "Error: Parameters are not appeneded properly")}
    }
    
    func uploadReleaseForm(formObj:Service_Order_Forms_Buffer, pingTime: String,completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        
        
        let senderDictionary = NSMutableDictionary()
        senderDictionary.setValue(formObj.form_template_id123!, forKey: "form_template_id")
        
        let allObj  = convertStringToDictionary(text: formObj.allFormFields!)
        senderDictionary.setValue(allObj, forKey: "values")
        
        let form_submission: String = notPrettyString(from: senderDictionary as Any)!
        
        var filesObj: Parameters = Dictionary<String, Any>()
        var allTimeStamps:NSArray? = NSArray()
        
        if formObj.allImagesTimeStamps != nil {
            allTimeStamps =  convertStringToDictionary(text: formObj.allImagesTimeStamps!) as? NSArray
            if allTimeStamps == nil {
                let timesStampsArray: NSArray = formObj.allImagesTimeStamps?.components(separatedBy: ",") as! NSArray
                
                for i in 0..<timesStampsArray.count{
                    filesObj[timesStampsArray[i] as! String] = timesStampsArray[i]
                }
            }
            else {
                allTimeStamps = (convertStringToDictionary(text: formObj.allImagesTimeStamps!) as! NSArray)
                for i in 0..<(allTimeStamps?.count)! {
                    
                    let dic = allTimeStamps![i] as! NSDictionary
                    for (key , value) in dic{
                        filesObj[key as! String] = value
                    }
                }
            }
        }
        
        filesObj["uploaded_data"] = formObj.signaturePath ?? ""
        
        var parm = ParameterDetail()
        parm.business_code = DBManager.shared.getBusinessCode()
        parm.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm.session_id = UserDefaults.standard.getLoginModel()?.sessionId
        
        parm.form_template_id = "\(formObj.form_template_id123?.intValue ?? 0)"
        parm.service_order_id = "\(formObj.orderId?.intValue ?? 0)"
        parm.form_submission = form_submission
        parm.release_form_id = "\(formObj.id456?.intValue ?? 0)"
        
        parm.lat = "\(Double(truncating: formObj.latitude ?? NSNumber(value: 0)))"
        parm.lng = "\(Double(truncating: formObj.longitude ?? NSNumber(value: 0)))"
        parm.timestamp = "\(Int(truncating: formObj.timeStamp ?? NSNumber(value: Int(Date().unixString()) ?? 0)))"
        parm.ping_TimeStamp = pingTime
        parm.client_version = UserDefaults.standard.getData(key: "VERSION_ID")
        
        
        if let yesterDayLogin = UserDefaults.standard.getLoginModel()?.isEnableYesteradyDriverLogin(), yesterDayLogin == true {
            
            parm.internal_login = ""
        }
        
        if let dict = parm.dictionary {
            
            let url = getBasuURL() + Method.submit_release_forms.rawValue
            
            let request: URLRequest
            
            do {
                request = try createRequestForMultipleFiles(url: url, parm: dict, filesDict: filesObj)
                
                fileUploadTask(request: request, completion: completion)
                
            } catch {
                print(error)
                completion(nil, error.localizedDescription)
            }
            
        } else { completion(nil, "Error: Parameters are not appeneded properly")}
    }
    
    func uploadDriverSignature(signImage: UIImage,completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        
        var parm = ParameterDetail()
        parm.business_code = DBManager.shared.getBusinessCode()
        parm.login = UserDefaults.standard.getData(key: LOGIN_USERNAME)
        parm.session_id = UserDefaults.standard.getLoginModel()?.sessionId

        parm.lat = "\(AppController.shared.delegate().userLatitude)"
        parm.lng = "\(AppController.shared.delegate().userLongitude)"
        parm.timestamp = Date().unixString()
    
        parm.client_version = UserDefaults.standard.getData(key: "VERSION_ID")
        
        let imageData = signImage.jpegData(compressionQuality: 0.8)
        
        if let dict = parm.dictionary {
            
            let url = getBasuURL() + Method.save_driver_signature.rawValue
            let filepath = "uploaded_data"
            let fileName = "image.jpg"
            let mimeType = "image/jpg"
            
            let request: URLRequest
            
            do {
                request = try createRequest(url: url, parm: dict, filePath: filepath, fileName: fileName, data: imageData ?? Data(), mimeType: mimeType)
                
                fileUploadTask(request: request, completion: completion)
                
            } catch {
                print(error)
                completion(nil, error.localizedDescription)
            }
            
        } else { completion(nil, "Error: Parameters are not appeneded properly")}
    }
    
}

extension Data {
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}
