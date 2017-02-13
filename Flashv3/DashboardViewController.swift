//
//  DashboardViewController.swift
//  Flashv3
//
//  Created by Chris on 1/2/17.
//  Copyright © 2017 Flash. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import SwiftyJSON
import SVProgressHUD

var lat = ""
var long = ""
var locationType:String = "restaurant"
var done = false

var name = ["", "", "", "", ""]
var rating = [0.0, 0.0, 0.0, 0.0, 0.0]
var price = ["", "", "", "", ""]
var phoneNumber = ["", "", "", "", ""]
var website = ["", "", "", "", ""]
var address = ["", "", "", "", ""]
var cashLabel = ["", "", "", "", ""]
var desc = ["", "", "", "", ""]
var distance = ["", "", "", "", ""]
var placePic: [UIImage] = [
    UIImage(named: "foodB")!,
    UIImage(named: "foodB")!,
    UIImage(named: "foodB")!,
    UIImage(named: "foodB")!,
    UIImage(named: "foodB")!,
]
var baseURL = ""
var restTypeFire = ""
var finalDistanceFire = 0
var minPriceFire = 1
var maxPriceFire = 3

class DashboardViewController: UIViewController, CLLocationManagerDelegate, UIViewControllerTransitioningDelegate, UIActionSheetDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var foodButton: UIButton!
    @IBOutlet weak var drinkButton: UIButton!
    @IBOutlet weak var barsButton: UIButton!
    @IBOutlet weak var groupButton: UIButton!
    
        var open = false
    var locationManager: CLLocationManager!
    
    var location: CLLocation! {
        didSet {
            lat = "\(location.coordinate.latitude)"
            long = "\(location.coordinate.longitude)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        checkCoreLocationPermission()
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        scrollView.contentSize.height = 645
        
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setForegroundColor(UIColor(red: 239/255.0, green: 96/255.0, blue: 86/255.0, alpha: 1))
        SVProgressHUD.setBackgroundColor(UIColor.white)
        SVProgressHUD.setRingRadius(5.0)
        
        //Title
        let logo = UIImage(named: "flashTitleDash")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        //Hamburger
        let menuImage = UIImage(named: "hamburger")
        let menu = UIBarButtonItem(image: menuImage, style: .plain, target: self, action: #selector(handleMore))
        menu.tintColor = UIColor(red: 239/255.0, green: 96/255.0, blue: 86/255.0, alpha: 1)
        self.navigationItem.leftBarButtonItem = menu
        
        //ChangePrefIcon
        let icon = UIImage(named: "changePrefIcon")
        let pref = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(dismissView))
        pref.tintColor = UIColor(red: 239/255.0, green: 96/255.0, blue: 86/255.0, alpha: 1)
        self.navigationItem.rightBarButtonItem = pref
        // Do any additional setup after loading the view.
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("users").child(uid!).child("preferences").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                restTypeFire = (dictionary["cuisine"] as? String)!
                finalDistanceFire = (dictionary["distance"] as? Int)!
                minPriceFire = (dictionary["min"] as? Int)!
                maxPriceFire = (dictionary["max"] as? Int)!
            }
        }, withCancel: nil)
        
        self.foodButton.layer.opacity = 0;
        self.drinkButton.layer.opacity = 0;
        self.barsButton.layer.opacity = 0;
        self.groupButton.layer.opacity = 0;
        
        UIView.animate(withDuration: 1, animations: {self.foodButton.layer.opacity = 1})
        UIView.animate(withDuration: 1.5, animations: {self.drinkButton.layer.opacity = 1})
        UIView.animate(withDuration: 2, animations: {self.barsButton.layer.opacity = 1})
        UIView.animate(withDuration: 2.5, animations: {self.groupButton.layer.opacity = 1})
    }

    override func viewDidAppear(_ animated: Bool) {
        done = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func foodButton(_ sender: Any) {
        
        locationType = "restaurant"
        SVProgressHUD.show()
        getPlace()
        if (done) {
            performSegue(withIdentifier: "rec", sender: nil)
        }
    }
    
    @IBAction func cafeButton(_ sender: Any) {
        
        locationType = "cafe"
        SVProgressHUD.show()
        getPlace()
        if (done) {
            performSegue(withIdentifier: "rec", sender: nil)
        }
    }
    
    @IBAction func barsButton(_ sender: Any) {
        
        locationType = "bar"
        SVProgressHUD.show()
        getPlace()
        if (done) {
            performSegue(withIdentifier: "rec", sender: nil)
        }
        
    }
    
    func handleMore() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Account", style: .default , handler:{ (UIAlertAction)in
            self.performSegue(withIdentifier: "account", sender: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive , handler:{ (UIAlertAction)in
            try! FIRAuth.auth()!.signOut()
            print("Signed Out")
            //self.performSegue(withIdentifier: "log", sender: nil)
            self.performSegue(withIdentifier: "skip", sender: nil)
        }))
        
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
            
            
        }))
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    func dismissView() {
        
        if (prefIsThere){
            self.dismiss(animated: true, completion: nil)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "preferences")
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func checkCoreLocationPermission() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
        else if (CLLocationManager.authorizationStatus() == .notDetermined){
            locationManager.requestWhenInUseAuthorization()
        }
        else if (CLLocationManager.authorizationStatus() == .restricted) {
            print("Unauthorized to use Location")
        }
        else {
            print("Didnt work")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed: \(error.localizedDescription)")
    }
    
    func printLatLong() {
        print("Lat/Long:")
        print(lat)
        print(long)
    }
    
    func getPlace() {
        
        SVProgressHUD.show()
        baseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(long)&radius=\(finalDistanceFire)&type=\(locationType)&keyword=\(restTypeFire)&minprice=\(minPriceFire)&maxprice=\(maxPriceFire)&opennow&key=AIzaSyAYsrOp4fKLQVFtkCb3OYOAb0IGWCeh5c8"
        
        let json = getJSONfromAPIURL(baseURL)
        print(baseURL)
        
        for index in 0...4 {
            name[index] = json["results"][index]["name"].stringValue
            rating[index] = json["results"][index]["rating"].doubleValue
            price[index] = json["results"][index]["price_level"].stringValue
            
            let id = json["results"][index]["place_id"].stringValue
            let placeLat = json["results"][index]["geometry"]["location"]["lat"].stringValue
            let placeLong = json["results"][index]["geometry"]["location"]["lng"].stringValue
            let placeDetailsURL = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(id)&key=AIzaSyAYsrOp4fKLQVFtkCb3OYOAb0IGWCeh5c8"
            let detailJson = getJSONfromAPIURL(placeDetailsURL)
            
            phoneNumber[index] = detailJson["result"]["formatted_phone_number"].stringValue
            website[index] = detailJson["result"]["website"].stringValue
            address[index] = detailJson["result"]["formatted_address"].stringValue
            
            let description = detailJson["result"]["reviews"][index]["text"].stringValue
            let photoReference = detailJson["result"]["photos"][index]["photo_reference"].stringValue
            let pictureURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference)&key=AIzaSyAYsrOp4fKLQVFtkCb3OYOAb0IGWCeh5c8"
            
            let theImageURL = URL(string: pictureURL)
            let imageData = try? Data(contentsOf: theImageURL!)
            
            if (imageData != nil) {
                placePic[index] = UIImage(data: imageData!)!
            }
            
            if (price[index] == "1") {
                cashLabel[index] = "$"
            } else if (price[index] == "2") {
                cashLabel[index] = "$$"
            } else if (price[index] == "3") {
                cashLabel[index] = "$$$"
            }
            
            desc[index] = description
            
            let distanceURL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=\(lat),\(long)&destinations=\(placeLat),\(placeLong)&key=AIzaSyAYsrOp4fKLQVFtkCb3OYOAb0IGWCeh5c8"
            let distanceJson = getJSONfromAPIURL(distanceURL)
            let dist = distanceJson["rows"][0]["elements"][0]["distance"]["text"].stringValue
            
            distance[index] = dist
            /*
             print("DISTANCE")
             print(dist)
             print(phoneNumber)
             print(website)
             print(id)
             print(restType)
             print(name)
             print(baseURL)
             */
        }
        done = true
    }
    
    func getJSONfromAPIURL(_ requestURL: String) -> JSON {
        var json = JSON(NSNull())
        
        if  let url = URL(string: requestURL),
            let data = try? Data(contentsOf: url, options: []) {
            json = JSON(data: data)
        }
        return json
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
