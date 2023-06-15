//
//  VC_Spiral.swift
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
    
    @IBAction func spiralButtonPress(_ sender: Any) {
        checkMassChange()
        removeViews()
        
        testChirp.initSpiral()
        
        let speedX = Double(speedSlider.value)
        let spiralUIIm = testChirp.genSpiralAnimation(speedX: speedX)
        
//        spectView = Spectrogram()
//        uiview = UIView(frame: frameRect)
        
        uiview = UIImageView(image: spiralUIIm)
        uiview.frame = frameRect
        uiview.center = windowFrame.center
        
        let xAxisLabel = UILabel()
                xAxisLabel.text = "Width of Frame: about 2500 km"
                xAxisLabel.textAlignment = .center
                xAxisLabel.translatesAutoresizingMaskIntoConstraints = false
                windowFrame.addSubview(xAxisLabel)
                
        NSLayoutConstraint.activate([
                // X axis label constraints
                xAxisLabel.bottomAnchor.constraint(equalTo: windowFrame.bottomAnchor, constant: -14),
                xAxisLabel.centerXAnchor.constraint(equalTo: windowFrame.centerXAnchor),


            ])
        
        print("spiral duration: ", spiralUIIm.duration)
        displaySpiralWithTime(duration: Double(spiralUIIm.duration))
        
    }
    
    // for spiral animation
    func displaySpiralWithTime(duration: Double) {
//        self.view.bringSubviewToFront(spiralView)
//        self.uiview.removeFromSuperview()
        view.addSubview(uiview)
        
        UIView.animate(withDuration: 0, delay: duration, animations: {
            self.uiview.alpha = 0
        }) {_ in
//            self.uiview.removeFromSuperview()
            
        }
    }
}
