//
//  VC_Collision.swift
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
    
    @IBAction func animButtonPress(_ sender: Any) {
        checkMassChange()
        removeViews()
        
        // Update animationdownSample according to speed slider
        let speedX = Double(speedSlider.value)
        animationdownSample = Int(ceil(0.01 * speedX / testChirp.getDT()))
        
        animInit()
        
        let currInitCount = initPressCount
        
//        let scaleDown: Double = 4000
        
        body1.isHidden = false
        body2.isHidden = false
        
        let radius1 = Int(testChirp.getR1() / scaleDown)
        let radius2 = Int(testChirp.getR2() / scaleDown)
        
        // Initialize the celestial bodies as circular views
        body1 = UIView(frame: CGRect(x: 0, y: 0, width: radius1 * 2, height: radius1 * 2))
        body1.layer.cornerRadius = CGFloat(radius1)
        body1.backgroundColor = .blue
//        view.addSubview(body1)
//        view.sendSubviewToBack(body1)
        windowFrame.addSubview(body1)
        
        body2 = UIView(frame: CGRect(x: 0, y: 0, width: radius2 * 2, height: radius2 * 2))
        body2.layer.cornerRadius = CGFloat(radius2)
        body2.backgroundColor = .red
//        view.addSubview(body2)
//        view.sendSubviewToBack(body2)
        windowFrame.addSubview(body2)
        
        
        print("radius1: ", radius1)
        print("radius2: ", radius2)
        print("radius sum: ", radius1 + radius2)
        
        //Ratio of the radius of mass1 to the window frame to calculate the scaled width of windowFrame
        let ratio = (Float(self.view.frame.size.width) * 0.77) / Float(radius1)
        print("ratio of window frame width to radius1: ",ratio)
        
        
        let lengthof_windowframe_km = Float(ratio) * Float(radius1) * 4
        
        
        
        let xAxisLabel = UILabel()
                xAxisLabel.text = "Width of Frame: about \(lengthof_windowframe_km) km"
                xAxisLabel.textAlignment = .center
                xAxisLabel.translatesAutoresizingMaskIntoConstraints = false
                windowFrame.addSubview(xAxisLabel)
                
        NSLayoutConstraint.activate([
                // X axis label constraints
                xAxisLabel.bottomAnchor.constraint(equalTo: windowFrame.bottomAnchor, constant: -14),
                xAxisLabel.centerXAnchor.constraint(equalTo: windowFrame.centerXAnchor),


            ])
        
        
        //let animationdownSample = 8
        
        var phi1: Double = 0.0
        var phi2: Double = Double.pi
        
        var samp: Int = 1

        
        let dt = testChirp.getDT()
        
        var timer: Timer!
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
                
//            print(self!.initPress)
            
            // Check if the celestial bodies have collided
            if (samp > self!.lastSamp || (self!.initPress[currInitCount])!) {
                // Invalidate the timer to stop the animation
                //print("collide!")
                print("current samp: ", samp)
                print("final Dist: ", self!.a[samp] / self!.scaleDown)
                timer.invalidate()
                
                self!.initPress.removeValue(forKey: currInitCount)
                
                // Display an alert indicating that the celestial bodies have collided
//                let alert = UIAlertController(title: "Collision", message: "The celestial bodies have collided!", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self?.present(alert, animated: true, completion: nil)
            }
            
            
            // Update the current time
            self?.currentTime += 0.01
            
            let deltaphi: Double = 2 * Double.pi * (self!.freq[samp - 1] + self!.freq[samp]) * (dt * Double(self!.animationdownSample))
            
            phi1 += deltaphi
            phi2 += deltaphi
            
            // update new distances to center
            let distToCenter1 = self!.a[samp] / self!.scaleDown * self!.mass2 / (self!.mass1 + self!.mass2)
            let distToCenter2 = self!.a[samp] / self!.scaleDown * self!.mass1 / (self!.mass1 + self!.mass2)

            
            // update the positions
            self!.x1 = distToCenter1 * cos(phi1);
            self!.y1 = distToCenter1 * sin(phi1);
            self!.x2 = distToCenter2 * cos(phi2);
            self!.y2 = distToCenter2 * sin(phi2);
            
            
            // Update the positions of the views that represent the celestial bodies on the screen
            
//            self?.body1.center = CGPoint(x: self!.view.bounds.midX + CGFloat(self?.x1 ?? 0.0), y: self!.centerFromTop + CGFloat(self?.y1 ?? 0.0))
//            self?.body2.center = CGPoint(x: self!.view.bounds.midX + CGFloat(self?.x2 ?? 0.0), y: self!.centerFromTop + CGFloat(self?.y2 ?? 0.0))
            self?.body1.center = CGPoint(x: self!.windowFrame.bounds.midX + CGFloat(self!.x1), y: self!.windowFrame.bounds.midY + CGFloat(self!.y1))
            self?.body2.center = CGPoint(x: self!.windowFrame.bounds.midX + CGFloat(self!.x2), y: self!.windowFrame.bounds.midY + CGFloat(self!.y2))
            
            
            samp += self!.animationdownSample
        }
        
    }
    
    func animInit() {
        
        
        // Initialize the constants for the masses of the celestial bodies and the initial distance between them
        
        initPress[initPressCount] = true
        initPressCount += 1
        initPress[initPressCount] = false
        
        mass1 = testChirp.getM1()
        mass2 = testChirp.getM2()
        self.lastSamp = Int(testChirp.getLastSample())
        
        self.freq = testChirp.getFreq()
        //self.freq[self.lastSamp] = test.extendedFreq()
        
        let freqCount = self.freq.count
        
        var lastPossIndex = min(self.lastSamp + animationdownSample, freqCount - 1)
        
        print("freqCount: ", freqCount)
        print("lastPossIndex: ", lastPossIndex)
        print("lastSamp: ", lastSamp)
        print("animationDownSample: ", animationdownSample)
        
        if (self.lastSamp < lastPossIndex) {
            vDSP.fill(&self.freq[self.lastSamp + 1...lastPossIndex],
                      with: testChirp.extendedFreq())
        }
        
        
        let temp_coeff = pow(G * (mass1 + mass2) * msun / pow(Double.pi, 2), 1/3)
        self.a = freq.map { (pow($0, -2/3)) }
        vDSP.multiply(temp_coeff, a, result: &a)
        
        initialDistance = a[0] / 1000
        
        print("initialDist: ", initialDistance)
        
        // Initialize the positions and velocities of the celestial bodies
//        x1 = initialDistance * mass2 / (mass1 + mass2)
//        y1 = 0.0
//        x2 = -initialDistance * mass1 / (mass1 + mass2)
//        y2 = 0.0
//        vx1 = 0.0
//        vy1 = 0.0
//        vx2 = 0.0
//        vy2 = 0.0
        
//        self.x1Pos = [Double](repeating: 0, count: freqCount)
//        self.y1Pos = [Double](repeating: 0, count: freqCount)
//        self.x2Pos = [Double](repeating: 0, count: freqCount)
//        self.y2Pos = [Double](repeating: 0, count: freqCount)
//        self.phi1 = [Double](repeating: 0, count: freqCount)
//        self.phi2 = [Double](repeating: 0, count: freqCount)
//        self.distToCenter1 = [Double](repeating: 0, count: freqCount)
//        self.distToCenter2 = [Double](repeating: 0, count: freqCount)
//
//        distToCenter1 = vDSP.multiply(self.mass2 / (self.mass1 + self.mass2) / self.scaleDown, self.a)
//        distToCenter1 = vDSP.multiply(self.mass1 / (self.mass1 + self.mass2) / self.scaleDown, self.a)
//
//        self.phi1[0] = 0
//        self.phi2[0] = Double.pi
//
//
//        let dt = testChirp.getDT()
//
//        for i in 1...freqCount - 1 {
//            let deltaphi: Double = 2 * Double.pi * (self.freq[i - 1] + self.freq[i]) * dt
//            self.phi1[i] = self.phi1[i - 1] + deltaphi
//            self.phi2[i] = self.phi2[i - 1] + deltaphi
//        }
        
    }
}
