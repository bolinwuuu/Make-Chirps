//
//  VC_Spectro.swift
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
    
    @IBAction func spectroButtonPress(_ sender: Any) {
        checkMassChange()
        removeViews()
        
        xAxisLabel.isHidden = false
        yAxisLabel.isHidden = false
        
        xAxisLabel.text = "Time (s)"
        yAxisLabel.text = "Frequency (Hz)"
        
        
        testChirp.initSpectrogram()
        let spectUIIm = testChirp.genSpectrogram()

        uiview = UIView(frame: frameRect)

        uiview = UIImageView(image: spectUIIm)
        uiview.frame = frameRect

        
        view.addSubview(uiview)
    }
}
