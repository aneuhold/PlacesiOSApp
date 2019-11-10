import UIKit
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
 * Purpose: Provides the view controller for the distance calculator. As the
 * user changes the starting and ending location, the distance and bearing will
 * be updated accordingly. 
 *
 * SER 423
 * see http://quay.poly.asu.edu/Mobile/
 * @author Anton Neuhold mailto:aneuhold@asu.edu
 *         Software Engineering
 * @version November 10, 2019
 */
class DistanceCalcViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate {
  
  var viewController: ViewController?
  @IBOutlet weak var pickerView: UIPickerView!
  @IBOutlet weak var startingLocationTextField: UITextField!
  @IBOutlet weak var endingLocationTextField: UITextField!
  @IBOutlet weak var bearingTextView: UILabel!
  @IBOutlet weak var distanceTextView: UILabel!
  let EARTH_AVG_RADIUS_MILES: Double = 3958.8
  var currentlySelectedTextField: UITextField!
  var distance: Double = 0
  var bearing: Double = 0
  var startPlace: PlaceDescription = PlaceDescription()
  var endPlace: PlaceDescription = PlaceDescription()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Get a reference to the top level view controller
    viewController = tabBarController as? ViewController
    
    // Set delegates
    startingLocationTextField.delegate = self
    endingLocationTextField.delegate = self
    pickerView.dataSource = viewController
    pickerView.delegate = self
    
    // Setting inital distance and bearing values
    distanceTextView.text = "\(distance)mi"
    bearingTextView.text = "\(bearing)°"
  }
  
  func getStartPlaceDescription() {
    let placesConnect: PlaceLibraryStub = PlaceLibraryStub(urlString: viewController!.urlString)
    let _:Bool = placesConnect.get(name: startingLocationTextField.text!, callback: {(res: String, err: String?) -> Void in
      if err != nil {
        NSLog(err!)
      } else {
        NSLog(res)
        if let data: Data = res.data(using: String.Encoding.utf8){
          do{
            let dict = try JSONSerialization.jsonObject(with: data,options:.mutableContainers) as?[String:AnyObject]
            let aDict:[String:AnyObject] = (dict!["result"] as? [String:AnyObject])!
            self.startPlace = PlaceDescription(jsonObjDict: aDict)
            self.recalculate()
          } catch {
            print("unable to convert to dictionary when getting Start Place Description")
          }
        }
      }
    })
  }
  
  func getEndPlaceDescription() {
    let placesConnect: PlaceLibraryStub = PlaceLibraryStub(urlString: viewController!.urlString)
    let _:Bool = placesConnect.get(name: endingLocationTextField.text!, callback: {(res: String, err: String?) -> Void in
      if err != nil {
        NSLog(err!)
      } else {
        NSLog(res)
        if let data: Data = res.data(using: String.Encoding.utf8){
          do{
            let dict = try JSONSerialization.jsonObject(with: data,options:.mutableContainers) as?[String:AnyObject]
            let aDict:[String:AnyObject] = (dict!["result"] as? [String:AnyObject])!
            self.endPlace = PlaceDescription(jsonObjDict: aDict)
            self.recalculate()
          } catch {
            print("unable to convert to dictionary when getting End Place Description")
          }
        }
      }
    })
  }
  
  private func recalculate() {
    
    // Calculate the new distance
    let newDistance: Double = calculateDistance(lat1Dec: startPlace.latitude!,
                                                lon1Dec: startPlace.longitude!,
                                                lat2Dec: endPlace.latitude!,
                                                lon2Dec: endPlace.longitude!)
    distanceTextView.text = "\(newDistance)mi"
    
    // Calculate the new bearing
    let newBearing: Double = calculateBearingInDegrees(lat1Dec: startPlace.latitude!,
                                                       lon1Dec: startPlace.longitude!,
                                                       lat2Dec: endPlace.latitude!,
                                                       lon2Dec: endPlace.longitude!)
    bearingTextView.text = "\(newBearing)°"
  }
  
  private func calculateDistance(lat1Dec: Double, lon1Dec: Double,
                                 lat2Dec: Double, lon2Dec: Double) -> Double {
    
    // Convert input to radians
    let lat1Rad:Double = deg2rad(lat1Dec)
    let lon1Rad:Double = deg2rad(lon1Dec)
    let lat2Rad:Double = deg2rad(lat2Dec)
    let lon2Rad:Double = deg2rad(lon2Dec)
    
    let r: Double = EARTH_AVG_RADIUS_MILES
    
    // Haversine formula - https://en.wikipedia.org/wiki/Haversine_formula
    let result: Double = 2 * r * asin(sqrt(
      pow(sin((lat2Rad - lat1Rad) / 2), 2)
        + cos(lat1Rad)
        * cos(lat2Rad)
        * pow(sin((lon2Rad - lon1Rad) / 2), 2)
    ));
    
    return result;
  }
  
  private func calculateBearingInDegrees(lat1Dec: Double, lon1Dec: Double,
                                         lat2Dec: Double, lon2Dec: Double) -> Double {
    // Convert input to radians
    let lat1Rad:Double = deg2rad(lat1Dec)
    let lon1Rad:Double = deg2rad(lon1Dec)
    let lat2Rad:Double = deg2rad(lat2Dec)
    let lon2Rad:Double = deg2rad(lon2Dec)
    
    // Formula retrieved from http://www.movable-type.co.uk/scripts/latlong.html
    var result: Double = atan2(sin(lon2Rad - lon1Rad) * cos(lat2Rad),
                               cos(lat1Rad) * sin(lat2Rad)
                                - sin(lat1Rad) * cos(lat2Rad)
                                * cos(lon2Rad - lon1Rad));
    
    // Convert to degrees. It starts out somewhere between -180 and +180
    result = remainder(rad2deg(result) + 360, 360)
    return result;
  }
  
  func deg2rad(_ number: Double) -> Double {
    return number * .pi / 180
  }
  
  func rad2deg(_ number: Double) -> Double {
    return number * 180 / .pi
  }
  
  // MARK: - UIPickerViewDelegate methods
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    self.view.endEditing(true)
    return viewController?.placeNames[row]
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    currentlySelectedTextField.text = viewController?.placeNames[row]
    pickerView.isHidden = true
    
    if (currentlySelectedTextField == startingLocationTextField) {
      getStartPlaceDescription()
    } else if (currentlySelectedTextField == endingLocationTextField) {
      getEndPlaceDescription()
    }
  }
  
  // MARK: - UITextFieldDelegate methods
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField == startingLocationTextField {
      currentlySelectedTextField = startingLocationTextField
      pickerView.isHidden = false
      textField.endEditing(true)
    } else if (textField == endingLocationTextField) {
      currentlySelectedTextField = endingLocationTextField
      pickerView.isHidden = false
      textField.endEditing(true)
    }
  }
  
  
}


