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
 * Purpose: CHANGE ME
 *
 * SER 423
 * see http://quay.poly.asu.edu/Mobile/
 * @author Anton Neuhold mailto:aneuhold@asu.edu
 *         Software Engineering
 * @version October 20, 2019
 */
class PlaceDescription {
  var name: String?
  var description: String?
  var category: String?
  var addressTitle: String?
  var addressStreet: String?
  var elevation: Double?
  var latitude: Double?
  var longitude: Double?
  
  convenience init (jsonStr: String) {
    if let data: Data = jsonStr.data(using: String.Encoding.utf8){
      do{
        let dict = try JSONSerialization.jsonObject(with: data,options:.mutableContainers) as?[String:Any]
        self.init(jsonObjDict: dict)
      } catch {
        print("unable to convert to dictionary")
      }
    }
  }
  
  /**
   Initialize the PlaceDescription object with a provided dictionary which is
   an already parsed JSON Object of the correct format.
   */
  init (jsonObjDict dict: [String:Any]?) {
    self.name = (dict!["name"] as? String)!
    self.description = (dict!["description"] as? String)!
    self.category = (dict!["category"] as? String)!
    self.addressTitle = (dict!["address-title"] as? String)!
    self.addressStreet = (dict!["address-street"] as? String)!
    self.elevation = (dict!["elevation"] as? Double)!
    self.latitude = (dict!["latitude"] as? Double)!
    self.longitude = (dict!["longitude"] as? Double)!
  }
  
  func toJsonString() -> String {
    var jsonStr = "";
    let dict:[String:Any] = [
      "name": name as Any,
      "description": description as Any,
      "category": category as Any,
      "address-title": addressTitle as Any,
      "address-street": addressStreet as Any,
      "elevation": elevation as Any,
      "latitude": latitude as Any,
      "longitude": longitude as Any,
    ] as [String : Any]
    do {
      let jsonData:Data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
      // here "jsonData" is the dictionary encoded in JSON data
      jsonStr = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
    } catch let error as NSError {
      print(error)
    }
    return jsonStr
  }
}
