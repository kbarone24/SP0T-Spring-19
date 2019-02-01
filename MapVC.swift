//
//  MainVC.swift
//  SP0T
//
//  Created by kbarone on 7/2/18.
//  Copyright © 2018 Spot LLC. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import Firebase
import GeoFire
import AssetsLibrary


 //need to save privacy settings to user
 class MapVC: UIViewController, CLLocationManagerDelegate {
 
 @IBOutlet weak var createSpotInstruction: UILabel!
 
 @IBOutlet weak var mapView: MKMapView!
 
 @IBOutlet weak var createSpotAtLocation: UIButton!
 
 @IBAction func unwindToMap(_ sender: UIStoryboardSegue){}
 
 @IBOutlet weak var createSpotButton: UIButton!
 
 @IBOutlet weak var centerButton: UIButton!
 
 var newSpotLocation = CLLocation()
 
 var createSpotTapped = false

 var authRef = DatabaseReference();
 
 //var authStatus = 2
 
 var userFoundSpots = Array<String>()

    
 
 let uid = Auth.auth().currentUser?.uid
 
 let infoButton = UIButton(type: .detailDisclosure)
 
 var currentSpotID = String()
 
 var localSpots = [[String:Int]]()
 
 
 // if they hit the create spot tap, this removes all of the spot icons and
 // presents the message to drag and drop a spot on the map
 // the functionality for adding a spot to the map will be pretty similar
 // This is probably one of the things that works best of the code that I wrote
    
 @IBAction func createSpotTap(_ sender: UILongPressGestureRecognizer) {
 if (createSpotTapped == false) {
 return
 } else {
 let location = sender.location(in: self.mapView)
 let locationCoordinate = self.mapView.convert(location, toCoordinateFrom: self.mapView)
 let annotation = MKPointAnnotation()
 annotation.coordinate = locationCoordinate
 
 newSpotLocation = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
 
 createSpotInstruction.isHidden = true
 self.mapView.removeAnnotations(mapView.annotations)
 self.mapView.addAnnotation(annotation)
 self.createSpotAtLocation.isHidden = false
 
 }
 }
 
 @IBAction func createSpot(_ sender: Any) {
 self.createSpotButton.isHidden = true
 self.centerButton.isHidden = true
 self.createSpotInstruction.isHidden = false
 createSpotTapped = true
 
 }
 
 var locationManager = CLLocationManager()
 
//This sets up the map when the user clicks the button that brings them back to their current location
//mapRegion.span sets how zoomed in the map is
 @IBAction func snapToLocation(_ sender: Any) {
 
 var mapRegion = MKCoordinateRegion()
 mapRegion.center = mapView.userLocation.coordinate
 mapRegion.span.latitudeDelta = 0.035
 mapRegion.span.longitudeDelta = 0.035
 mapView.setRegion(mapRegion, animated: true)
 
 }
 
 
 
 override func viewDidLoad() {
 super.viewDidLoad()
 authRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("foundSpotIDs");
    }
 override func viewWillAppear(_ animated: Bool) {
 self.setUpTabBar()
 self.createSpotInstruction.layer.masksToBounds = true
 self.createSpotInstruction.layer.cornerRadius = 10.0
 self.createSpotInstruction.isHidden = true
 self.createSpotAtLocation.layer.cornerRadius = 10.0
 self.createSpotAtLocation.isHidden = true
 self.mapView.mapType = .standard
 self.mapView.showsCompass = true
 self.mapView.delegate = self
 self.setUpNavBar()
 
 self.locationManager.delegate = self
 self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
 self.locationManager.requestWhenInUseAuthorization()
 self.locationManager.startUpdatingLocation()
 
 }
 
 func setUpTabBar() {
 Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
 if let dictionary = snapshot.value as? [String: AnyObject] {
 if (dictionary["profileImageURL"] != nil) {
 //   let tempURL = dictionary["profileImageURL"]
 let ref = Storage.storage().reference(forURL: "gs://spot69420.appspot.com").child("profilePic").child(self.uid!)
 
 //we can download the url with a reference to the users UID from storage
 print(ref)
 ref.downloadURL(completion: { (url, error) in
 if error != nil {
 print(error?.localizedDescription as Any)
 return
 }
 URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
 if error != nil {
 print(error as Any)
 return
 }
 
 guard let imageData = UIImage(data: data!) else { return }
 //  let profileItem = self.tabBarItem
 
 //I've had a lot of trouble working with asynchronous tasks and Firebase so this all might be a little sloppy
 //This sets the users profile image to the middle tab bar item- the task currently completes very late and it takes
 //5 seconds or so for the profile image to show up
DispatchQueue.main.async {
 print(imageData)
 print("tabImage")
 let tempTabImage = imageData.circularImage(size:  CGSize(width: 40.0, height: 40.0))
 let newTabImage = tempTabImage.roundedWithBorder(width: 1.0, color: UIColor.white)
 let selectedTabImage = tempTabImage.roundedWithBorder(width: 1.0, color: UIColor.init(red: 99/255, green: 229/255, blue: 205/255, alpha: 1.0))
 //self.resizeImage(image: imageData, targetSize: CGSize(width: 50.0, height: 50.0))
 
 self.tabBarController?.tabBar.items![1].image = newTabImage?.withRenderingMode(.alwaysOriginal)
 self.tabBarController?.tabBar.items![1].selectedImage = selectedTabImage?.withRenderingMode(.alwaysOriginal)
 }
 }).resume()
 })
 }
 }
 })
 }
 
 func setUpNavBar() {
 //add where search results will show up
 
 // set spot logo to be the title of the nav bar
 let navController = navigationController!
 
 let banner = #imageLiteral(resourceName: "banner")
 let imageView = UIImageView(image:banner)
 
 let bannerWidth = navController.navigationBar.frame.size.width / 1.75
 let bannerHeight = navController.navigationBar.frame.size.height / 1.75
 
 let bannerX = bannerWidth  / 2 - banner.size.width / 2
 let bannerY = bannerHeight / 2 - banner.size.height / 2
 
 imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
 imageView.contentMode = .scaleAspectFit
 
 self.navigationItem.titleView = imageView
 
 }
 
 //this populates the user's map with spots within a specific area (same as the size of the map here)
 //eventually want the user to be able to scroll through the map and have spots automatically populate as the user scrolls
 func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
 let location = locations[0]
 let span:MKCoordinateSpan = MKCoordinateSpanMake(0.035, 0.035)
 let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
 let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
 mapView.setRegion(region, animated: true)
 self.mapView.showsUserLocation = true
 loadAnnotations(location: location)
 }
 
 func loadAnnotations(location:CLLocation) {
 
 
 let spotRef = Database.database().reference().child("spots")
 let geoFire = GeoFire(firebaseRef: spotRef)
 let center = location
 let circleQuery = geoFire.query(at: center, withRadius: 3)
 self.loadUserAuth() {
 (result: String) in
 print("got back: \(result)")
 self.runQueries(circleQuery: circleQuery)
 }
 }
 
//matches spotID with each spot
 func loadUserAuth(completion: @escaping (_ result: String) -> Void) {
 authRef.observe(.value, with: { (snapshot) in
 if let dictionary = snapshot.value as? [String: AnyObject] {
 for each in dictionary as [String: AnyObject] {
 Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("foundSpotIDs").child(each.key).observeSingleEvent(of: .value, with: { (snapshot2) in
 if let userdick = snapshot2.value as? [String: AnyObject] {
 self.userFoundSpots.append(userdick["spotID"] as! String)
 print(userdick["spotID"] as! String)
 }
 })
 }
 completion("auth done")
 }
 })
 }
 //Here we run the location query and check for the users authorization level to each local spot
// (user found spot, user unlocked spot, or locked spot)
 func runQueries(circleQuery : GFCircleQuery) {
 circleQuery.observe(GFEventType.keyEntered) { (key: String!, tempLocation: CLLocation!) in
 
 print("in query")
 if (self.userFoundSpots.contains(key)) {
 print("we was here")
 self.localSpots.append([key : 0])
 }
 else { self.localSpots.append([key : 2])}
 
 self.setUpAnnotations(key: key, tempLocation: tempLocation)
 }
 }
 
 
//Sets up annotations on the map and the popouts for those annotations
 func setUpAnnotations(key : String, tempLocation : CLLocation!){
 Database.database().reference().child("spots").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
 if let dictionary = snapshot.value as? [String: AnyObject] {
 let anno = MKPointAnnotation()
 let spotID = dictionary["id"] as! String
 self.currentSpotID = spotID
 anno.title = dictionary["name"] as? String
 anno.coordinate = tempLocation.coordinate
 
 if (self.localSpots.contains([spotID : 0])){
 anno.subtitle = "Your Spots"
 }
 else { anno.subtitle = "Locked Spot" }
 print("pre anno")
 self.mapView.addAnnotation(anno)
 let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.infoTap(_:)))
 tapGesture.numberOfTapsRequired = 1
 self.infoButton.addGestureRecognizer(tapGesture)
 }
 })
 }
 
 //user clicks through from the spot popout to the spot page
 @objc func infoTap(_ sender: UITapGestureRecognizer) {
 if !(self.userFoundSpots.contains(currentSpotID)) {
 print(currentSpotID)
 print(userFoundSpots[0])
 print(userFoundSpots[1])
 self.performSegue(withIdentifier: "mapToLockedSpot", sender: self)
 }
 else { self.performSegue(withIdentifier: "mapToUnlockedSpot", sender: self) }
 }
 
 
 
 
 
 
 override func prepare(for segue: UIStoryboardSegue, sender: Any?)
 {
 if segue.identifier == "mapToNav" {
 if let nav = segue.destination as? UINavigationController {
 if let vc = nav.topViewController as? CreateNewSpotVC {
 vc.newSpotLocation = self.newSpotLocation
 }
 }
 }
 if segue.identifier == "mapToUnlockedSpot" {
 if let nav = segue.destination as? UINavigationController {
 if let vc = nav.topViewController as? MainSpotVC {
 vc.spotID = self.currentSpotID
 }
 }
 
 }
 }
 
 }
 
 
 
 //setting custom annotations (pins) for each spot -> doesn't work
 extension MapVC: MKMapViewDelegate {
 func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
 {
 
 let annoIdentifier = "Spot"
 var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annoIdentifier)
 
 if annotation.isKind(of: MKUserLocation.self ) {
 return nil;
 }
 else if annotationView == nil {
 annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annoIdentifier)
 annotationView?.canShowCallout = true
 annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
 } else {
 annotationView?.annotation = annotation
 }
 if (annotationView?.annotation?.subtitle == "Your Spots") {
 annotationView?.image = UIImage(named: "spotRainbow")
 }
 else if (annotationView?.annotation?.subtitle == "Locked Spot") {
 annotationView?.image = UIImage(named: "spotBlack")
 }
 
 //self.authStatus = 2
 
 /*   if (self.localSpots[key] == 0) {
 annotationView?.image = UIImage(named: "spotRainbow")
 }*/
 
 annotationView?.detailCalloutAccessoryView?.backgroundColor = UIColor.black
 annotationView?.canShowCallout = true
 annotationView?.rightCalloutAccessoryView = infoButton
 
 
 
 
 return annotationView
 
 }
 class CustomMKPinAnnotationView: MKPinAnnotationView {
 override func setSelected(_ selected: Bool, animated: Bool) {
 //Set text of labels in custom callout
 }
 }
 
 
 func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
 print("selected")
 }
 }


//circular image extension for the user's profile nav bar item
 extension UIImage {
 
 func circularImage(size: CGSize?) -> UIImage {
 let newSize = size ?? self.size
 
 let minEdge = min(newSize.height, newSize.width)
 let size = CGSize(width: minEdge, height: minEdge)
 
 UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
 let context = UIGraphicsGetCurrentContext()
 
 self.draw(in: CGRect(origin: CGPoint.zero, size: size), blendMode: .copy, alpha: 1.0)
 
 context!.setBlendMode(.copy)
 context!.setFillColor(UIColor.clear.cgColor)
 
 let rectPath = UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: size))
 let circlePath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: size))
 
 rectPath.append(circlePath)
 
 rectPath.usesEvenOddFillRule = true
 rectPath.fill()
 
 let result = UIGraphicsGetImageFromCurrentImageContext()
 UIGraphicsEndImageContext()
 
 return result!
 }
 func roundedWithBorder(width: CGFloat, color: UIColor) -> UIImage? {
 let square = CGSize(width: min(size.width, size.height) + width * 2, height: min(size.width, size.height) + width * 2)
 let imageView = UIImageView(frame: CGRect(origin: .zero, size: square))
 imageView.contentMode = .center
 imageView.image = self
 imageView.layer.cornerRadius = square.width/2
 imageView.layer.masksToBounds = true
 imageView.layer.borderWidth = width
 imageView.layer.borderColor = color.cgColor
 UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
 defer { UIGraphicsEndImageContext() }
 guard let context = UIGraphicsGetCurrentContext() else { return nil }
 imageView.layer.render(in: context)
 return UIGraphicsGetImageFromCurrentImageContext()
 }
 }
 
 
 
 /* func imageWithBorder(width: CGFloat) -> UIImage? {
 let square = CGSize(width: min(size.width, size.height) + width * 2, height: min(size.width, size.height) + width * 2)
 let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
 imageView.contentMode = .center
 imageView.image = self
 imageView.layer.borderWidth = width
 imageView.layer.borderColor = UIColor.white.cgColor
 UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
 guard let context = UIGraphicsGetCurrentContext() else { return nil }
 imageView.layer.render(in: context)
 let result = UIGraphicsGetImageFromCurrentImageContext()
 UIGraphicsEndImageContext()
 return result
 }*/
 
 
 
 
 //this is currently not being used but was meant to set up a search bar at one point

 class SearchBarContainerView: UIView, UISearchBarDelegate {
 
 let searchBar: UISearchBar
 
 init(customSearchBar: UISearchBar) {
 searchBar = customSearchBar
 super.init(frame: CGRect.zero)
 
 searchBar.delegate = self
 searchBar.placeholder = "Search".localizedLowercase
 searchBar.barTintColor = UIColor.white
 searchBar.searchBarStyle = .minimal
 searchBar.returnKeyType = .done
 addSubview(searchBar)
 }
 override convenience init(frame: CGRect) {
 self.init(customSearchBar: UISearchBar())
 self.frame = frame
 }
 
 required init?(coder aDecoder: NSCoder) {
 fatalError("init(coder:) has not been implemented")
 }
 
 override func layoutSubviews() {
 super.layoutSubviews()
 searchBar.frame = bounds
 }
 }
 
