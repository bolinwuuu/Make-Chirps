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
        // animationdownSample = 1
        
        animInit()
        
        
//        let scaleDown: Double = 4000
        
        body1.isHidden = false
        body2.isHidden = false
        
        
        // radius units; METERS / Scaledown ; "Scaledown Units"
        let radius1 = Int(ceil(testChirp.getR1() / scaleDown))
        let radius2 = Int(ceil(testChirp.getR2() / scaleDown))
        
       
        
        
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
        
//        //Ratio of the radius of mass1 to the window frame to calculate the scaled width of windowFrame
//        let ratio = (Float(self.view.frame.size.width) * 0.77) / Float(radius1)
//        print("ratio of window frame width to radius1: ",ratio)
//
//
//        let lengthof_windowframe_km = Float(ratio) * Float(radius1) * 4
        var concen1radius = Int(0)
        var concen2radius = Int(0)
        concentric1.isHidden = true
        concentric2.isHidden = true
        
        var ratioradii = Double(radius1) / Double(radius2)
        var ratioradiiinv = Double(radius2) / Double(radius1)
        
        if ratioradii <= Double(1.0/4.0) {
            concentric1.isHidden = false
            concen1radius = radius1 * 6
            if ratioradii < 1.0/8.0 {
                concen1radius = radius1 * 10
            }
            if ratioradii < 1.0/15.0{
                concen1radius = radius1*20
            }
        }
        
        if ratioradiiinv <= Double(1.0/4.0) {
            concentric2.isHidden = false
            concen2radius = radius2 * 6
            if ratioradiiinv < 1.0/8.0 {
                concen2radius = radius2 * 10
            }
            if ratioradiiinv < 1.0/15.0{
                concen2radius = radius2 * 20
            }
        }
        
        
        
        
        concentric1 = UIView(frame: CGRect(x: 0, y: 0, width: concen1radius, height: concen1radius))
        concentric1.backgroundColor = .clear
        concentric1.layer.cornerRadius=CGFloat(concen1radius / 2)
        concentric1.layer.borderWidth = 3
        concentric1.layer.borderColor = .init(red: 0, green: 0, blue: 1, alpha: 0.8)
       
        
        concentric2 = UIView(frame: CGRect(x: 0, y: 0, width: concen2radius, height: concen2radius))
        concentric2.backgroundColor = .clear
        concentric2.layer.cornerRadius=CGFloat(concen2radius / 2)
        concentric2.layer.borderWidth = 3
        concentric2.layer.borderColor = .init(red: 1, green: 0, blue: 0, alpha: 0.8)
        
        windowFrame.addSubview(concentric2)
        windowFrame.addSubview(concentric1)
        

        
        let lengthof_windowframe_km = Int(windowFrame.frame.width * scaleDown) / 1000
        // added /1000
        
        
//        let xAxisLabel = UILabel()
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
        
        // make the animation start at the last 10 seconds
        var samp: Int = max(1, lastSamp - Int(10.0 / 0.01) * animationdownSample)
        print("animation starts at index \(samp)")
        print("mass1 is \(mass1), mass2 is \(mass2)")
        // brutally fixing an index-out-of-bound bug when masses are 1.4 & 1.4
        if (mass1 == 1.4 && mass2 == 1.4) {
           // print ("old lastsamp: \(lastSamp)")
            lastSamp -= 1
            print("brutal solution triggered! New lastSamp: \(lastSamp)")
            
        }
        
        let dt = testChirp.getDT()
        
//        var timer: Timer!
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
                
            
            // Check if the celestial bodies have collided
            if (samp > self!.lastSamp) {
                // Invalidate the timer to stop the animation
                //print("collide!")
                print("current samp: ", samp)
                
                
//                print("a size: \(self!.a.count)")
//                print("final Dist: ", self!.a[samp] / self!.scaleDown)
                self!.timer?.invalidate()
                
                

            } else {
                
                
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
                self?.concentric1.center = CGPoint(x: self!.windowFrame.bounds.midX + CGFloat(self!.x1), y: self!.windowFrame.bounds.midY + CGFloat(self!.y1))
                self?.body2.center = CGPoint(x: self!.windowFrame.bounds.midX + CGFloat(self!.x2), y: self!.windowFrame.bounds.midY + CGFloat(self!.y2))
                self?.concentric2.center = CGPoint(x: self!.windowFrame.bounds.midX + CGFloat(self!.x2), y: self!.windowFrame.bounds.midY + CGFloat(self!.y2))

                
                
                samp += self!.animationdownSample
            }
        }
        
    }
    
    func animInit() {
        
        
        // Initialize the constants for the masses of the celestial bodies and the initial distance between them
        
        
        mass1 = testChirp.getM1()
        mass2 = testChirp.getM2()
        
        timer?.invalidate()
        
        
        let massSum = Double(mass1 + mass2)
        // A more discrete scaleDown in order to make it easier to see smaller mass star collisions. Large difference in the individual masses still makes it difficult. Need to point to really small masses
//        if mass1 + mass2 < 15{
//           scaleDown = 850
//        }
//        else if massSum >= 15 && massSum < 30 {
//            print("small masses, less scale down")
//            scaleDown = 1500
//        }
//        else if massSum >= 30 && massSum < 50{
//            scaleDown = 2000
//        }
//        else if massSum >= 50 && massSum < 100{
//            scaleDown = 3300
//        }
//        else {
//            print("large masses, more scale down")
//            scaleDown = 4000
//        }
        
        let scaleDownCoefficient = UIDevice.current.userInterfaceIdiom == .pad ? 60.0 : 130.0
        scaleDown = ceil(massSum / 5) * 5 * scaleDownCoefficient
         
      //  scaleDown = 1500
        print("scaledown factor: \(scaleDown)")

        
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
        
        
    }
}
