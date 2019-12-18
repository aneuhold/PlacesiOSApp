import UIKit
import MapKit

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
 * Purpose: The main controller for the map interface.
 *
 * SER 423
 * see http://quay.poly.asu.edu/Mobile/
 * @author Anton Neuhold mailto:aneuhold@asu.edu
 *         Software Engineering
 * @version November 27, 2019
 */
class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
  let regionRadius: CLLocationDistance = 50000 // roughly 30 miles
  
  var newTitle:String = ""
  var newDescription:String = ""
  var placeCoreData: PlaceCoreData? 
  var viewController: ViewController?
  
  @IBOutlet weak var mapView: MKMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Get a reference to the top level view controller
    viewController = tabBarController as? ViewController
    
    // Get the placeCoreData reference
    placeCoreData = viewController?.placeCoreData
    
    // Center the map if there is a location
    if ((placeCoreData?.placeAnnotations.count)! > 0) {
      let coordinate = placeCoreData?.placeAnnotations[0].coordinate
      let newCoordinate = CLLocation(latitude: (coordinate?.latitude)!, longitude: (coordinate?.longitude)!)
      centerMapOnLocation(location: newCoordinate)
    }
    
    // Put pins on the map for all places in the library
    for placeAnnotation in (placeCoreData?.placeAnnotations)! {
      mapView.addAnnotation(placeAnnotation)
    }
    
    // Add the reference to the mapView in Core Data
    placeCoreData?.mapView = self.mapView
    
    // Set up a long tap for dropping a new pin, and adding a new annotation (lat/lon)
    let longTap: UILongPressGestureRecognizer = UILongPressGestureRecognizer(
      target: self,
      action: #selector(didLongTapMap(gestureRecognizer:)))
    longTap.delegate = self
    longTap.minimumPressDuration = 2.0
    mapView.addGestureRecognizer(longTap)
    
  }
  
  @objc func didLongTapMap(gestureRecognizer: UIGestureRecognizer) {

    // is this the beginning? otherwise it'll execute twice begin and end
    if gestureRecognizer.state == UIGestureRecognizer.State.began {
      
      // Get the location that was tapped.
      let tapPoint: CGPoint = gestureRecognizer.location(in: mapView)
      let touchMapCoordinate: CLLocationCoordinate2D = mapView.convert(tapPoint, toCoordinateFrom: mapView)
      
      // query the user for new place title and description
      let promptND = UIAlertController(title: "New Place", message: "Enter Title & Description", preferredStyle: UIAlertController.Style.alert)
      // if the user cancels, we don't want to add an annotation or pin
      promptND.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
      // setup the OK action and the closure to be executed when/if OK selected
      promptND.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) -> Void in
        let newPlaceDescription: PlaceDescription = PlaceDescription()
        newPlaceDescription.name = (promptND.textFields?[0].text)!
        newPlaceDescription.description = (promptND.textFields?[1].text)!
        newPlaceDescription.latitude = touchMapCoordinate.latitude
        newPlaceDescription.longitude = touchMapCoordinate.longitude
        self.placeCoreData?.addPlace(newPlaceDescription: newPlaceDescription)
      }))
      promptND.addTextField(configurationHandler: {(textField: UITextField!) in
        textField.placeholder = "Title"
      })
      promptND.addTextField(configurationHandler: {(textField: UITextField!) in
        textField.placeholder = "Description"
      })
      present(promptND, animated: true, completion: nil)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func centerMapOnLocation(location: CLLocation) {
    let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate,
                                                   latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
    mapView.setRegion(coordinateRegion, animated: true)
  }
  
  // MKMapViewDelegate method, similar to tableview viewFor method that returns view for table rows,
  // this method returns a view for the selected pin.
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    var view:MKPinAnnotationView? = nil
    if let annotation = annotation as? PlaceAnnotation {
      let identifier = "pin"
      if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        as? MKPinAnnotationView {
        dequeuedView.annotation = annotation
        view = dequeuedView
      } else {
        view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        view?.canShowCallout = true
        view?.calloutOffset = CGPoint(x: -5, y: 5)
        view?.rightCalloutAccessoryView = UIButton(type:UIButton.ButtonType.detailDisclosure)
      }
    }
    return view
  }
}
