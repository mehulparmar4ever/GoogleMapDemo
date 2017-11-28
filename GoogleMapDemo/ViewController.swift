//
//  ViewController.swift
//  GoogleMapDemo
//
//  Created by mehulmac on 17/04/17.
//  Copyright © 2017 mehulmac. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {

    
    //Variables
    @IBOutlet weak var activitytLocation: UIActivityIndicatorView!
    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var viewGoogleMap: UIView!
    @IBOutlet weak var imgPinCenter: UIImageView!
    
    //custom
    var markerLocation : GMSMarker?
    var currentZoom : Float = 0.0
    var mapView = GMSMapView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        //Ahmedabad lat long, yuou can create .gpx file and you can use it as your default location in map
        /*
        <?xml version="1.0"?>
        <gpx version="1.1" creator="Xcode">
        
        <wpt lat="23.0271" lon="72.5085">
        <name>Ahmedabad</name>
        </wpt>
        </gpx>
        */

        //Srt temp title
        self.title = "Please wait while fetching address"

        //Initially, added temp location address
        let latitude : CLLocationDegrees = 23.0271
        let longitude : CLLocationDegrees = 72.5085
    
        currentZoom = 15
        
        let camera : GMSCameraPosition = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: currentZoom, bearing: 3, viewingAngle: 0)
        
        //Setup for mapview
        viewGoogleMap.layer.masksToBounds = true
        var mapTmp: CGRect = viewGoogleMap.frame
        mapTmp.size.height -= 64
        mapView = GMSMapView.map(withFrame: mapTmp, camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true 
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.isIndoorEnabled = false
        //    [mapView animateToViewingAngle:45];
        viewGoogleMap.addSubview(mapView)

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.mapView.frame = self.viewGoogleMap.frame
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.imgPinCenter.center = CGPoint(x: self.viewGoogleMap.center.x, y: self.viewGoogleMap.center.y-(self.imgPinCenter.frame.size.height/2))
        })
        
        
        activitytLocation.startAnimating()
        
        self.getAddressForMapCenter()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.imgPinCenter.center = CGPoint(x: self.viewGoogleMap.center.x, y: self.viewGoogleMap.center.y-(self.imgPinCenter.frame.size.height/2))
        })
    }

    func getAddressForMapCenter() {
        
        let point : CGPoint = mapView.center
        let coordinate : CLLocationCoordinate2D = mapView.projection.coordinate(for: point)
        let location =  CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.GetAnnotationUsingCoordinated(location)
    }
    
    func GetAnnotationUsingCoordinated(_ location : CLLocation) {
        
        //get current address from geocode from apple, from location lat long
        GMSGeocoder().reverseGeocodeCoordinate(location.coordinate) { (response, error) in
            
            //stop animating loader
            if self.activitytLocation.isAnimating {
                self.activitytLocation.stopAnimating()
            }
            
            self.imgPinCenter.isHidden = true

            var strAddresMain : String = ""
            
            if let address : GMSAddress = response?.firstResult() {
                if let lines = address.lines  {
                    if (lines.count > 0) {
                        if lines.count > 0 {
                            if lines[0].count > 0 {
                                strAddresMain = strAddresMain + lines[0]
                            }
                        }
                    }
                    
                    if lines.count > 1 {
                        if lines[1].count > 0 {
                            if strAddresMain.count > 0 {
                                strAddresMain = strAddresMain + ", \(lines[1])"
                            } else {
                                strAddresMain = strAddresMain + "\(lines[1])"
                            }
                        }
                    }
                    
                    if (strAddresMain.count > 0) {
                        print("strAddresMain : \(strAddresMain)")
                        
                        self.title = strAddresMain
                        
                        var strSubTitle = ""
                        if let locality = address.locality {
                            strSubTitle = locality
                        }
                        
                        if let administrativeArea = address.administrativeArea {
                            if strSubTitle.count > 0 {
                                strSubTitle = "\(strSubTitle), \(administrativeArea)"
                            }
                            else {
                                strSubTitle = administrativeArea
                            }
                        }

                        if let country = address.country {
                            if strSubTitle.count > 0 {
                                strSubTitle = "\(strSubTitle), \(country)"
                            }
                            else {
                                strSubTitle = country
                            }
                        }

                        
                        if strSubTitle.count > 0 {
                            self.addPin_with_Title(strAddresMain, subTitle: strSubTitle, location: location)
                        }
                        else {
                            self.addPin_with_Title(strAddresMain, subTitle: "Your address", location: location)
                        }
                    }
                    else {
                        print("Location address not found")
                        self.title = "Location address not found"
                    }
                }
                else {
                    self.title = "Please change location, address is not available"

                    print("Please change location, address is not available")
                }
            }
            else {
                self.title = "Address is not available"

                print("Address is not available")
            }
        }
    }

    func addPin_with_Title(_ title: String, subTitle: String, location : CLLocation) {
        
        if markerLocation == nil {
            markerLocation = GMSMarker.init()//GMSMarker.init(position: location.coordinate)
        }
        
        //add Marker on google map
        self.addMarkerOnGoogleMap(title, subTitle: subTitle, location: location)
    }

    func addMarkerOnGoogleMap(_ title: String, subTitle: String, location: CLLocation) {
        //update title
//        var titleMain = (title.length > 20) ? ("\(title.substring(to: 20))") : title

        let position : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        markerLocation = GMSMarker(position: position)
        markerLocation?.title = title
        markerLocation?.snippet = subTitle
        markerLocation?.icon = #imageLiteral(resourceName: "ic_pin_drop")
        markerLocation?.appearAnimation = .pop
        mapView.clear()
        markerLocation?.map = mapView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Button Action methods

    @IBAction func btnZoomClicked(_ sender: Any) {
        
        let point : CGPoint = mapView.center
        let coordinate : CLLocationCoordinate2D = mapView.projection.coordinate(for: point)
        
        if((sender as! UIButton).tag == 0) {
            print("btnZoominClicked")

            currentZoom += 1;
            
        }
        else {
            print("btnZoomOutClicked")

            currentZoom -= 1;
        }
        
        let camera : GMSCameraPosition = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: currentZoom)
        mapView.camera = camera
    }
}

extension ViewController : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        //print("didChangeCameraPosition: \(position)")
        mapView.clear()

        //markerLocation?.map = mapView
        
        self.imgPinCenter.isHidden = false
        activitytLocation.startAnimating()

    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        //print("idleAtCameraPosition: \(position)")
        //stop animating loader
        if !self.activitytLocation.isAnimating {
            activitytLocation.startAnimating()
        }

        self.imgPinCenter.isHidden = false
        self.getAddressForMapCenter()
    }
}
