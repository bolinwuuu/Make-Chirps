//
//  AnimationViewController.swift
//  StoryboardChirp
//
//  Created by Bolin Wu on 2/3/23.
//

import UIKit
import Accelerate

class AnimationViewController: UIViewController {

    // Declare properties for the two celestial bodies
    var body1: UIView!
    var body2: UIView!
    
    // Declare constants for the masses of the two celestial bodies
    let mass1: Double
    let mass2: Double
    
    // Declare constants for the gravitational constant and the initial distance between the two celestial bodies
    let G: Double = 6.67e-11
    let msun: Double = 2.0e30;
    let initialDistance: Double
    
    // Declare the vectors of frequency and semi-major axis
    var freq: [Double]
    var a: [Double]
    
    let lastSamp: Int
    
    // Declare a timer that will be used to update the positions of the celestial bodies
    var timer: Timer!
    
    // Declare a property to store the current time
    var currentTime: Double = 0.0
    
    // Declare properties to store the current positions and velocities of the celestial bodies
    var x1: Double
    var y1: Double
    var x2: Double
    var y2: Double
    var vx1: Double
    var vy1: Double
    var vx2: Double
    var vy2: Double
    
    // Animation downSample factor
    let animationdownSample: Int = 8
    
    // Initialize the ViewController with the masses of the celestial bodies and the initial distance between them
    init(mass1: Double, mass2: Double, freq: inout [Double]) {
        self.mass1 = mass1
        self.mass2 = mass2
        self.lastSamp = Int(testChirp.getLastSample())
        
        self.freq = freq
        let temp_coeff = pow(G * (mass1 + mass2) * msun / pow(Double.pi, 2), 1/3)
        self.a = freq.map { (pow($0, -2/3)) }
        vDSP.multiply(temp_coeff, a, result: &a)
        
        initialDistance = a[0] / 100
        
        // Initialize the positions and velocities of the celestial bodies
        x1 = 0.0
        y1 = 0.0
        x2 = initialDistance
        y2 = 0.0
        vx1 = 0.0
        vy1 = 0.0
        vx2 = 0.0
        vy2 = 0.0
        
        super.init(nibName: nil, bundle: nil)
    }
    

    
    required init?(coder: NSCoder) {
        // Initialize the constants for the masses of the celestial bodies and the initial distance between them
        mass1 = testChirp.getM1()
        mass2 = testChirp.getM2()
        self.lastSamp = Int(testChirp.getLastSample())
        
        self.freq = testChirp.getFreq()
        //self.freq[self.lastSamp] = test.extendedFreq()
        vDSP.fill(&self.freq[self.lastSamp + 1...self.lastSamp + animationdownSample],
                  with: testChirp.extendedFreq())
        
        
        let temp_coeff = pow(G * (mass1 + mass2) * msun / pow(Double.pi, 2), 1/3)
        self.a = freq.map { (pow($0, -2/3)) }
        vDSP.multiply(temp_coeff, a, result: &a)
        
        initialDistance = a[0] / 1000
        
        print("initialDist: ", initialDistance)
        
        // Initialize the positions and velocities of the celestial bodies
        x1 = initialDistance * mass2 / (mass1 + mass2)
        y1 = 0.0
        x2 = -initialDistance * mass1 / (mass1 + mass2)
        y2 = 0.0
        vx1 = 0.0
        vy1 = 0.0
        vx2 = 0.0
        vy2 = 0.0

        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let radius1 = Int(testChirp.getR1() / 1000)
        let radius2 = Int(testChirp.getR2() / 1000)
        
        // Initialize the celestial bodies as circular views
        body1 = UIView(frame: CGRect(x: 0, y: 0, width: radius1 * 2, height: radius1 * 2))
        body1.layer.cornerRadius = CGFloat(radius1)
        body1.backgroundColor = .blue
        view.addSubview(body1)
        
        body2 = UIView(frame: CGRect(x: 0, y: 0, width: radius2 * 2, height: radius2 * 2))
        body2.layer.cornerRadius = CGFloat(radius2)
        body2.backgroundColor = .red
        view.addSubview(body2)
        
        
        print("radius1: ", radius1)
        print("radius2: ", radius2)
        print("radius sum: ", radius1 + radius2)
        
        //let animationdownSample = 8
        
        var phi1: Double = 0.0
        var phi2: Double = Double.pi
        
        var samp: Int = 1

        
        let dt = testChirp.getDT()
        
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in

            // Check if the celestial bodies have collided
            if (samp > self!.lastSamp) {
                // Invalidate the timer to stop the animation
                //print("collide!")
                print("current samp: ", samp)
                print("final Dist: ", self!.a[samp] / 1000)
                self?.timer.invalidate()
                
                // Display an alert indicating that the celestial bodies have collided
                let alert = UIAlertController(title: "Collision", message: "The celestial bodies have collided!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
            
            
            // Update the current time
            self?.currentTime += 0.01
            
            let deltaphi: Double = 2 * Double.pi * (self!.freq[samp - 1] + self!.freq[samp]) * dt
            
            phi1 += deltaphi
            phi2 += deltaphi
            
            // update new distances to center
            let distToCenter1 = self!.a[samp] / 1000 * self!.mass2 / (self!.mass1 + self!.mass2)
            let distToCenter2 = self!.a[samp] / 1000 * self!.mass1 / (self!.mass1 + self!.mass2)

            
            // update the positions
            self!.x1 = distToCenter1 * cos(phi1);
            self!.y1 = distToCenter1 * sin(phi1);
            self!.x2 = distToCenter2 * cos(phi2);
            self!.y2 = distToCenter2 * sin(phi2);
            
            
            // Update the positions of the views that represent the celestial bodies on the screen
            self?.body1.center = CGPoint(x: self!.view.bounds.midX + CGFloat(self?.x1 ?? 0.0), y: self!.view.bounds.midY + CGFloat(self?.y1 ?? 0.0))
            self?.body2.center = CGPoint(x: self!.view.bounds.midX + CGFloat(self?.x2 ?? 0.0), y: self!.view.bounds.midY + CGFloat(self?.y2 ?? 0.0))
            
            
            samp += self!.animationdownSample
        }
    }
    
    func refreshView() {
        loadView()
    }

}
