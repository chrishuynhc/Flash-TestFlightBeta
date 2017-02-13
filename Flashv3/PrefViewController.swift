//
//  PrefViewController.swift
//  Flashv3
//
//  Created by Chris on 12/28/16.
//  Copyright © 2016 Flash. All rights reserved.
//

import UIKit
import Firebase

var minPrice = 1
var maxPrice = 3
var finalDistance : Int = 15
var restTypeArray = ["American", "Italian", "Mexican", "Korean", "Japanese", "", ""]
var open = true
var savedDefault = 0
var restType = ""
var prefIsThere = false

class PrefViewController: UIViewController, TagListViewDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    @IBOutlet weak var prefTags: TagListView!
    @IBOutlet weak var milesSlider: UISlider!
    @IBOutlet weak var miles: UILabel!
    @IBOutlet weak var low: UIButton!
    @IBOutlet weak var medium: UIButton!
    @IBOutlet weak var high: UIButton!
    @IBOutlet weak var prefTable: UITableView!
    
    var distance = 10
    var prefs = ["American", "Italian", "Mexican", "Korean", "Japanese", "Indian",
                 "Cajun", "Thai", "Greek", "Lebanese", "French", "German", "Vietnamese"]
    var filteredPrefs = [String]()
    var searchController: UISearchController!
    var resultsController = UITableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prefIsThere = true
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PrefViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //Preferences Title
        let logo = UIImage(named: "preferencesTitle")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        //Back Arrow
        let checkImage = UIImage(named: "redCheck")
        let check = UIBarButtonItem(image: checkImage, style: .plain, target: self, action: #selector(alertSaveDefault))
        check.tintColor = UIColor(red: 239/255.0, green: 96/255.0, blue: 86/255.0, alpha: 1)
        self.navigationItem.rightBarButtonItem = check
        
        prefTags.delegate = self
        prefTags.alignment = .left
        
        prefTags.textFont = UIFont.systemFont(ofSize: 14)
        prefTags.addTags(["American", "Italian", "Mexican", "Korean", "Japanese"])
        
        miles.text = String(Int(milesSlider.value))
        
        prefTable.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prefTable.reloadData()
    }
    
    //***Table View Protocol***//
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == prefTable {
            return self.prefs.count
        } else {
            return filteredPrefs.count
        }
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        
        print(currentCell.textLabel!.text!)
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        prefTable.layer.opacity = 1
        UIView.animate(withDuration: 0.5, animations: {self.prefTable.layer.opacity = 0})
        searchController.isActive = false
        prefTable.isHidden = true
        for index in 0...6 {
            if (restTypeArray[index] == currentCell.textLabel!.text!) {
                prefTags.removeTag(currentCell.textLabel!.text!)
                restTypeArray[index] = ""
            }
            
            if (restTypeArray[index] == "") {
                restTypeArray[index] = currentCell.textLabel!.text!
                prefTags.addTag(currentCell.textLabel!.text!)
                break
            } else {
                if (index == 6) {
                    open = false
                }
            }
        }
        
        if (open == false) {
            let alert = UIAlertController(title: "Oops!", message: "Only 7 preferences!", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
        for index in 0...6 {
            print(restTypeArray[index])
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        if tableView == prefTable {
            cell.textLabel?.text = self.prefs[indexPath.row]
        } else {
            cell.textLabel?.text = self.filteredPrefs[indexPath.row]
        }
        return cell
    }
    
    //***UISearchResultsUpdating Protocol***//
    func updateSearchResults(for searchController: UISearchController) {
        
        filteredPrefs = prefs.filter { (prefs: String) -> Bool in
            if prefs.contains(searchController.searchBar.text!) {
                return true
            } else {
                return false
            }
        }
        resultsController.tableView.reloadData()
    }
    
    //***Search Bar Functions***//
    @IBAction func searchBarOverlayButton(_ sender: Any) {
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        prefTable.isHidden = false
        prefTable.layer.opacity = 0
        UIView.animate(withDuration: 0.5, animations: {self.prefTable.layer.opacity = 1})
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
        searchController = UISearchController(searchResultsController: resultsController)
        prefTable.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.searchBar.becomeFirstResponder()
        
        let dismissImage = UIImage(named: "backArrow")
        let dismiss = UIBarButtonItem(image: dismissImage, style: .plain, target: self, action: #selector(dismissPrefTable))
        dismiss.tintColor = UIColor(red: 239/255.0, green: 96/255.0, blue: 86/255.0, alpha: 1)
        self.navigationItem.leftBarButtonItem = dismiss

    }
    
    func dismissPrefTable() {
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        prefTable.layer.opacity = 1
        UIView.animate(withDuration: 0.5, animations: {self.prefTable.layer.opacity = 0})
        searchController.isActive = false
        prefTable.isHidden = true
        definesPresentationContext = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func completeSelection() {
        
        restType = ""
        for index in 0...6 {
            if (restTypeArray[index] != "") {
                restType += (restTypeArray[index].lowercased() + "%7C")
            }
        }
        
        determineMinMax()
        finalDistance = Int(distance * 1609)
        
        //***SEND TO FIREBASE HERE***//
        let uid = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference(fromURL: "https://flash-85846.firebaseio.com/")
        let usersRef = ref.child("users").child(uid!).child("preferences")
        let values = ["cuisine": restType, "min": minPrice, "max": maxPrice, "distance": finalDistance] as [String : Any]
        usersRef.updateChildValues(values as [AnyHashable: Any], withCompletionBlock: {
            (err, ref) in
            
            if err != nil{
                print(err)
                return
            }
            print("Saved Info")
        })
        
        if (restType == "") {
            
            let alert = UIAlertController(title: "Error", message: "Please choose a restaurant type.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        } else {
            
            performSegue(withIdentifier: "prefToDash", sender: nil)
        }

    }
    
    //***Removing Tags***//
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title)")
        sender.removeTagView(tagView)
        
        for index in 0...6 {
            if (restTypeArray[index] == title) {
                restTypeArray[index] = ""
            }
        }
        open = true
    }
    
    func DismissKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        miles.text = String(Int(milesSlider.value))
        //distance = Int(milesSlider.value)
    }
    
    //Handling minimum and maximum prices based on selection
    var one$ = false
    var two$$ = false
    var three$$$ = false
    
    @IBAction func cash(_ sender: Any) {
        let pressedImg = UIImage(named: "$P")
        let notpressedImg = UIImage(named: "$O")
        
        if (low.isSelected == true) {
            low.setImage(notpressedImg, for: UIControlState())
            low.isSelected = false
            one$ = false
        } else {
            low.setImage(pressedImg, for: UIControlState())
            low.isSelected = true
            one$ = true
        }
    }
    
    @IBAction func cashCash(_ sender: Any) {
        let pressedImg = UIImage(named: "$$P")
        let notpressedImg = UIImage(named: "$$O")
        
        if (medium.isSelected == true) {
            medium.setImage(notpressedImg, for: UIControlState())
            medium.isSelected = false
            two$$ = false
        } else {
            medium.setImage(pressedImg, for: UIControlState())
            medium.isSelected = true
            two$$ = true
        }
    }
    
    @IBAction func cashCashCash(_ sender: Any) {
        let pressedImg = UIImage(named: "$$$P")
        let notpressedImg = UIImage(named: "$$$O")
        
        if (high.isSelected == true) {
            high.setImage(notpressedImg, for: UIControlState())
            high.isSelected = false
            three$$$ = false
        } else {
            high.setImage(pressedImg, for: UIControlState())
            high.isSelected = true
            three$$$ = true
        }
    }
    
    func determineMinMax() {
        if (one$ == true && two$$ == true && three$$$ == true){
            minPrice = 1
            maxPrice = 3
        }
        else if (one$ == true && two$$ == false && three$$$ == false) {
            minPrice = 1
            maxPrice = 1
        }
        else if (one$ == false && two$$ == true && three$$$ == false) {
            minPrice = 2
            maxPrice = 2
        }
        else if (one$ == false && two$$ == false && three$$$ == true) {
            minPrice = 3
            maxPrice = 3
        }
        else if (one$ == true && two$$ == true && three$$$ == false) {
            minPrice = 1
            maxPrice = 2
        }
        else if (one$ == false && two$$ == true && three$$$ == true) {
            minPrice = 2
            maxPrice = 3
        } else {
            minPrice = 1
            maxPrice = 3
        }
    }

    func alertSaveDefault() {
        //Alert View
        var alertController: UIAlertController?
        
        alertController = UIAlertController(title: "Preferences", message: "Do you want to save preferences as default?", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .default) {
            (action) -> Void in
            savedDefault = 0
            let uid = FIRAuth.auth()?.currentUser?.uid
            let ref = FIRDatabase.database().reference(fromURL: "https://flash-85846.firebaseio.com/")
            let usersRef = ref.child("users").child(uid!)
            let values = ["savedPreferences": savedDefault]
            usersRef.updateChildValues(values as [AnyHashable: Any], withCompletionBlock: {
                (err, ref) in
                
                if err != nil{
                    print(err)
                    return
                }
                print("Saved Info")
            })
            
            self.completeSelection()
        }
        let yesAction = UIAlertAction(title: "Yes", style: .default) {
            (action) -> Void in
            savedDefault = 1
            let uid = FIRAuth.auth()?.currentUser?.uid
            let ref = FIRDatabase.database().reference(fromURL: "https://flash-85846.firebaseio.com/")
            let usersRef = ref.child("users").child(uid!)
            let values = ["savedPreferences": savedDefault]
            usersRef.updateChildValues(values as [AnyHashable: Any], withCompletionBlock: {
                (err, ref) in
                
                if err != nil{
                    print(err)
                    return
                }
                print("Saved Info")
            })
            
            self.completeSelection()
        }
        
        alertController?.addAction(noAction)
        alertController?.addAction(yesAction)
        self.present(alertController!, animated: true, completion: nil)
    }
    
}
