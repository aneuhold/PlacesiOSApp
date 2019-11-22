import UIKit
import MapKit
import CoreData

/*
 * Copyright 2017 Tim Lindquist,
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Purpose: Example iOS app showing the use of MapKit. MKMapView comes pretty
 * complete out of the box with facilities to draw maps, zoom, and drag.
 * See the Class reference for the many options of what to show on the map.
 * This example shows how to annotate a map with pins. The app includes
 * an implementation of MKAnnotation that is consistent with "Places", and
 * a collection of PlaceAnnotations for adding and removing places.
 * What to look for?
 * 1. Setting the mapview in storyboard (note constraints to fill view)
 * 2. IB outlet for the mapView
 * 3. PlaceAnnotation implements a protocol, and provides property getters
 * 4. method mapView viewForAnnotation, which is similar to providing views
 *    for rows of a table view
 * 5. Creating and associating a gesture recognizer (here long presses) with
 *    the mapView.
 * 6. In the delegate for long presses, an example of using an alert controller
 *    with associated textfields.
 *
 * Ser423 Mobile Applications
 * see http://pooh.poly.asu.edu/Mobile
 * @author Tim Lindquist Tim.Lindquist@asu.edu
 *         Software Engineering, CIDSE, IAFSE, ASU Poly
 * @version February 2017
 *
 * ------------------------------------
 *
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
 * @version November 17, 2019
 */
class PlaceAnnotation: NSObject, MKAnnotation {
  let name:String
  var desc:String
  var coordinate:CLLocationCoordinate2D
  
  init(name: String, description: String, latitude: Double, longitude: Double) {
    self.name = name
    self.desc = description
    self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    super.init()
  }
  
  override init(){
    self.name = "unknown"
    self.desc = "unknown"
    self.coordinate = CLLocationCoordinate2D(latitude:0.0, longitude: 0.0)
    super.init()
  }
  
  init(name:String, desc:String, location:CLLocationCoordinate2D) {
    self.name = name
    self.desc = desc
    self.coordinate = location
    super.init()
  }
  
  // so the title and subtitle are able to be picked up for the annotation
  var title: String? {
    return self.name
  }
  
  var subtitle: String? {
    return self.desc
  }
  
}
