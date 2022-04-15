//
//  TravelMapViewController.swift
//  VirtualTourist
//
//  Created by Saad altwaim on 8/29/21.
//  Copyright © 2021 Saad Altwaim. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelMapViewController: UIViewController , MKMapViewDelegate
{
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController : DataController!
    var pinObjectID :Pin?
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad()
    {   
        super.viewDidLoad()
        
        mapView.delegate = self
        
        loadPinFromCoreData()
        
        getCoreDataURL()
        
        viewSpanAndAnnotation() // to get the zoom level & Center for the map
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
     // MARK: - MapView functions 
    
//    https://review.udacity.com/#!/reviews/3259616
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) // Page 9
    {
        if sender.state == .ended // Page 16
        {
            let location = sender.location(in: mapView) //Page 10 note 1
            let locCoordinate = mapView.convert(location, toCoordinateFrom:  mapView) // note 1- B

            let annotation = MKPointAnnotation() // page 10 Note 2
            annotation.coordinate = locCoordinate // page 10 Note 3
            let latitude = annotation.coordinate.latitude // Note 1 - C
            let longitude = annotation.coordinate.longitude

            savesPinToCoreData(latitude : latitude , longitude : longitude)
            mapView.addAnnotation(annotation) // Page 10 note 4
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) // Page 10 Note 8
    {
        getMapZoomAndCenter(for: mapView) // this function
    }
    
    func getMapZoomAndCenter(for mapView : MKMapView) // to save ZoomAndCenter
    {
        let latitudeDelta = mapView.region.span.latitudeDelta
        let longitudeDelta = mapView.region.span.longitudeDelta
        
        let latitudeCenter = mapView.centerCoordinate.latitude
        let longitudeCenter = mapView.centerCoordinate.longitude
        
        userDefaults.set(latitudeDelta,   forKey: "latZoom")
        userDefaults.set(longitudeDelta,  forKey: "lonZoom")
        userDefaults.set(latitudeCenter,  forKey: "latCenter")
        userDefaults.set(longitudeCenter, forKey: "lonCenter")

    }
    
    func viewSpanAndAnnotation() //to Load ZoomAndCenter
    {
        let defaultLatitudeZoom    = userDefaults.object(forKey: "latZoom")   as! Double
        let defaultLongitudeZoom   = userDefaults.object(forKey: "lonZoom")   as! Double
        let defaultLatitudeCenter  = userDefaults.object(forKey: "latCenter") as! Double
        let defaultLongitudeCenter = userDefaults.object(forKey: "lonCenter") as! Double
        
        let annotation = MKPointAnnotation()
        
        let location = CLLocationCoordinate2D(latitude: defaultLatitudeCenter , longitude: defaultLongitudeCenter)
        annotation.coordinate = location
         
        let span = MKCoordinateSpan(latitudeDelta : defaultLatitudeZoom , longitudeDelta: defaultLongitudeZoom) // Page 10 note 5

        let region = MKCoordinateRegion(center: annotation.coordinate, span: span) // Page 10 note 6
        mapView.setRegion(region, animated: true) // Page 10 note 6
    }
   
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) // Page 10 note 8
    {
        let selectedAnnotation = view.annotation
        let latitude = selectedAnnotation?.coordinate.latitude
        let longitude = selectedAnnotation?.coordinate.longitude

        FlickrApiClient.LocationVariable.latitude = latitude!
        FlickrApiClient.LocationVariable.longitude  = longitude!

        retrievingPinFromCoredata(inputLatitude: latitude!, inputLongitude: longitude!)

        self.performSegue(withIdentifier: "showPhotoAlbumVC", sender: nil)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil } // Page 11 Note 1

        // page 11 Note 2
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil
        {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.image = UIImage(named: "mapPin1")
        }
        else
        {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
     // MARK: - Coredata Operation
    
    func savesPinToCoreData(latitude : Double , longitude : Double)
    {
        let savePin = Pin(context: dataController.viewContext)
        savePin.latitude = latitude
        savePin.longitude = longitude
        self.pinObjectID = savePin

        do
        {
            try dataController.viewContext.save()
//            print("The Pin is saved to Core data ")
        }
        catch
        {
            print("Cant save the data : ",error.localizedDescription)
        }
    }
    
    func loadPinFromCoreData()
    {
        var latitude  = 0.0
        var longitude = 0.0
        
        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()

        if let result = try? dataController.viewContext.fetch(fetchRequest)
        {
            for savedData in result as [NSManagedObject]
            {
                latitude  = savedData.value(forKey: "latitude")  as! Double
                longitude = savedData.value(forKey: "longitude") as! Double
                
                let annotation = MKPointAnnotation()
                let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                annotation.coordinate = location
                mapView.addAnnotation(annotation)
            }
        }
    }
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? PhotoAlbumViewController
        {
            vc.dataController = dataController
            vc.pin = pinObjectID
        }
    }
    
    func getCoreDataURL()
    {
        let coredataURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(coredataURL[coredataURL.count-1] as URL)
    }
    
    func retrievingPinFromCoredata(inputLatitude : Double , inputLongitude : Double)
    {
        var coredataLatitude  = 0.0
        var coredataLongitude = 0.0

        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()

        if let result = try? dataController.viewContext.fetch(fetchRequest)
        {
            for savedData in result as [NSManagedObject]
            {
                coredataLatitude  = savedData.value(forKey: "latitude")  as! Double
                coredataLongitude = savedData.value(forKey: "longitude") as! Double

                if (inputLatitude == coredataLatitude && inputLongitude == coredataLongitude)
                {
                    pinObjectID =  savedData as? Pin
                }
            }
        }
    }
}

