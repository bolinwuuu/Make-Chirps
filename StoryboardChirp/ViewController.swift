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
    
    @IBOutlet weak var xAxisLabel: UILabel!
    
    @IBOutlet weak var yAxisLabel: UILabel!
    
//    @IBOutlet weak var intializeButton: UIButton!
    
    @IBOutlet weak var waveformButton: UIButton!
    
    @IBOutlet weak var freqButton: UIButton!
    
    @IBOutlet weak var spectroButton: UIButton!
    
    @IBOutlet weak var audioButton: UIButton!
    
    @IBOutlet weak var animButton: UIButton!
    
    @IBOutlet weak var spiralButton: UIButton!
    
//    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(screenTapped(_:)))
    
    @IBOutlet weak var waveformInfo: UIButton!
    
    @IBOutlet weak var freqInfo: UIButton!
    
    //    @IBOutlet weak var playButton: UIButton!
    
    var windowFrame: UIView = UIView()
    
    var uiview: UIView = UIView()
    
    var chartView = LineChartView()
    
    var frameProp = 0.65
    
    // rectangle frame, used by spectrogram
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
        
//        self.view.addGestureRecognizer(tapGesture)

        
        let frameRect_w: Double = self.view.frame.size.width * frameProp
        let frameRect_h: Double = self.view.frame.size.width * frameProp
        let frameRect_x: Double = self.view.frame.size.width * (1 - frameProp) / 2
        let frameRect_y: Double = centerFromTop - frameRect_h / 2
        
        frameRect = CGRect(x: frameRect_x,
                           y: frameRect_y,
                           width: frameRect_w,
                           height: frameRect_h)
        
        uiview.isHidden = true
        
//        playButton.isHidden = true
//        playButton.isEnabled = false
        
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
        
        let axisLabel_w = 350
        let axisLabel_h = 34
        xAxisLabel.frame = CGRect(x: (Int(self.view.frame.size.width) - axisLabel_w) / 2,
                                  y: Int(centerFromTop + window_h / 2),
                                  width: axisLabel_w,
                                  height: axisLabel_h)
        xAxisLabel.textAlignment = .center
        
        yAxisLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        yAxisLabel.frame = CGRect(x: Int(window_x) - axisLabel_h / 2 - 20,
                                  y: Int(centerFromTop) - axisLabel_w / 2,
                                  width: axisLabel_h,
                                  height: axisLabel_w)
        yAxisLabel.textAlignment = .center
        
        
        xAxisLabel.isHidden = true
        yAxisLabel.isHidden = true
        view.addSubview(windowFrame)
        
    }

    @IBAction func mass1Change(_ sender: Any) {
        mass1Label.text = "\(round(mass1Slider.value * 100) / 100.0)"
    }
    
    @IBAction func mass2Change(_ sender: Any) {
        mass2Label.text = "\(round(mass2Slider.value * 100) / 100.0)"
    }
    
    
    func checkMassChange() {
        if (mass1 != Double(mass1Slider.value) || mass2 != Double(mass2Slider.value)) {
            mass1 = Double(mass1Slider.value)
            mass2 = Double(mass2Slider.value)
            removeViews()
            testChirp.changeMasses(mass1: mass1, mass2: mass2)
    //        testSpect.refresh(run_chirp: &testChirp)
    //        spectUIIm = testSpect.genSpectrogram()
            
            animInit()
            audioInit()
            print("Re-initialize!")
        }
    }
    
//    @IBAction func initializePress(_ sender: Any) {
//        let m1 = Double(mass1Slider.value)
//        let m2 = Double(mass2Slider.value)
//
//        removeViews()
//
//        testChirp.changeMasses(mass1: m1, mass2: m2)
////        testSpect.refresh(run_chirp: &testChirp)
////        spectUIIm = testSpect.genSpectrogram()
//
//        animInit()
//        audioInit()
//
////        initPress = true
//    }
//
//
//    @IBAction func playButtonPress(_ sender: Any) {
//        audioPlayer?.currentTime = 0
//        audioPlayer?.play()
//    }
    
    @IBAction func speedSliderChange(_ sender: Any) {
        speedLabel.text = "x \(round(speedSlider.value * 100) / 100.0)"
    }
    
    func removeViews() {
        self.uiview.removeFromSuperview()
        self.chartView.removeFromSuperview()
//        playButton.isHidden = true
//        playButton.isEnabled = false
        
        self.body1.removeFromSuperview()
        self.body2.removeFromSuperview()
        body1.isHidden = true
        body2.isHidden = true
        xAxisLabel.isHidden = true
        yAxisLabel.isHidden = true
    }

    

}

