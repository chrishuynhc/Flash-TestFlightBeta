//
//  RecViewController.swift
//  Flashv3
//
//  Created by Chris on 1/4/17.
//  Copyright © 2017 Flash. All rights reserved.
//

import UIKit
import Cosmos
import ScalingCarousel
import Firebase
import SwiftyJSON
import SVProgressHUD

class RecViewController: UIViewController, UICollectionViewDataSource, UIScrollViewDelegate {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "flashTitleDash")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        let menuImage = UIImage(named: "backArrow")
        let menu = UIBarButtonItem(image: menuImage, style: .plain, target: self, action: #selector(dismissRec))
        menu.tintColor = UIColor(red: 239/255.0, green: 96/255.0, blue: 86/255.0, alpha: 1)
        self.navigationItem.leftBarButtonItem = menu
    
        self.automaticallyAdjustsScrollViewInsets = false
        
                // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //***COLLECTION VIEW METHODS***//
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        var cell = ScalingCarouselCell()
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ScalingCarouselCell
        
        cell.restaurantPic.image = placePic[indexPath.row]
        cell.restaurantPic.roundCorners(corners: [.topLeft, .topRight], radius: 20)
        cell.starRating.rating = rating[indexPath.row]
        cell.restaurantName.text = name[indexPath.row]
        cell.restaurantRating.text = String(rating[indexPath.row])
        cell.restaurantPrice.text = cashLabel[indexPath.row]
        //cell.restaurantDescription.text = desc[indexPath.row]
        cell.restaurantDistance.text = distance[indexPath.row]
        
        cell.menuButton.tag = indexPath.row
        cell.menuButton.addTarget(self, action: #selector(menu(_:)), for: .touchUpInside)
        cell.mapButton.tag = indexPath.row
        cell.mapButton.addTarget(self, action:  #selector(map(_:)), for: .touchUpInside)
        cell.phoneButton.tag = indexPath.row
        cell.phoneButton.addTarget(self, action:  #selector(call(_:)), for: .touchUpInside)
        
        return cell
    }
    
        
    func dismissRec() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func menu(_ sender: UIButton) {
        
        UIApplication.shared.open(URL(string: website[sender.tag])!, options: [:], completionHandler: nil)
    }
    
    
    func map(_ sender: UIButton) {
        
        if (UIApplication.shared.canOpenURL(URL(string:"http://maps.google.com")!)) {
            let baseUrl : String = "http://maps.apple.com/?q="
            let encodedName = address[sender.tag].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let finalUrl = baseUrl + encodedName!
            UIApplication.shared.open(URL(string: finalUrl)!, options: [:], completionHandler: nil)

        }
        else if (UIApplication.shared.canOpenURL(URL(string:"http://maps.apple.com")!)) {
            
            let baseUrl : String = "http://maps.apple.com/?q="
            let encodedName = address[sender.tag].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let finalUrl = baseUrl + encodedName!
            UIApplication.shared.open(URL(string: finalUrl)!, options: [:], completionHandler: nil)
        } else {
            print("Can't use Apple Maps");
        }

        
    }
    
    func call(_ sender: UIButton) {
        
        
        if let phoneCallURL:URL = URL(string: "tel:\(phoneNumber[sender.tag].digits)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
}

extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

extension String {
    
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined(separator: "")
    }
}
