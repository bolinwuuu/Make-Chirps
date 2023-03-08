//
//  AudioViewController.swift
//  StoryboardChirp
//
//  Created by Bolin Wu on 2/10/23.
//

import UIKit
import AVFoundation

class AudioViewController: UIViewController {

    var audioPlayer: AVAudioPlayer?
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // soundURL becomes the URL to the temporary .wav file.
        let soundURL = testChirp.saveWav1([testChirp.make_h_float(h: testChirp.h), testChirp.make_h_float(h: testChirp.h)])
        
        do{
            //Initialize audioPlayer node
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
        }
        catch{
            print("Could not intitialize AVAudioPlayer with the file")
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func AudioButton(_ sender: UIButton) {
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
        }


}
