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
        self.uiview.removeFromSuperview()

        removeViews()
        
        
//        uiview.center = windowFrame.center // new

        
//        view.addSubview(uiview)
        
        
//        let xAxisLabel = UILabel()
                xAxisLabel.text = "Time (seconds)"
                xAxisLabel.textAlignment = .center
                xAxisLabel.translatesAutoresizingMaskIntoConstraints = false
                windowFrame.addSubview(xAxisLabel)
                
//                let yAxisLabel = UILabel()
                yAxisLabel.text = "Frequency (Hz)"
                yAxisLabel.textAlignment = .center
                yAxisLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
                yAxisLabel.translatesAutoresizingMaskIntoConstraints = false
                windowFrame.addSubview(yAxisLabel)
        
        //xAxisLabel.center = chartView.center
        //yAxisLabel.center = chartView.center
        
        NSLayoutConstraint.activate([
                // X axis label constraints
                xAxisLabel.bottomAnchor.constraint(equalTo: windowFrame.bottomAnchor, constant: -14),
                xAxisLabel.centerXAnchor.constraint(equalTo: windowFrame.centerXAnchor),

                // Y axis label constraints
                yAxisLabel.leadingAnchor.constraint(equalTo: windowFrame.leadingAnchor, constant: -35),
                yAxisLabel.centerYAnchor.constraint(equalTo: windowFrame.centerYAnchor, constant: -23)
            ])
        
        
        testChirp.initSpectrogram()
        let spectUIIm = testChirp.genSpectrogram()

        // uiview = UIView(frame: frameRect) // This may be redundant as well ?

        uiview = UIImageView(image: spectUIIm)
        uiview.frame = frameRect // TESTING if this is the cause of the bug.
        
//        uiview.center = windowFrame.center // new Kurt 14.06

        
//        view.addSubview(uiview)
        
        windowFrame.addSubview(uiview) // embed the spectrogram in windowFrame

        uiview.center = CGPoint(x: windowFrame.bounds.midX, y: windowFrame.bounds.midY) // set the center to the center of windowFrame
        print("uiview frame: \(uiview.frame)")

    }
}
