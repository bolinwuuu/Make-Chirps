//
//  ViewController.swift
//  StoryboardChirp
//
//  Created by Bolin Wu on 1/27/23.
//

import SwiftUI
import UIKit
import Charts
import AVFoundation
import Accelerate

class ViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var mass1Slider: UISlider!
    
    @IBOutlet weak var mass2Slider: UISlider!
    
    @IBOutlet weak var speedSlider: UISlider!
    
    @IBOutlet weak var mass1Label: UILabel!
    
    @IBOutlet weak var mass2Label: UILabel!
    
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var intializeButton: UIButton!
    
    @IBOutlet weak var waveformButton: UIButton!
    
    @IBOutlet weak var freqButton: UIButton!
    
    @IBOutlet weak var spectroButton: UIButton!
    
    @IBOutlet weak var audioButton: UIButton!
    
    @IBOutlet weak var animButton: UIButton!
    
    @IBOutlet weak var spiralButton: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    
    var windowFrame: UIView = UIView()
    
    var uiview: UIView = UIView()
    
    var chartView = LineChartView()
    
    var frameProp = 0.65
    
    var frameRect: CGRect!
    
    var audioPlayer: AVAudioPlayer?
    
    //------------------------------------------------------//
    //            Collsion Animation Variables              //
    
    // Declare properties for the two celestial bodies
    var body1: UIView = UIView()
    var body2: UIView = UIView()
    
    // Declare constants for the masses of the two celestial bodies
    var mass1: Double = 0
    var mass2: Double = 0
    
    // Declare constants for the gravitational constant and the initial distance between the two celestial bodies
    let G: Double = 6.67e-11
    let msun: Double = 2.0e30;
    var initialDistance: Double = 0
    
    // Declare the vectors of frequency and semi-major axis
    var freq: [Double]!
    var a: [Double]!
    
    var lastSamp: Int = 0
    
    // Declare a timer that will be used to update the positions of the celestial bodies
//    var timer: Timer!
    
    // Declare a property to store the current time
    var currentTime: Double = 0.0
    
    // Declare properties to store the current positions and velocities of the celestial bodies
    var x1: Double!
    var y1: Double!
    var x2: Double!
    var y2: Double!
//    var vx1: Double!
//    var vy1: Double!
//    var vx2: Double!
//    var vy2: Double!
    
    // Animation downSample factor
    var animationdownSample: Int = 8
    
    var initPress: [Int: Bool] = [:]
    var initPressCount = 0
    
    let centerFromTop: Double = 400
    
//    var x1Pos: [Double] = []
//    var y1Pos: [Double] = []
//    var x2Pos: [Double] = []
//    var y2Pos: [Double] = []
//
//    var phi1: [Double] = []
//    var phi2: [Double] = []
//
//    var distToCenter1: [Double] = []
//    var distToCenter2: [Double] = []
    
    var scaleDown: Double = 4000
    
    
    
    //        Collsion Animation Variables ends             //
    //------------------------------------------------------//
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let frameRect_w: Double = self.view.frame.size.width * frameProp
        let frameRect_h: Double = self.view.frame.size.width * frameProp
        let frameRect_x: Double = self.view.frame.size.width * (1 - frameProp) / 2
        let frameRect_y: Double = centerFromTop - frameRect_h / 2
        
        frameRect = CGRect(x: frameRect_x,
                           y: frameRect_y,
                           width: frameRect_w,
                           height: frameRect_h)
        
        uiview.isHidden = true
        
        playButton.isHidden = true
        playButton.isEnabled = false
        
        body1.isHidden = true
        body2.isHidden = true
        
        animInit()
        audioInit()
        
//        windowFrame
        let windowProp = frameProp + 0.02
        
        let window_w: Double = self.view.frame.size.width * windowProp
        let window_h: Double = self.view.frame.size.width * windowProp
        let window_x: Double = self.view.frame.size.width * (1 - windowProp) / 2
        let window_y: Double = centerFromTop - window_h / 2
        
        windowFrame = UIView(frame: CGRect(x: window_x,
                                           y: window_y,
                                           width: window_w,
                                           height: window_h))
        windowFrame.layer.borderWidth = 8
        windowFrame.layer.borderColor = UIColor.black.cgColor
        view.addSubview(windowFrame)
    }

    @IBAction func mass1Change(_ sender: Any) {
        mass1Label.text = "\(round(mass1Slider.value * 100) / 100.0)"
    }
    
    @IBAction func mass2Change(_ sender: Any) {
        mass2Label.text = "\(round(mass2Slider.value * 100) / 100.0)"
    }
    
    @IBAction func initializePress(_ sender: Any) {
        let m1 = Double(mass1Slider.value)
        let m2 = Double(mass2Slider.value)
        
        removeViews()
        
        testChirp.changeMasses(mass1: m1, mass2: m2)
//        testSpect.refresh(run_chirp: &testChirp)
//        spectUIIm = testSpect.genSpectrogram()
        
        animInit()
        audioInit()
        
//        initPress = true
    }
    
    @IBAction func waveformButtonPress(_ sender: Any) {
        removeViews()
        
//        chartView = LineChartView()
        
        chartView.frame = frameRect
        
        view.addSubview(chartView)
        
        let set = LineChartDataSet(entries: testChirp.waveformDataEntries())
        set.drawCirclesEnabled = false
        set.colors = [NSUIColor](repeating: .systemBlue, count: set.colors.count)
        set.lineWidth = 30
        
        let data = LineChartData(dataSet: set)
        data.setDrawValues(false)
        
        chartView.data = data
        
        
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.axisLineColor = NSUIColor.lightGray
        chartView.xAxis.labelTextColor = .lightGray
        
        chartView.leftAxis.axisLineColor = NSUIColor.lightGray
        chartView.leftAxis.labelTextColor = .lightGray

        chartView.rightAxis.drawAxisLineEnabled = false
        chartView.rightAxis.drawLabelsEnabled = false
//
        chartView.legend.enabled = false
        
        chartView.animate(xAxisDuration: 2.5)
    }
    
    @IBAction func freqButtonPress(_ sender: Any) {
        removeViews()
        
//        chartView = LineChartView()
        
        chartView.frame = frameRect
        
        view.addSubview(chartView)
        
        let set = LineChartDataSet(entries: testChirp.freqDataEntries())
        set.drawCirclesEnabled = false
        set.colors = [NSUIColor](repeating: .systemBlue, count: set.colors.count)
        set.lineWidth = 30
        
        let data = LineChartData(dataSet: set)
        data.setDrawValues(false)
        
        chartView.data = data
        
        
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.axisLineColor = NSUIColor.lightGray
        chartView.xAxis.labelTextColor = .lightGray
        
        chartView.leftAxis.axisLineColor = NSUIColor.lightGray
        chartView.leftAxis.labelTextColor = .lightGray

        chartView.rightAxis.drawAxisLineEnabled = false
        chartView.rightAxis.drawLabelsEnabled = false
//
        chartView.legend.enabled = false
        
        chartView.animate(xAxisDuration: 2.5)
    }
    
    
    @IBAction func spectroButtonPress(_ sender: Any) {
        removeViews()
        
        testChirp.initSpectrogram()
        let spectUIIm = testChirp.genSpectrogram()

        uiview = UIView(frame: frameRect)

        uiview = UIImageView(image: spectUIIm)
        uiview.frame = frameRect

        
        view.addSubview(uiview)
    }
    
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
    
    
    @IBAction func playButtonPress(_ sender: Any) {
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
    }
    
    @IBAction func speedSliderChange(_ sender: Any) {
        speedLabel.text = "x \(round(speedSlider.value * 100) / 100.0)"
    }
    
    @IBAction func animButtonPress(_ sender: Any) {
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
        view.addSubview(body1)
        view.sendSubviewToBack(body1)
        
        body2 = UIView(frame: CGRect(x: 0, y: 0, width: radius2 * 2, height: radius2 * 2))
        body2.layer.cornerRadius = CGFloat(radius2)
        body2.backgroundColor = .red
        view.addSubview(body2)
        view.sendSubviewToBack(body2)
        
        
        print("radius1: ", radius1)
        print("radius2: ", radius2)
        print("radius sum: ", radius1 + radius2)
        
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
//            self?.body1.center = CGPoint(x: self!.view.bounds.midX + CGFloat(self?.x1 ?? 0.0), y: self!.view.bounds.midY + CGFloat(self?.y1 ?? 0.0))
//            self?.body2.center = CGPoint(x: self!.view.bounds.midX + CGFloat(self?.x2 ?? 0.0), y: self!.view.bounds.midY + CGFloat(self?.y2 ?? 0.0))
            
            self?.body1.center = CGPoint(x: self!.view.bounds.midX + CGFloat(self?.x1 ?? 0.0), y: self!.centerFromTop + CGFloat(self?.y1 ?? 0.0))
            self?.body2.center = CGPoint(x: self!.view.bounds.midX + CGFloat(self?.x2 ?? 0.0), y: self!.centerFromTop + CGFloat(self?.y2 ?? 0.0))
            
            
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
        
        vDSP.fill(&self.freq[self.lastSamp + 1...lastPossIndex],
                  with: testChirp.extendedFreq())
        
        
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
    
    @IBAction func spiralButtonPress(_ sender: Any) {
        removeViews()
        
        testChirp.initSpiral()
        
        let speedX = Double(speedSlider.value)
        let spiralUIIm = testChirp.genSpiralAnimation(speedX: speedX)
        
//        spectView = Spectrogram()
//        uiview = UIView(frame: frameRect)
        
        uiview = UIImageView(image: spiralUIIm)
        uiview.frame = frameRect

        displayWithTime(duration: Double(spiralUIIm.duration))
        
    }
    
    // for spiral animation
    func displayWithTime(duration: Double) {
//        self.view.bringSubviewToFront(spiralView)
//        self.uiview.removeFromSuperview()
        view.addSubview(uiview)
        
        UIView.animate(withDuration: 0, delay: duration, animations: {
            self.uiview.alpha = 0
        }) {_ in
//            self.uiview.removeFromSuperview()
            
        }
    }
    
    
    func removeViews() {
        self.uiview.removeFromSuperview()
        self.chartView.removeFromSuperview()
        playButton.isHidden = true
        playButton.isEnabled = false
        
        self.body1.removeFromSuperview()
        self.body2.removeFromSuperview()
        body1.isHidden = true
        body2.isHidden = true
    }
}

