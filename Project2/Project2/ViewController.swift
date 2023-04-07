//
//  ViewController.swift
//  Project2
//
//  Created by Noel Abraham Biju on 2023-04-03.
//

import UIKit
import MapKit
class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupMap()
        addAnnotation(location: getFanshaweLocation())
    }
    
    private func getFanshaweLocation() -> CLLocation{
        return CLLocation(latitude: 43.0130, longitude: -81.1994)
    }
    
    private func addAnnotation(location: CLLocation){
        let annotation = MyAnnotation(coordinate: location.coordinate,
                                      title: "My title",
                                      subtitle: "My subtitle", glyphText: "F")
        mapView.addAnnotation(annotation)
    }
    
    private func setupMap(){
        
        //set deligate
        mapView.delegate = self
        
        //Fanshawe: 43.0130, -81.1994
        let location = getFanshaweLocation()
        
        let radiusInMeters: CLLocationDistance = 1000
        
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: radiusInMeters,
                                        longitudinalMeters: radiusInMeters)
        
        mapView.setRegion(region, animated: true)
        
        //camera boundary
        
        let cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: region)
        mapView.setCameraBoundary(cameraBoundary, animated: true)
        
        //zoom Range
        
        let zoonRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 100000)
        mapView.setCameraZoomRange(zoonRange, animated: true)
        
    }
}

extension ViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let indentifier = "myIdentifier"
        var view: MKMarkerAnnotationView
        
        // check to see if we have a view we can reuse
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: indentifier)as?
            MKMarkerAnnotationView{
            //get updated annotation
            dequeuedView.annotation = annotation
            // use our reuseable view
            view = dequeuedView
        }
        else{
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: indentifier)
            view.canShowCallout = true
            
            //set the position of callout
            view.calloutOffset = CGPoint(x: 0, y: 10)
            
            //add a button to right side of callout
            
            let button = UIButton(type: .detailDisclosure)
            view.rightCalloutAccessoryView = button
            
            //add an image to left side of callout
            let image = UIImage(systemName: "graduationcap.circle.fill")
            view.leftCalloutAccessoryView = UIImageView(image: image)
            
            //change colour of pin/marker
            view.markerTintColor = UIColor.purple
            
            //change colour of accessories
            view.tintColor = UIColor.systemRed
            
            if let myAnnotaion = annotation as? MyAnnotation{
                view.glyphText = myAnnotaion.glyphText
            }
        }
        return view
    }
}

class MyAnnotation: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var glyphText: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, glyphText: String? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.glyphText =  glyphText
        
        super.init()
    }
    
    
}

