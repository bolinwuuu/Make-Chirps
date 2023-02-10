//
//  ViewController.swift
//  StoryboardChirp
//
//  Created by Bolin Wu on 1/27/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mass1: UISlider!
    
    @IBOutlet weak var mass2: UISlider!
    
    @IBOutlet weak var mass1Label: UILabel!
    
    @IBOutlet weak var mass2Label: UILabel!
    
    @IBOutlet weak var intializeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func mass1Change(_ sender: Any) {
        mass1Label.text = "\(round(mass1.value * 100) / 100.0)"
    }
    
    @IBAction func mass2Change(_ sender: Any) {
        mass2Label.text = "\(round(mass2.value * 100) / 100.0)"
    }
    
    @IBAction func initializePress(_ sender: Any) {
        let m1 = Double(mass1.value)
        let m2 = Double(mass2.value)
        
        testChirp.changeMasses(mass1: m1, mass2: m2)
//        testSpect.refresh(run_chirp: &testChirp)
//        spectUIIm = testSpect.genSpectrogram()
    }
}

