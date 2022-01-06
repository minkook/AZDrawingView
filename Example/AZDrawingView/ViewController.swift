//
//  ViewController.swift
//  AZDrawingView
//
//  Created by minkook on 01/06/2022.
//  Copyright (c) 2022 minkook. All rights reserved.
//

import UIKit
import AZDrawingView

class ViewController: UIViewController {
    
    @IBOutlet weak var drawingView: AZDrawingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clearButtonAction(_ sender: Any) {
        drawingView.clear()
    }
    
    @IBAction func redoButtonAction(_ sender: Any) {
        drawingView.redo()
    }
    
    @IBAction func undoButtonAction(_ sender: Any) {
        drawingView.undo()
    }
    
}

