//
//  ViewController.swift
//  Flashv3
//
//  Created by Chris on 11/26/16.
//  Copyright © 2016 Flash. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.performSegue(withIdentifier: "toLogin", sender: nil)
    })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

