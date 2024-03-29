import UIKit
import CoreData

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
 * Purpose: Provides the view controller for a specific place's details screen.
 * This information is populated from Core Data.
 *
 * SER 423
 * see http://quay.poly.asu.edu/Mobile/
 * @author Anton Neuhold mailto:aneuhold@asu.edu
 *         Software Engineering
 * @version November 17, 2019
 */
class PlaceDetailsViewController: UIViewController {
  var place: NSManagedObject?
  var viewController: ViewController?
  var placeCoreData: PlaceCoreData?
  var placeDescription: PlaceDescription?
  var placeIndex: Int?
  
  @IBOutlet weak var placeNameTextField: UITextField!
  @IBOutlet weak var placeDescriptionTextField: UITextField!
  @IBOutlet weak var placeCategoryTextField: UITextField!
  @IBOutlet weak var placeAddressTitleTextField: UITextField!
  @IBOutlet weak var placeAddressStreetTextField: UITextField!
  @IBOutlet weak var placeElevationTextField: UITextField!
  @IBOutlet weak var placeLatitudeTextField: UITextField!
  @IBOutlet weak var placeLongitudeTextField: UITextField!
  @IBOutlet weak var scrollView: UIScrollView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Create a reference to the main view controller. For Data!
    viewController = tabBarController as? ViewController
    placeCoreData = viewController?.placeCoreData!
    
    hydratePlaceDescriptionViews()

    // Do something about the keyboard hiding the content
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard),
                                   name: UIResponder.keyboardWillHideNotification,
                                   object: nil)
    notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard),
                                   name: UIResponder.keyboardWillChangeFrameNotification,
                                   object: nil)
  }
  
  @objc func adjustForKeyboard(notification: Notification) {
    guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
    
    let keyboardScreenEndFrame = keyboardValue.cgRectValue
    let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
    
    if notification.name == UIResponder.keyboardWillHideNotification {
      scrollView.contentInset = .zero
    } else {
      scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
    }
    
    scrollView.scrollIndicatorInsets = scrollView.contentInset
  }
  
  private func hydratePlaceDescriptionViews() {
    placeNameTextField.text = placeDescription?.name
    placeDescriptionTextField.text = placeDescription?.description
    placeCategoryTextField.text = placeDescription?.category
    placeAddressTitleTextField.text = placeDescription?.addressTitle
    placeAddressStreetTextField.text = placeDescription?.addressStreet
    placeElevationTextField.text = String(format: "%f",(placeDescription?.elevation)!)
    placeLatitudeTextField.text = String(format: "%f",(placeDescription?.latitude)!)
    placeLongitudeTextField.text = String(format: "%f",(placeDescription?.longitude)!)
  }
  
  @IBAction func onDonePress(_ sender: UIButton) {
    
    // Set all of the PlaceDescription values
    placeDescription?.description = placeDescriptionTextField.text
    placeDescription?.category = placeCategoryTextField.text
    placeDescription?.addressTitle = placeAddressTitleTextField.text
    placeDescription?.addressStreet = placeAddressStreetTextField.text
    placeDescription?.elevation = (placeElevationTextField.text! as NSString).doubleValue
    placeDescription?.latitude = (placeLatitudeTextField.text! as NSString).doubleValue
    placeDescription?.longitude = (placeLongitudeTextField.text! as NSString).doubleValue

    // Save the information to Core Data
    placeCoreData!.setPlaceAt(placeIndex!, newPlaceDescription: placeDescription!)
    
    // Dismiss this view controller
    self.navigationController?.popViewController(animated: true)
  }
  
}
