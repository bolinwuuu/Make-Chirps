//
//  AudioViewController.swift
//  StoryboardChirp
//
//  Created by Bolin Wu on 2/10/23.
//

import UIKit
import AVFoundation

class AudioViewController: UIViewController {

    @IBAction func AudioButton(_ sender: UIButton) {
        testChirp.saveWav([testChirp.make_h_float(h: testChirp.h), testChirp.make_h_float(h: testChirp.h)])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    



}
