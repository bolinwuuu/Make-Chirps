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

    
    @IBOutlet weak var scrollView: UIScrollView!
    
    // the view embeded in the scrollView, containing all items
    @IBOutlet weak var contentView: UIView!
    
    // the view containing the sliders and text fields
    @IBOutlet weak var sliderRegionView: UIView!
    
    @IBOutlet weak var colorThemeButton: UIButton!
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    @IBOutlet weak var mass1Slider: UISlider!
    
    @IBOutlet weak var mass2Slider: UISlider!
    
    @IBOutlet weak var speedSlider: UISlider!
    
//    @IBOutlet weak var mass1Label: UILabel!
//
//    @IBOutlet weak var mass2Label: UILabel!
    
    @IBOutlet weak var mass1TextField: UITextField!
    
    @IBOutlet weak var mass2TextField: UITextField!
    
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
    
    var frameProp = 0.75
    
    // rectangle frame, used by spectrogram
    var frameRect: CGRect!
    var frameRect2: CGRect!
    
    var audioPlayer: AVAudioPlayer?
    
    let navigationBarHeight: Double = 120
    
    // value that colorThemeButton controls
    var isLightTheme: Bool = true
    
    // UIImage for light theme button
    var lightThemeImage: UIImage!
    
    // UIImage for dark theme button
    var darkThemeImage: UIImage!
    
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
    
    var timer: Timer?
    
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
    
    var backgroundImageView: UIImageView!
    
    //        Collsion Animation Variables ends             //
    //------------------------------------------------------//
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.view.addGestureRecognizer(tapGesture)

        
        let frameRect_w: Double = self.view.frame.size.width * frameProp
        let frameRect_h: Double = self.view.frame.size.width * frameProp
        let frameRect_x: Double = self.view.frame.size.width * (1 - frameProp) / 2
        let frameRect_y: Double = centerFromTop - frameRect_h / 2
        
        // For use by wavelength and frequency
        frameRect = CGRect(x: frameRect_x,
                           y: frameRect_y,
                           width: frameRect_w * (10/11),
                           height: frameRect_h * (10/11))
        
        frameRect2 = CGRect(x: frameRect_x,
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
        windowFrame.layer.borderWidth = 10
        windowFrame.layer.borderColor = UIColor.black.cgColor
        windowFrame.layer.cornerRadius = 50
        windowFrame.backgroundColor = UIColor.white
        
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
//        view.addSubview(windowFrame)
        contentView.addSubview(windowFrame)
//        windowFrame.center = CGPoint(x: contentView.bounds.midX, y: centerFromTop - navigationBarHeight)
        windowFrame.center = CGPoint(x: contentView.bounds.midX, y: centerFromTop)

        scrollView.isScrollEnabled = false
        
        // for automatically scrolling up when the keyboard appears
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        sliderRegionView.layer.cornerRadius = 30
        
        let colorThemeButtonConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large)
        
        lightThemeImage = UIImage(systemName: "sun.max.circle", withConfiguration: colorThemeButtonConfig)
        
        darkThemeImage = UIImage(systemName: "moon.circle", withConfiguration: colorThemeButtonConfig)
        
        colorThemeButton.setImage(lightThemeImage, for: .normal)
        
        // add blank background image view
        backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        self.view.insertSubview(backgroundImageView, at: 0)
        self.view.sendSubviewToBack(backgroundImageView)
        
        setLightTheme()
        

    }

    @IBAction func mass1Change(_ sender: Any) {
//        mass1Label.text = "\(roundToTwoDecimalPlaces(num: Double(mass1Slider.value)))"
        mass1TextField.text = "\(roundToTwoDecimalPlaces(num: Double(mass1Slider.value)))"
    }
    
    @IBAction func mass2Change(_ sender: Any) {
//        mass2Label.text = "\(roundToTwoDecimalPlaces(num: Double(mass2Slider.value)))"
        mass2TextField.text = "\(roundToTwoDecimalPlaces(num: Double(mass2Slider.value)))"
    }
    
    @IBAction func mass1TextChange(_ sender: Any) {
        if (!isDecimalNumber(str: mass1TextField.text!)) {
            // input is not a number
            print("input is not a number!")
            mass1TextField.text = String(roundToTwoDecimalPlaces(num: Double(mass1Slider.value)))
            
            let alertController = UIAlertController(title: "Invalid Input", message: "Please enter a valid number.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(OKAction)

            present(alertController, animated: true)
            
        } else if (Double(mass1TextField.text!)! < 1.4) {
            // input is smaller than min value
            mass1TextField.text = "1.4"
            
            let alertController = UIAlertController(title: "Invalid Input", message: "Please enter a number larger than 1.4.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(OKAction)

            present(alertController, animated: true)
        } else if (Double(mass1TextField.text!)! > 100) {
            // input is larger than max value
            mass1TextField.text = "100.0"
            
            let alertController = UIAlertController(title: "Invalid Input", message: "Please enter a number smaller than 100.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(OKAction)

            present(alertController, animated: true)
        }
        
        let roundedValue = roundToTwoDecimalPlaces(num: Double(mass1TextField.text!)!)
        mass1TextField.text = String(roundedValue)
        mass1Slider.value = Float(roundedValue)
    }
    
    @IBAction func mass2TextChange(_ sender: Any) {
        if (!isDecimalNumber(str: mass2TextField.text!)) {
            // input is not a number
            print("input is not a number!")
            mass2TextField.text = String(roundToTwoDecimalPlaces(num: Double(mass2Slider.value)))
            
            let alertController = UIAlertController(title: "Invalid Input", message: "Please enter a valid number.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(OKAction)

            present(alertController, animated: true)
            
        } else if (Double(mass2TextField.text!)! < 1.4) {
            // input is smaller than min value
            mass2TextField.text = "1.4"
            
            let alertController = UIAlertController(title: "Invalid Input", message: "Please enter a number larger than 1.4.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(OKAction)

            present(alertController, animated: true)
        } else if (Double(mass2TextField.text!)! > 100) {
            // input is larger than max value
            mass2TextField.text = "100.0"
            
            let alertController = UIAlertController(title: "Invalid Input", message: "Please enter a number smaller than 100.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(OKAction)

            present(alertController, animated: true)
        }
        
        let roundedValue = roundToTwoDecimalPlaces(num: Double(mass2TextField.text!)!)
        mass2TextField.text = String(roundedValue)
        mass2Slider.value = Float(roundedValue)
    }
    
    
    func roundToTwoDecimalPlaces(num: Double) -> Double {
        return round(num * 100) / 100.0
    }
    
    func isDecimalNumber(str: String) -> Bool {
//        return CharacterSet(charactersIn: str).isSubset(of: CharacterSet.decimalDigits)
        return str.range(
                         of: "^[0-9]+[.]?[0-9]*$", // 1
                         options: .regularExpression) != nil
    }
    
    func checkMassChange() {
            if (mass1 != Double(mass1Slider.value) || mass2 != Double(mass2Slider.value)) {
                mass1 = Double(mass1Slider.value)
                mass2 = Double(mass2Slider.value)
                removeViews()
                
                // invalidate the timer if it's working
                timer?.invalidate()
                
                testChirp.changeMasses(mass1: mass1, mass2: mass2)
        //        testSpect.refresh(run_chirp: &testChirp)
        //        spectUIIm = testSpect.genSpectrogram()
                
                animInit()
                audioInit()
                print("Re-initialize!")
            }
        }
    

    @IBAction func speedSliderChange(_ sender: Any) {
        speedLabel.text = " x \(round(speedSlider.value * 100) / 100.0)"
    }
    
    
    func removeViews() {
        // view.subviews.forEach({ $0.removeFromSuperview() })
//        print("CALLING removeViews()")
//        print("uiview before removing: \(uiview)")

        self.uiview.removeFromSuperview()
        // uiview.removeFromSuperview()
        // uiview = nil // TESTING
        uiview.isHidden = true
        self.chartView.removeFromSuperview()
        
        for subview in windowFrame.subviews {
            subview.removeFromSuperview()
        }
        
//        print("uiview after removing: \(uiview)")

        
        
        
      //  playButton.isHidden = true
      //  playButton.isEnabled = false
        
        self.body1.removeFromSuperview()
        self.body2.removeFromSuperview()
        body1.isHidden = true
        body2.isHidden = true
        xAxisLabel.isHidden = true
        yAxisLabel.isHidden = true
    }
    
    @IBAction func colorThemeButtonPress(_ sender: Any) {
        if (isLightTheme) {
            colorThemeButton.setImage(darkThemeImage, for: .normal)
            setDarkTheme()
            print("image set to moon")
        } else {
            colorThemeButton.setImage(lightThemeImage, for: .normal)
            setLightTheme()
            print("image set to sun")
        }
        isLightTheme = !isLightTheme
        print("color theme button pressed, light theme is \(isLightTheme)")
    }
    
    func setDarkTheme() {
        let darkPurple = UIColor(red: 40/255, green: 25/255, blue: 90/255, alpha: 1.0)
        let lightPurple = UIColor(red: 75/255, green: 50/255, blue: 130/255, alpha: 1.0)
//        view.backgroundColor = darkPurple
//        contentView.backgroundColor = darkPurple
        view.backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        sliderRegionView.backgroundColor = lightPurple
        
        setBackgroundImageView()
        
        colorThemeButton.tintColor = UIColor.white
    }
    
    func setLightTheme() {
        view.backgroundColor = UIColor.white
        contentView.backgroundColor = UIColor.white
        sliderRegionView.backgroundColor = UIColor.systemGray5
        
        colorThemeButton.tintColor = UIColor.systemBlue
    }
    

    @objc func keyboardWillShow(notification:NSNotification) {
        
        scrollView.isScrollEnabled = true
        
        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }
    
    func setBackgroundImageView() {

        backgroundImageView.image = UIImage(named: "gw_artist_image.jpeg")
        backgroundImageView.contentMode =  UIView.ContentMode.scaleAspectFill

    }

    @objc func keyboardWillHide(notification:NSNotification) {

//        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
//        scrollView.contentInset = contentInset

        scrollView.setContentOffset(CGPoint(x: 0, y: -navigationBarHeight), animated: true)
        
        scrollView.isScrollEnabled = false
    }
    

}

