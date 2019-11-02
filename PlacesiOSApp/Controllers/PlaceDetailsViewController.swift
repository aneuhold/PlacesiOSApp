import UIKit

class PlaceDetailsViewController: UIViewController {
  var placeDescription: PlaceDescription?
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
    
    hydratePlaceDescriptionViews()

    // TODO: Do something about the keyboard hiding the content
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
}
