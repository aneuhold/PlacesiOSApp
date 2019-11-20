import Foundation

/**
 * Copyright 2019 Anton G Neuhold Jr,
 *
 * This software is the intellectual property of the author, and can not be
 * distributed, used, copied, or reproduced, in whole or in part, for any
 * purpose, commercial or otherwise. The author grants the ASU Software
 * Engineering program the right to copy, execute, and evaluate this work for
 * the purpose of determining performance of the author in coursework, and for
 * Software Engineering program evaluation, so long as this copyright and
 * right-to-use statement is kept in-tact in such use. All other uses are
 * prohibited and reserved to the author.<br>
 * <br>
 *
 * Purpose: To retrieve data from a remote JSON RPC server that contains
 * information on the different places stored. The different methods available
 * are below:
 *
 * - get
 * -- params should be a [String] type with one String which is the name of the place.
 * - add
 * - getNames
 * -- params should be a new [] with nothing in it
 * - resetFromJsonFile
 * - saveToJsonFile
 * - remove
 * -- params should be a [String] type with one String which is the name of the place.
 * - getCategoryNames
 * - getNamesInCategory
 *
 * SER 423 see http://quay.poly.asu.edu/Mobile/
 * @author Anton Neuhold mailto:aneuhold@asu.edu
 *         Software Engineering
 * @version November 10, 2019
 */
public class PlaceLibraryStub {
  
  static var id:Int = 0
  
  var url:String
  
  init(urlString: String){
    self.url = urlString
  }
  
  // used by methods below to send a request asynchronously.
  // creates and posts a URLRequest that attaches a JSONRPC request as a Data object. The URL session
  // executes in the background and calls its completion handler when the result is available.
  func asyncHttpPostJSON(url: String,  data: Data,
                         completion: @escaping (String, String?) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
    request.httpMethod = "POST"
    request.addValue("application/json",forHTTPHeaderField: "Content-Type")
    request.addValue("application/json",forHTTPHeaderField: "Accept")
    request.httpBody = data
    httpSendRequest(request: request, callback: completion)
  }
  
  // sendHttpRequest
  func httpSendRequest(request: NSMutableURLRequest,
                       callback: @escaping (String, String?) -> Void) {
    // task.resume() below, causes the shared session http request to be posted in the background
    // (independent of the UI Thread)
    // the use of the DispatchQueue.main.async causes the callback to occur on the main queue --
    // where the UI can be altered, and it occurs after the result of the post is received.
    let task = URLSession.shared.dataTask(with: request as URLRequest) {
      (data, response, error) -> Void in
      if (error != nil) {
        print("There was an error in the httpSendRequest method")
        callback("", error!.localizedDescription)
      } else {
        DispatchQueue.main.async(execute: {callback(NSString(data: data!,
                                                             encoding: String.Encoding.utf8.rawValue)! as String, nil)})
      }
    }
    task.resume()
  }
  
  private func prepareAsyncHttpPostJSON(params: [Any], methodName: String,
                                callback:@escaping (String, String?) -> Void) -> Bool {
    var ret:Bool = false
    PlaceLibraryStub.id = PlaceLibraryStub.id + 1
    do {
      let dict:[String:Any] = ["jsonrpc":"2.0", "method":methodName, "params":params, "id":PlaceLibraryStub.id]
      let reqData:Data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions(rawValue: 0))
      self.asyncHttpPostJSON(url:self.url, data:reqData, completion:callback)
      ret = true
    } catch let error as NSError {
      print(error)
    }
    return ret
  }
  
  func get(name: String, callback:@escaping (String, String?) -> Void) -> Bool{
    return prepareAsyncHttpPostJSON(params: [name], methodName: "get", callback: callback)
  }
  
  func getNames(callback:@escaping(String, String?) -> Void) -> Bool{
    return prepareAsyncHttpPostJSON(params: [], methodName: "getNames", callback: callback)
  }
  
  func add(placeDescription: PlaceDescription, callback:@escaping(String, String?) -> Void) -> Bool {
    return prepareAsyncHttpPostJSON(params: [placeDescription.toJsonObj()], methodName: "add", callback: callback)
  }
  
  func remove(name: String, callback:@escaping (String, String?) -> Void) -> Bool{
    return prepareAsyncHttpPostJSON(params: [name], methodName: "remove", callback: callback)
  }
  
  // callbacks to getNames remote method may use this method to get the array of strings from the jsonrpc result string
  func getStringArrayResult(jsonRPCResult:String) -> [String] {
    var ret:[String] = [String]()
    if let data:NSData = jsonRPCResult.data(using:String.Encoding.utf8) as NSData?{
      do{
        let dict = try JSONSerialization.jsonObject(with: data as Data,options:.mutableContainers) as?[String:AnyObject]
        let resArr:[String] = dict?["result"] as! [String]
        ret = resArr
      } catch {
        print("unable to convert Json to a dictionary")
      }
    }
    return ret
  }
  
  // callbacks to get remote method may use this method to get the PlaceDescription from the jsonrpc result string
  func getPlaceDescriptionResult(jsonRPCResult:String) -> PlaceDescription {
    var ret:PlaceDescription = PlaceDescription()
    if let data:NSData = jsonRPCResult.data(using:String.Encoding.utf8) as NSData?{
      do{
        let dict = try JSONSerialization.jsonObject(with: data as Data,options:.mutableContainers) as?[String:AnyObject]
        let aPlace:PlaceDescription = PlaceDescription(jsonObjDict: dict?["result"] as? [String:Any])
        ret = aPlace
      } catch {
        print("unable to convert Json to a dictionary")
      }
    }
    return ret
  }
  
}
