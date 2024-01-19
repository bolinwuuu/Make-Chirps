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
        
        let imList = spiralUIIm.0
        print("imList size: \(imList.count)")
        
        let dur = spiralUIIm.1
        spiralview.animationImages = imList
        spiralview.animationDuration = dur
        spiralview.animationRepeatCount = 1
        spiralview.frame = frameRect
        spiralview.center = CGPoint(x: windowFrame.bounds.midX, y: windowFrame.bounds.midY) // set the center to the center of windowFrame
        
        // let uiview show the last frame of animation
        uiview = UIImageView(image: imList.last)
        uiview.frame = frameRect
        uiview.center = CGPoint(x: windowFrame.bounds.midX, y: windowFrame.bounds.midY) // set the center to the center of windowFrame
        
//        uiview = UIImageView(image: spiralUIIm)
//        uiview.frame = frameRect
////        uiview.center = windowFrame.center
//        uiview.center = CGPoint(x: windowFrame.bounds.midX, y: windowFrame.bounds.midY) // set the center to the center of windowFrame
        
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
        
        displaySpiralWithTime(duration: dur)
//        print("spiral duration: ", spiralUIIm.duration)
//        displaySpiralWithTime(duration: Double(spiralUIIm.duration))
        
    }
    
    // for spiral animation
    func displaySpiralWithTime(duration: Double) {
        spiralview.isHidden = false
        windowFrame.addSubview(uiview)
        windowFrame.addSubview(spiralview)
        
//        UIView.animate(withDuration: 0, delay: duration, animations: {
////            self.uiview.alpha = 0
//        }) {_ in
//
//        }
        spiralview.startAnimating()
    }
}
