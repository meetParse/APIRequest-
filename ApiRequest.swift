//
//  File.swift
//  APIRequest
//
//  Created by SculptSoft on 26/04/18.
//  Copyright © 2018 SculptSoft. All rights reserved.
//

import Foundation
import UIKit

class APIRequest:NSObject{
    
    fileprivate static let baseUrl = "http://ho.varianceinfotech.net/webservices/"
    
    static func doRequestForJson(method:MethodName,queryString:String?,parameters:[String:Any]?,showLoading:Bool = true,returnError:Bool = false,completionHandler:@escaping (Any)->()){
        
        getDataFromServer(method: method, queryString: queryString, parameters: parameters, showLoading: showLoading, returnError: returnError) { (data, error) in
            if let errorFound = error{
                print(errorFound)
            }else{
                do{
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String:AnyObject]{
                            completionHandler(json)
                    }
                }catch let err{
                    print(err.localizedDescription)
                }
            }
        }
    }
    
    static func doRequestForDecodable<T : Decodable>(decodablClass:T.Type,method:MethodName,queryString:String?,parameters:[String:Any]?,showLoading:Bool = true,returnError:Bool = false,completionHandler:@escaping (T?,String?)->()){
        
        getDataFromServer(method: method, queryString: queryString, parameters: parameters, showLoading: showLoading, returnError: returnError) { (data, error) in
            if let errorFound = error{
                completionHandler(nil, errorFound)
            }else if let dataFound = data{
                do{
                    let decodable = try JSONDecoder().decode(decodablClass.self, from: dataFound)
                    completionHandler(decodable, nil)
                }catch let err{
                    print(err.localizedDescription)
                }
            }
        }
        
    }
    
    static func someThingWrong(msg:String = "Something went wrong"){
        print("Someting went wrong")
    }
    
    
    static func getDataFromServer(method:MethodName,queryString:String?,parameters:[String:Any]?,showLoading:Bool = true,multipart:Bool? = false,returnError:Bool = true,completionHandler:@escaping (Data?,String?)->()){
        
        var baseURLString = baseUrl
        
//        if !Reachability.isAvailable(),showLoading {
//            ShowToast.show(toatMessage: String.noInternet())
//            return
//        }
        
        func unknownError(){
            DispatchQueue.main.async{
                if showLoading{
                   // ShowToast.show(toatMessage: String.unknownError())
                }
            }
        }
        if showLoading{
            DispatchQueue.main.async{
               // FVTHud.showHud()
            }
        }
        
        
        if var query = queryString{
            query = query.replacingOccurrences(of: " ", with: "")
            if let first = query.first,first == "/"{
                query = String(query.dropFirst())
            }
            baseURLString += query
        }
        if let url = URL(string: baseURLString){
            
            var request = URLRequest(url: url,timeoutInterval: 60)
            request.httpMethod = method.rawValue
            
           // if multipart == true {
                let bodyData = NSMutableData()
                let tempData = NSMutableData()
                
                let boundary = "---------------------------14737809831466499882746641449" as NSString
                
                let contentType : NSString = "multipart/form-data; boundary=\(boundary)" as NSString
                request.setValue(contentType as String, forHTTPHeaderField: "Content-Type")
                
                
                if parameters != nil{
                    
                    for (keys, values) in parameters! {
                        tempData.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                        tempData.append("Content-Disposition: form-data; name=\"\(keys)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
                        tempData.append("\(values)\r\n".data(using: String.Encoding.utf8)!)
                    }
                    
                    if let data = parameters?["vImage"]{
                        tempData.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                        let timestemp:Int = Int(NSDate().timeIntervalSince1970 * 1000)
                        let ticks = "\(timestemp).jpg"
                        tempData.append("Content-Disposition: form-data; name=\"vImage\"; filename=\"\("\(ticks)")\"\r\n".data(using: String.Encoding.utf8)!)
                        tempData.append("Content-Type: \("jpg")\r\n\r\n".data(using: String.Encoding.utf8)!)
                        tempData.append(data as! Data)
                        tempData.append("\r\n".data(using: String.Encoding.utf8)!)
                        tempData.append("--".appending(boundary.appending("--")).data(using: String.Encoding.utf8)!)
                    }
                    
                    bodyData.append(tempData as Data)
                    request.setValue("\(bodyData.length)", forHTTPHeaderField: "Content-Length")
                    request.httpBody = bodyData as Data
                    
                    
            }
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                DispatchQueue.main.async{
              //      FVTHud.hide()
                }
                if error == nil,data != nil
                {
                    //   print(String(data: data!, encoding: .utf8)!)
                    if let httpStatus = response as? HTTPURLResponse  { // checks http errors
                        if httpStatus.statusCode == 200 {
                            do{
                                if let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String:AnyObject]{
                                    if let status = json["status"] as? String{
                                        if status == "1"{
                                            completionHandler(data, nil)
                                            return
                                        }else if status == "2"{
                                            return
                                        }else{
                                            if let msg = json["msg"] as? String{
                                                 DispatchQueue.main.async{
                                             //   ShowToast.show(toatMessage:msg)
                                                }
                                                 return
                                            }
                                        }
                                    }
                                }
                            }
                            catch{
                                
                            }
                        }else
                        {
                            DispatchQueue.main.async{
                            //    ShowToast.show(toatMessage:"Server issues occured")
                            }
                            return
                        }
                    }
                }
                unknownError()
            })
            task.resume()
        }
    }

}

// PUSH
//let storyboard = UIStoryboard(name: "Main" , bundle: nil)
//let vc = storyboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
//self.navigationController?.pushViewController(vc, animated: true)

//BACK
//self.navigationController?.popViewController(animated: true)


//NORMAL API (WID WEB SERVICE CLASS)

//PRAGMA MARK:- Get-Open Close Count API
//func GetRequestReportGroupByAPI() {
//    let reachability = Reachability()!
//
//    if reachability.connection == .none {
//        showAlertMessage(vc: self, messageStr: "Please Check Your Internet Connection".localiz())
//    }
//    else{
//        let DictData :NSDictionary = ["GroupName":"hotel"]
//        post(params: DictData, url: "Service/GetRequestReportGroupBy") { (succeeded: Bool, Response: NSDictionary) in
//            DispatchQueue.main.async {
//                if(succeeded) {
//
//                    let StrAvail1:NSArray = Response.allKeys as NSArray
//
//                    if StrAvail1 .contains("issuccess"){
//
//                        let LoginStatus = Response["issuccess"] as! Bool
//                        print(Response)
//                        if LoginStatus == true{
//                            print(Response)
//                        }
//                    }
//                }
//            }
//        }
//    }
//}


//FOR NORMAL MODEL CLASS

//import Foundation
//import UIKit
//
//class ApparelModel: NSObject {
//    var name:String?
//    var image:AnyObject?
//    var Code:String?
//    var ObjId:String?
//}


//didload
 //var arrApparelData = [ApparelModel]()

// in API Response
//let vdoProductionData = ApparelModel()
//
//if let objectId = object2.value(forKeyPath: "objectId") as? String {
//    vdoProductionData.ObjId = objectId
//}else{
//    vdoProductionData.ObjId = ""
//}
//
//if let name = object2.value(forKey: "name") as? String {
//    vdoProductionData.name = name
//} else{
//    vdoProductionData.name = ""
//}
//self.arrVdoProdDataModel.append(vdoProductionData)


//PRAGMA MARK:-  Increase Counnt Method
//func countIncreaseMethod() {
//    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reloadTblData), object: nil)
//    self.perform(#selector(self.reloadTblData), with: nil, afterDelay: 2)
//}

//PRAGMA MARK:- reload Tbl Data
//@objc func reloadTblData() {
//    DispatchQueue.main.async {
//        collectionView?.reloadData()
//    }
//}

//https://github.com/soapyigu/Swift-30-Projects

// FavouriteListFeed.self   ---> Model Name
// self.arrRequestData  ---> Array of that Model    (var arrRequestData : FavouriteListFeed?)

//MODEL CLASS
//import uikit
//struct  FavouriteListFeed: Decodable {
//    var data: [FavouriteListModel]
//}
//
//struct FavouriteListModel: Decodable {
//    let vFirstName:String?
//    let vLastName:String?
//    let vImage:String?
//    let vCity:String?
//    let vState:String?
//}

//TBALE VIEW CELL
//cell.FavouriteCellAttribute = arrRequestData?.data[indexPath.row]
//return arrRequestData?.data.count ?? 0

//TBALE VIEW CELL CUSTOM CLASS
//class cellFav:UITableViewCell{
//
//    var FavouriteCellAttribute:FavouriteListModel?{
//        didSet{
//            if let firstName = FavouriteCellAttribute?.vFirstName {
//                lblName.text = "\(firstName)"
//            }else{
//                lblName.text = ""
//            }
//        }
//    }
//}



// TO CALL API

//var params =  [String:AnyObject]()
//params["vLoginToken"] = String.getUserDetails(type: .vLoginToken) as AnyObject
//params["iUserId"] = String.getUserDetails(type: .userId) as AnyObject
//params["index"] = "1" as AnyObject
//params["size"] = pageSize as AnyObject
//
//APIRequest.doRequestForDecodable(decodablClass: FavouriteListFeed.self, method: .POST,queryString: "favoriteServiceProviderList", parameters: params)
//{ (decodable, error) in
//    if let decodableValue = decodable{
//        self.arrRequestData = decodableValue
//        DispatchQueue.main.async{
//            if (self.arrRequestData?.data.count)! > 0{
//                self.tblView.reloadData()
//            }else{
//                self.tblView.showMessageLabel()
//            }
//        }
//    }
//}


enum MethodName:String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}





