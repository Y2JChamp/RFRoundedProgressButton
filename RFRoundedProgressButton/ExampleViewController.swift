//
//  ExampleViewController.swift
//  RFRoundedProgressButton
//
//  Created by Raffaele Forgione on 14/02/2020.
//  Copyright © 2020 Raffaele Forgione. All rights reserved.
//

import UIKit

class ExampleViewController: UIViewController {
    
    @IBOutlet weak var button: RFProgressButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    @IBAction func didTapCountdown(_ sender: Any) {
        button.restartCountDown(withSeconds: 10, withForegroundCompletion: {
            print("foreground")
        }) {
            print("background")
        }
    }
    
}

