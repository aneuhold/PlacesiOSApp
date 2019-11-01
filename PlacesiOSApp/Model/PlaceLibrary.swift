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
 * Purpose: Extracts place dat from the places.json file held locally. Maybe.
 *
 * SER 423 see http://quay.poly.asu.edu/Mobile/
 * @author Anton Neuhold mailto:aneuhold@asu.edu
 *         Software Engineering
 * @version October 30, 2019
 */
class PlaceLibrary {
  private var placeDescriptions: [PlaceDescription] = [PlaceDescription]()
  
  init() {
    
    // Construct the places dictionary from the json file containing places
    if let path = Bundle.main.path(forResource: "places", ofType: "json"){
      do {
        let jsonStr:String = try String(contentsOfFile:path)
        let data:Data = jsonStr.data(using: String.Encoding.utf8)!
        let jsonObjDict:[String:Any] = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any]
        
        // Access the place array within the root object
        if let jsonObjArray = jsonObjDict["placeArray"] as? [Any] {
          
          // Access each value of the array and convert them to entries of
          // Place Description objects
          for obj in jsonObjArray {
            
            // Test that the contained object is a JSON object
            if let placeDescriptionObj = obj as? [String: Any] {
              
              // Assign the contained object to a new Place Description object
              placeDescriptions.append(PlaceDescription(jsonObjDict: placeDescriptionObj))
            }
          }
        }
      } catch {
        print("Contents of places.json could not be loaded")
      }
    }
  }
  
  func getPlaceAt(_ index: Int) -> PlaceDescription {
    return placeDescriptions[index]
  }
  
  func size() -> Int {
    return placeDescriptions.count;
  }
}
