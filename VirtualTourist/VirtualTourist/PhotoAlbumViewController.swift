//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Saad altwaim on 9/8/21.
//  Copyright © 2021 Saad Altwaim. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController , MKMapViewDelegate , UICollectionViewDelegate , UICollectionViewDataSource
    , NSFetchedResultsControllerDelegate
{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewButton: UIButton!
    
    var dataController : DataController?
    var pin : Pin?
    var isPinExist : Bool? // Page 17 Note 1
    var fetchedResultsController : NSFetchedResultsController<Photo>!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        createNavButton(title: "OK", imageName: "Button2.png")
        
        createCellLayout(numberOfItemsPreRow : 3.0 , leftAndRightPaddings : 32.0 ,heightAdjustment : 32.0)
                
        setUpFetchedResultsController()
        
        flickrApiCaller() //Page 18 Note 3 -A
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        setUpFetchedResultsController()

    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        resetCollectionView()
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func createNavButton(title: String , imageName : String) // Page 11 Note 3 
    {
        let backbutton = UIButton(type: .custom)
        backbutton.setImage(UIImage(named: imageName), for: .normal)
        backbutton.setTitle(title, for: .normal)
        backbutton.setTitleColor(backbutton.tintColor, for: .normal)
        backbutton.addTarget(self, action: #selector(self.backButton), for: .touchUpInside)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutton)
        
        showSelectedPin()
    }

    @objc func backButton()
    {
        navigationController?.popViewController(animated: true)
    }
    
    func showSelectedPin()
    {
        let lat = FlickrApiClient.LocationVariable.latitude
        let lon = FlickrApiClient.LocationVariable.longitude
        
        let annotation = MKPointAnnotation()
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        annotation.coordinate = location
        let span = MKCoordinateSpan(latitudeDelta: 1.3, longitudeDelta: 1.3)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
    }

    func displayFlickrApiPhoto()
    {
        FlickrApiClient.getFlickrPhotosSearchForLocation
        {
            (flickrPhoto , error) in
//            print("message from view contrller" , flickrPhoto)
            
            FlickerDataModel.dataList = flickrPhoto
             
            if (FlickerDataModel.dataList == [] || error != nil)
            {
                DispatchQueue.main.async
                {
                    let alertVC = UIAlertController(title: "Error", message: "No Image was found in this Location", preferredStyle: .alert)
                    let alertButton = UIAlertAction(title: "OK", style: .default,
                                                    handler: { (action) -> Void in
                                                    self.navigationController?.popViewController(animated: true)})
                    alertVC.addAction(alertButton)
                    self.present(alertVC,animated: true, completion: nil)
                }
            }
                
            else
            {
                DispatchQueue.main.async
                {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if (pinView == nil)
        {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.image = UIImage(named: "mapPin1")
        }
        else
        {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func resetCollectionView()
    {
        FlickerDataModel.dataList = []
        collectionView.reloadData()
    }
    
    // MARK: - Coredata Operation
    
    func flickrApiCaller()
    {
        let fetchRequest : NSFetchRequest<Photo> = Photo.fetchRequest() // Note 1 Page 16
        let predicate = NSPredicate(format: "pin == %@", pin!)
          
        fetchRequest.predicate = predicate
          
        if let result = try? dataController?.viewContext.fetch(fetchRequest)
        {
            if (result.count == 0)
            {
                displayFlickrApiPhoto()
            }
        }
    }
    
    func saveImagesFromBackgroundContext(data :Data) // Page 20 note 2 - B
    {
        if let image = UIImage(data: data)
        {
            let backgroundContext : NSManagedObjectContext! = self.dataController?.backgroundContext
            
            backgroundContext.perform
            {
                let photo = Photo(context: self.dataController!.backgroundContext)
                let phtotID = photo.objectID

                let pinID = self.pin?.objectID
                let backgroundPin = self.dataController?.backgroundContext.object(with: pinID!) as! Pin // Note 2 Page 18 - B

                let pngImagesData = image.pngData()
                let backgroundPhoto = backgroundContext.object(with: phtotID) as! Photo // Note 2 Page 18 - A
                backgroundPhoto.locationPhotos = pngImagesData // Note 2 Page 18 - C
                backgroundPhoto.pin = backgroundPin

                if backgroundContext.hasChanges
                {
                    do
                    {
                        try backgroundContext.save()
                        print("The image was save in core COREDATA Using background Context")
                    }
                    catch
                    {
                        print(error)
                        print("Cant save IMAGE TO COREDATA background Context")
                    }
                }
            }
        }
    }
    
    func deleteImageFromCoredata(at indexPath : IndexPath)
    {
        let iamgeToDelete = fetchedResultsController.object(at: indexPath)
        dataController?.viewContext.delete(iamgeToDelete)

        if dataController?.viewContext.hasChanges == true
        {
            try? dataController?.viewContext.save()
        }
        
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9,
            options: UIView.AnimationOptions.curveLinear, animations:
            {
                self.collectionView.reloadItems(at: [indexPath])
            },
            completion: { success in
        })
        
    }
    
    // MARK: - fetchedResultsController
    
    fileprivate func setUpFetchedResultsController() // Page 20 note 2 - A
    {
        let fetchRequest : NSFetchRequest<Photo> = Photo.fetchRequest()
        let pinObjectID = self.pin?.objectID
        let pinFromBackground = self.dataController?.backgroundContext.object(with: pinObjectID!) as! Pin
        let predicate = NSPredicate(format: "pin == %@", pinFromBackground)
        let sortDescriptor = NSSortDescriptor(key: "locationPhotos", ascending: false)
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: dataController!.viewContext,
                                                              sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do
        {
            try fetchedResultsController.performFetch()
        }
            
        catch
        {
            print("The Error Message is : ",error)
            fatalError("The Fetch Could Not be preformed : \(error.localizedDescription)")
        }
        
    }
    
    // MARK: - UIcollectionView
    
    @IBAction func newCollectionButton(_ sender: Any)
    {
        var totalPages = Int.random(in: 1..<20)
        
        var randomPageNumber: Int
        {
            let page = min(totalPages, 4000/FlickerDataModel.dataList.count)
            return Int(arc4random_uniform(UInt32(page)) + 1)
        }

        FlickrApiClient.LocationVariable.page = randomPageNumber
        displayFlickrApiPhoto()
    }
    
    func createCellLayout(numberOfItemsPreRow : CGFloat , leftAndRightPaddings : CGFloat ,heightAdjustment :  CGFloat) // Page 11 Note 4
    {
        let width  = (collectionView!.frame.width - leftAndRightPaddings) / numberOfItemsPreRow
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width + heightAdjustment)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        if let sections = fetchedResultsController.sections
        {
            return sections.count
        }
        else
        {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        //Page 18 Note 3 -B (in the next Page)
        let isRecordExist = fetchedResultsController.sections?[section].numberOfObjects
        
        if isRecordExist != 0
        {
            guard let sections = fetchedResultsController.sections
            
            else
            {
                return 0
            }
            
            isPinExist = true
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
            
        else
        {
            isPinExist = false
            return FlickerDataModel.dataList.count
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if(isPinExist == false)
        {
            FlickerDataModel.dataList.remove(at: indexPath.item)
            self.collectionView.deleteItems(at: [indexPath])
        }
        else
        {
            deleteImageFromCoredata(at: indexPath) // Page 19 Note 2
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        // Page 13 note 1 
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrCollectionViewCell", for: indexPath) as! CollectionViewCell

        if isPinExist != false
        {
            let aPhoto = fetchedResultsController.object(at: indexPath) //Page 19 note 1
            if let imageData = aPhoto.locationPhotos
            {
                let uiIamge = UIImage(data: imageData)

                cell.imageView.image = uiIamge
            }
        }
                
        else
        {
            let DataModel = FlickerDataModel.dataList[indexPath.row]

            cell.imageView.image = UIImage(named: "placeholder1")

            let urlString = "https://live.staticflickr.com/\(DataModel.server)/\(DataModel.id)_\(DataModel.secret)_m.jpg"
            let imageUrl = URL(string: urlString)

            FlickrApiClient.downloadAsynchronousImage(imagePath: urlString)
            {
                (Data, String) in
                self.saveImagesFromBackgroundContext(data: Data!)
            }

            let disabledButton = collectionViewButton
            cell.imageView.loadImage(fromURL: imageUrl!, placeHolderImage : "placeholder1", button: disabledButton!) // old cell Code Page 13 - 1

            collectionViewButton.isEnabled = false
        }
        
        return cell
    }
}
