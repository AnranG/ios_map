//
//  ViewController.swift
//  COMP327 Assignment2
//
//  Created by Anran Guo on 05/12/2016.
//  Copyright © 2016 Anran Guo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

//initialize two global variable
var placeID = ""
var photoReference = ""

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    //initialize elements of UIView and MapView
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var showDetails: UIBarButtonItem!
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var locationTable: UITableView!
    @IBOutlet weak var filter: UISegmentedControl!
   
    /*
     initialize LocationManager to get lication service;
     currentLocation to present the attribute of current location;
     jsonResult to save the result from json file;
     filterType to store the type of data
    */
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation!
    var jsonResult : AnyObject = 0 as AnyObject
    var filterType: String = ""
    
    /*
     touch search button to show search bar or hide it
     */
    @IBAction func selectSearch(_ sender: Any) {
        if search.isHidden == true {
            search.isHidden = false
        }else{
            search.isHidden = true
        }
        
    }
    
    
   
    
    /*
     touch filter button to show filter segmented control or hide it
     */
    @IBAction func showFilter(_ sender: Any) {
        if filter.isHidden == true {
            filter.isHidden = false
        }else{
            filter.isHidden = true
        }
    }
    
    /*
     touch filter type segmented control to change different filter type
     */
    @IBAction func filterChanged(_ sender: AnyObject) {
        
        if sender.selectedSegmentIndex == 0{
            filterType = "gym"
        }
        else if sender.selectedSegmentIndex == 1{
            
            filterType = "atm"
        }
        else if sender.selectedSegmentIndex == 2{
            filterType = "store"
        }
        else if sender.selectedSegmentIndex == 3{
            filterType = "hospital"
        }
        else if sender.selectedSegmentIndex == 4{
            filterType = "food"
        }
        //load json file with current location and filter type
        loadJson(lat: String(currentLocation.coordinate.latitude), lon: String(currentLocation.coordinate.longitude),type: filterType, key: "")
        //hide the segmented control
        filter.isHidden = true
    }
    
    /*
     touch map type segmented control to change different map type
     */
    @IBAction func segmentedControl(_ sender: AnyObject) {
        if sender.selectedSegmentIndex == 0{
            
            map.mapType = MKMapType.standard
        }
        else if sender.selectedSegmentIndex == 1{
            
            map.mapType = MKMapType.satellite
        }
        else if sender.selectedSegmentIndex == 2{
            
            map.mapType = MKMapType.hybrid
        }
    }
    
    /*
     touch location button to move the visual field to current location with constrained span
     */
    @IBAction func findCurrentLocation(_ sender: Any) {
        //constrain span
        let span = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        //the coordinate of current location
        let coordinate = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        //constrain region with coordinate of current location as center ans constrained span as span
        let region = MKCoordinateRegion(center: coordinate, span: span)
        //set region on the map
        self.map.setRegion(region, animated: true)
    }
    
    /*
     set the number of rows with the number of "results"
     */
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let nameArray = self.jsonResult["results"] as? NSArray{
            return nameArray.count
        }else{
            return 0
        }
        
    }
    /*
     write the results and the distance to destination into cell, and show the annotation on the map
     */
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //set a new cell with value1 style
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "myCell")
        if let nameLabel = ((self.jsonResult["results"] as? NSArray)?[indexPath.row] as? NSDictionary)?["name"] as? String{
            //print the name label in the table cell
            cell.textLabel?.text = nameLabel
            //latitude of result location
            let latitude = ((((self.jsonResult["results"] as? NSArray)?[indexPath.row] as? NSDictionary)?["geometry"] as? NSDictionary)?["location"] as? NSDictionary)?["lat"] as? CLLocationDegrees
            //longtitude of result location
            let longitude = ((((self.jsonResult["results"] as? NSArray)?[indexPath.row] as? NSDictionary)?["geometry"] as? NSDictionary)?["location"] as? NSDictionary)?["lng"] as? CLLocationDegrees
            //set up span
            let span = MKCoordinateSpan(latitudeDelta: 0.023, longitudeDelta: 0.023)
            //set up coordinate of reslut location
            let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            //set up coordinate of current location
            let currentCoordinate = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            //set up region
            let region = MKCoordinateRegion(center: currentCoordinate, span: span)
            //show the region on the map
            self.map.setRegion(region, animated: true)
            //set up annotation
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = nameLabel
            //show the annotation on the map
            self.map.addAnnotation(annotation)
            
            // Get source of current position
            let sourcePlacemark = MKPlacemark(coordinate: currentLocation.coordinate, addressDictionary: nil)
            let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
            
            // Get destination of destination position
            let destinationCoordinates = CLLocationCoordinate2DMake(latitude!, longitude!)
            let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinates, addressDictionary: nil)
            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
            
            // Create request
            let request = MKDirectionsRequest()
            request.source = sourceMapItem
            request.destination = destinationMapItem
            request.transportType = MKDirectionsTransportType.automobile
            request.requestsAlternateRoutes = false
            let directions = MKDirections(request: request)
            //calculate the distance
            directions.calculate(completionHandler: {(response, error) in
                if let route = response?.routes.first {
                    //print the distance in the table cell
                    cell.detailTextLabel?.text = "\(route.distance)m"
                } else {
                    print("Error!")
                }
                
            })
        }
        return cell
    }
    /*
     caculate the route from current location to destination location
     */
    public func showRoute(_ response: MKDirectionsResponse) {
        for route in response.routes {
            map.add(route.polyline, level: MKOverlayLevel.aboveRoads)
        }
    }
    /*
     present the route on the map
     */
    public func mapView(_ mapView: MKMapView, rendererFor
        overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        return renderer
    }
    /*
     the dunc will be called when a cell is selected;
     the corresponding route will show on the map;
     the details button on the navigation bar can be selected to see more details
     */
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //get placeID from json file
        placeID = (((self.jsonResult["results"] as? NSArray)?[indexPath.row] as? NSDictionary)?["place_id"] as? String)!
        //get photoReference from json file
        if let reference = ((((self.jsonResult["results"] as? NSArray)?[indexPath.row] as? NSDictionary)?["photos"] as? NSArray)?[0] as? NSDictionary)?["photo_reference"] as? String{
            photoReference = reference
        }
        //remove overlays from the map
        let overlays = self.map.overlays
        self.map.removeOverlays(overlays)
        
        //latitude of result location
        let latitude = ((((self.jsonResult["results"] as? NSArray)?[indexPath.row] as? NSDictionary)?["geometry"] as? NSDictionary)?["location"] as? NSDictionary)?["lat"] as? CLLocationDegrees
        //longtitude of result location
        let longitude = ((((self.jsonResult["results"] as? NSArray)?[indexPath.row] as? NSDictionary)?["geometry"] as? NSDictionary)?["location"] as? NSDictionary)?["lng"] as? CLLocationDegrees
        // Get source of current position
        let sourcePlacemark = MKPlacemark(coordinate: currentLocation.coordinate, addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        
        // Get destination of destination position
        
        let destinationCoordinates = CLLocationCoordinate2DMake(latitude!, longitude!)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinates, addressDictionary: nil)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        // Create request
        let request = MKDirectionsRequest()
        request.source = sourceMapItem
        request.destination = destinationMapItem
        request.transportType = MKDirectionsTransportType.automobile
        request.requestsAlternateRoutes = false
        let directions = MKDirections(request: request)
        //call showRoute func to show route on the map
        directions.calculate(completionHandler: {(response, error) in
            
            if error != nil {
                print("Error getting directions")
            } else {
                self.showRoute(response!)
            }
        })
        //enable the details button
        showDetails.isEnabled = true
    }
    
    /*
     the func is called when the serch button is selected;
     all the annotation on the map will be removed;
     load json file;
     hide the search bar
     */
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        //remove all the annotations
        map.removeAnnotations(map.annotations)
        //load json file with current locationa and key with loadJson func
        loadJson(lat: String(currentLocation.coordinate.latitude), lon: String(currentLocation.coordinate.longitude),type: "", key: search.text!)
        //hide the search bar
        search.isHidden = true
        
        }
    
    /*
     the main func that will be called when the view did load
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        //details button is not enabled
        showDetails.isEnabled = false
        //filter segmented control is hidden
        filter.isHidden = true
        //keep the number of cell appropriate
        locationTable.tableFooterView = UIView()
        //search bar is hidden
        search.isHidden = true
        
        //set up location manager to update current location
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.requestAlwaysAuthorization()
        
        //show current location on the map
        map.showsUserLocation = true
    }
    
    /*
     the func will be called when the user location is updated;
     record the current location;
     show the currentlocation on the map with constrained region and center
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //record current location
        self.currentLocation = locations.last
        
        //constrain span
        let span = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        //the coordinate of current location
        let coordinate = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        //constrain region with coordinate of current location as center ans constrained span as span
        let region = MKCoordinateRegion(center: coordinate, span: span)
        //set region on the map
        self.map.setRegion(region, animated: true)
        
        //stop update location
        locationManager?.stopUpdatingLocation()
    }
    
    /*
     the func will be called when the updating of location is failed
     */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: NSError) {
        print("Failed to find user's location")
    }
    
    /*
     a func load data fron json file;
     with four variables of type string
     */
    func loadJson (lat: String,lon: String,type: String, key: String){
        //remove all the white space from input
        let key = key.replacingOccurrences(of: " ", with: "")
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(lon)&radius=1000&types=\(type)&keyword=\(key)&key=AIzaSyB579Y7prckL2vXW3qG1XwnRz8whAacy5E")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                        if error != nil {
                            print(error)
            
                        } else {
                            if let urlContent = data {
            
                                do {
                                    //get jsonResult
                                    self.jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                                    DispatchQueue.main.async {
                                        //reload table
                                        self.locationTable.reloadData()
                                        //remove overlays
                                        let overlays = self.map.overlays
                                        self.map.removeOverlays(overlays)
                                        //details button is not enable
                                        self.showDetails.isEnabled = false
                                    }
                                } catch {
                                    print("======\nJSON processing Failed\n=======")
                                }
                                
                            }
                        }
                    }
                    
                    task.resume()
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

