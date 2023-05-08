//
//  VC_Audio.swift
//  StoryboardChirp
//
//  Created by Bolin Wu on 5/8/23.
//

import SwiftUI
import UIKit
import Charts
import AVFoundation
import Accelerate

extension ViewController {
    
    @IBAction func audioButtonPress(_ sender: Any) {
//        removeViews()
//
//        playButton.isHidden = false
//        playButton.isEnabled = true
//
//        let soundURL = testChirp.saveWav1([testChirp.make_h_float(h: testChirp.h), testChirp.make_h_float(h: testChirp.h)])
//
//        do{
//            //Initialize audioPlayer node
//            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
//        }
//        catch{
//            print("Could not intitialize AVAudioPlayer with the file")
//        }
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
    }
    
    // initialize audio when init button is pressed
    func audioInit() {
//        removeViews()
        
//        playButton.isHidden = false
//        playButton.isEnabled = true
        
        let soundURL = testChirp.saveWav1([testChirp.make_h_float(h: testChirp.h), testChirp.make_h_float(h: testChirp.h)])
        
        do{
            //Initialize audioPlayer node
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
        }
        catch{
            print("Could not intitialize AVAudioPlayer with the file")
        }
    }
}
