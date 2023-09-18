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
    
    @IBOutlet weak var mass1Title: UILabel!
    
    @IBOutlet weak var mass2Title: UILabel!
    
    @IBOutlet weak var animationSpeedTitle: UILabel!
    
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
    
    @IBOutlet weak var spectroInfo: UIButton!
    
    @IBOutlet weak var audioInfo: UIButton!
    
    @IBOutlet weak var animInfo: UIButton!
    
    @IBOutlet weak var spiralInfo: UIButton!
    
    //    @IBOutlet weak var playButton: UIButton!
    
    var windowFrame: UIView = UIView()
    
    var uiview: UIView = UIView()
    
    var spiralview: UIImageView = UIImageView()
    
    var chartView = LineChartView()
    
    var frameProp = 0.75
    
    // rectangle frame, used by spectrogram
    var frameRect: CGRect!
//    var frameRect2: CGRect!
    
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
    
    var centerFromTop: Double = 400
    
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
        centerFromTop = self.view.frame.height / 3
        
        frameProp = UIDevice.current.userInterfaceIdiom == .pad ? 0.75 : 0.9
        
        let frameRect_w: Double = self.view.frame.width * frameProp
        let frameRect_h: Double = self.view.frame.width * frameProp
//        let frameRect_x: Double = self.view.frame.width * (1 - frameProp) / 2
        let frameRect_x: Double = (self.view.frame.width - frameRect_w) / 2
        let frameRect_y: Double = centerFromTop - frameRect_h / 2
        
        // For use by wavelength and frequency
        frameRect = CGRect(x: frameRect_x,
                           y: frameRect_y,
                           width: frameRect_w * (10/11),
                           height: frameRect_h * (10/11))
        
        
//        frameRect2 = CGRect(x: frameRect_x,
//                           y: frameRect_y,
//                           width: frameRect_w,
//                           height: frameRect_h)
        
        uiview.isHidden = true
        
//        playButton.isHidden = true
//        playButton.isEnabled = false
        
        body1.isHidden = true
        body2.isHidden = true
        
        animInit()
        audioInit()
        
//        windowFrame
        let windowProp = frameProp + 0.02
        
        let window_w: Double = self.view.frame.width * windowProp
        let window_h: Double = self.view.frame.width * windowProp
//        let window_x: Double = self.view.frame.width * (1 - windowProp) / 2
        let window_x: Double = (self.view.frame.width - window_w) / 2
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
        xAxisLabel.frame = CGRect(x: (Int(self.view.frame.width) - axisLabel_w) / 2,
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

//        windowFrame.center = CGPoint(x: contentView.bounds.midX, y: centerFromTop)

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
        
        setupButtons()
        
        // ---------------------------------------------------------------------
        // adjust view frames
        
        // adjust slider region view
        sliderRegionView.frame = CGRect(origin: CGPoint(x: windowFrame.frame.origin.x,
                                                        y: windowFrame.frame.maxY),
                                        size: CGSize(width: windowFrame.frame.width * 2 / 3,
                                                     height: self.view.frame.maxY - windowFrame.frame.maxY - (self.tabBarController?.tabBar.frame.height)!))
        
        // adjust the sliders
        let sliderPadding: CGFloat = 0.05
        let sliderW = sliderRegionView.frame.width * 0.8
        let sliderH = sliderRegionView.frame.height / 13 // not working
        let sliderOriX = sliderRegionView.frame.width * 0.1
        var sliderOriY = sliderRegionView.frame.height * sliderPadding + sliderRegionView.frame.height * (1 - 2 * sliderPadding) / 6 - sliderH
        let sliderSize = CGSize(width: sliderW,
                                 height: sliderH)
        for sld in [mass1Slider, mass2Slider, speedSlider] {
            sld!.frame = CGRect(origin: CGPoint(x: sliderOriX,
                                                y: sliderOriY),
                                size: sliderSize)
//            sld!.thumb
            sliderOriY += sliderRegionView.frame.height * (1 - 2 * sliderPadding) / 3
        }
        print("slider frame: \(mass1Slider.frame)")
        print("slider width: \(mass1Slider.frame.width)")
        print("slider height: \(mass1Slider.frame.height)")
        
        // adjust the labels in slider region
        let massLabelH = sliderRegionView.frame.height / 10
        let massLabelW = massLabelH * 5
        let massLabelCenterX = mass1Slider.center.x
        var massLabelCenterY = mass1Slider.frame.origin.y - massLabelH / 2
        let massLabelFontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 27 : 18
        for masslbl in [mass1Title, mass2Title, animationSpeedTitle] {
            masslbl!.font = masslbl!.font.withSize(massLabelFontSize)
            masslbl!.frame.size = CGSize(width: massLabelW, height: massLabelH)
            masslbl!.center = CGPoint(x: massLabelCenterX, y: massLabelCenterY)
            massLabelCenterY += sliderRegionView.frame.height * (1 - 2 * sliderPadding) / 3
        }
        print("mass label frame: \(animationSpeedTitle.frame)")
        
        // adjust the textfields in slider region
        let textFieldH = massLabelH
        let textFieldW = textFieldH * 3
        let textFieldCenterX = massLabelCenterX
        var textFieldCenterY = mass1Slider.frame.maxY + textFieldH / 2
        let textFieldFontSize = massLabelFontSize
        for txtfld in [mass1TextField, mass2TextField, speedLabel] {
//            txtfld!.font = txtfld!.font.withSize(textFieldFontSize)
            txtfld!.frame.size = CGSize(width: textFieldW, height: textFieldH)
            txtfld!.center = CGPoint(x: textFieldCenterX, y: textFieldCenterY)
            textFieldCenterY += sliderRegionView.frame.height * (1 - 2 * sliderPadding) / 3
        }
        mass1TextField.font = mass1TextField.font?.withSize(textFieldFontSize)
        mass2TextField.font = mass2TextField.font?.withSize(textFieldFontSize)
        speedLabel.font = speedLabel.font?.withSize(textFieldFontSize)
        print("text field frame: \(mass1TextField.frame)")
        
        // adjust color theme button
        colorThemeButton.center = CGPoint(x: windowFrame.frame.maxX + 10,
                                          y: windowFrame.frame.minY + 100)
        
        // adjust functional buttons
        let buttonH = sliderRegionView.frame.height / 1.3 / 6
        let buttonLeftPadding: CGFloat = windowFrame.frame.width / 32
        let buttonW = windowFrame.frame.width - sliderRegionView.frame.width - buttonLeftPadding
        var buttonUpperPadding: CGFloat = (sliderRegionView.frame.height - 6 * buttonH) / 5
        var buttonFrameY: CGFloat = sliderRegionView.frame.origin.y
        let buttonFontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 22 : 13
        for bttn in [waveformButton, freqButton, spectroButton,
                     audioButton, animButton, spiralButton] {
            bttn!.configuration?.attributedTitle?.font = UIFont(name: "Helvetica", size: buttonFontSize)
            bttn!.frame = CGRect(origin: CGPoint(x: sliderRegionView.frame.maxX + buttonLeftPadding,
                                                y: buttonFrameY),
                                size: CGSize(width: buttonW, height: buttonH))
            buttonFrameY += bttn!.frame.height + buttonUpperPadding
        }
        
        // adjust info buttons
        let infoLeftPadding: CGFloat = buttonLeftPadding / 2
        let infoCenterDist: CGFloat = waveformButton.frame.height + buttonUpperPadding
        var infoCenterY: CGFloat = waveformButton.center.y
        for infobttn in [waveformInfo, freqInfo, spectroInfo,
                         audioInfo, animInfo, spiralInfo] {
            infobttn!.center = CGPoint(x: waveformButton.frame.maxX + infoLeftPadding,
                                       y: infoCenterY)
            infoCenterY += infoCenterDist
        }
        print("button frame: \(waveformButton.frame)")
//        waveformButton.frame = CGRect(origin: CGPoint(x: sliderRegionView.frame.maxX + buttonLeftPadding,
//                                                      y: sliderRegionView.frame.origin.y),
//                                      size: waveformButton.frame.size)
        
        print("self.view.height: \(self.view.frame.height)")
        print("self.view.width: \(self.view.frame.width)")
        print("windowframe.frame: \(windowFrame.frame)")
        print("sliderregion.frame: \(sliderRegionView.frame)")
        
//        if UIDevice.current.userInterfaceIdiom == .pad {
//
//        } else if UIDevice.current.userInterfaceIdiom == .phone {
//
//        }
        // END adjust view frames
        // ---------------------------------------------------------------------
    }
    
    func setupButtons() {
        for bttn in [waveformButton, freqButton, spectroButton, audioButton, animButton, spiralButton] {            
            // set up shadows
            bttn?.layer.shadowColor = UIColor.black.cgColor
            bttn?.layer.shadowOffset = CGSize(width: 0, height: 4)
            bttn?.layer.shadowOpacity = 1.0
            bttn?.layer.shadowRadius = 2.0
            bttn?.layer.masksToBounds = false
            bttn?.layer.cornerRadius = 4.0
        }
        
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
                mass1 = roundToTwoDecimalPlaces(num: Double(mass1Slider.value))
                mass2 = roundToTwoDecimalPlaces(num: Double(mass2Slider.value))
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
        spiralview.isHidden = true
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
        isLightTheme = !isLightTheme
        if (!isLightTheme) {
            colorThemeButton.setImage(darkThemeImage, for: .normal)
            setDarkTheme()
            print("image set to moon")
        } else {
            colorThemeButton.setImage(lightThemeImage, for: .normal)
            setLightTheme()
            print("image set to sun")
        }
        print("color theme button pressed, light theme is \(isLightTheme)")
    }
    
    func setDarkTheme() {
        let darkPurple = UIColor(red: 40/255, green: 25/255, blue: 90/255, alpha: 1.0)
        let lightPurple = UIColor(red: 75/255, green: 50/255, blue: 130/255, alpha: 1.0)
//        view.backgroundColor = darkPurple
//        contentView.backgroundColor = darkPurple
        let translucentGray = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
        let translucentDarkGray = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.85)
        let opaqueDarkGray = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
//        let translucentPurple = UIColor(red: 35/255, green: 10/255, blue: 115/255, alpha: 0.7)
        let translucentPurple = UIColor(red: 120/255, green: 100/255, blue: 180/255, alpha: 1)
        view.backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // slider region
//        sliderRegionView.backgroundColor = translucentDarkGray
        sliderRegionView.backgroundColor = opaqueDarkGray
        
        mass1Title.textColor = .white
        mass2Title.textColor = .white
        animationSpeedTitle.textColor = .white
        
        for txtfld in [mass1TextField, mass2TextField] {
            txtfld?.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
            txtfld?.textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        }
        
        speedLabel.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
        speedLabel.textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        
        for slider in [mass1Slider, mass2Slider, speedSlider] {
            slider?.tintColor = .systemBlue
        }
        // slider region ends
        
//        windowFrame.backgroundColor = translucentGray
        windowFrame.backgroundColor = .white
        

        changeThemeButton()

        
        setBackgroundImageView()
        
        colorThemeButton.tintColor = .white
    }
    
    func setLightTheme() {
        // purple theme
        let darkPurple = UIColor(red: 20/255, green: 10/255, blue: 60/255, alpha: 1)
        let panelPurple = UIColor(red: 45/255, green: 20/255, blue: 100/255, alpha: 1)
        let textfieldPurple = UIColor(red: 95/255, green: 70/255, blue: 150/255, alpha: 1)
        let buttonPink = UIColor(red: 200/255, green: 170/255, blue: 220/255, alpha: 1)
        let buttonYellow = UIColor(red: 255/255, green: 210/255, blue: 100/255, alpha: 1)

        view.backgroundColor = darkPurple
        contentView.backgroundColor = darkPurple
        
        // slider region
        sliderRegionView.backgroundColor = panelPurple
        
        mass1Title.textColor = .white
        mass2Title.textColor = .white
        animationSpeedTitle.textColor = .white
        
        for txtfld in [mass1TextField, mass2TextField] {
            txtfld?.backgroundColor = textfieldPurple
            txtfld?.textColor = .white
        }
        speedLabel.backgroundColor = textfieldPurple
        speedLabel.textColor = .white
        
        for slider in [mass1Slider, mass2Slider, speedSlider] {
            slider?.tintColor = buttonYellow
        }
        // slider region ends
        
        windowFrame.backgroundColor = .white
        
        
        changeThemeButton()
        
        colorThemeButton.tintColor = UIColor.systemBlue
    }
    
    func changeThemeButton() {
        var buttonBackground: UIColor!
        var buttonForeground: UIColor!
        var infoTint: UIColor!
        
        if isLightTheme {
            // white theme
            buttonBackground = .systemBlue
            buttonForeground = .white
            infoTint = .darkGray
            // white theme END
            
            // purple theme
            let darkPurple = UIColor(red: 20/255, green: 10/255, blue: 60/255, alpha: 1)
            let buttonPink = UIColor(red: 200/255, green: 170/255, blue: 220/255, alpha: 1)
            let buttonYellow = UIColor(red: 255/255, green: 210/255, blue: 100/255, alpha: 1)
            buttonBackground = buttonYellow
            buttonForeground = darkPurple
            infoTint = .lightGray
            // purple theme END
        } else {
            buttonBackground = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
            buttonForeground = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
            
//            buttonBackground = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
//            buttonForeground = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
            
            infoTint = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        }
        
        for bttn in [waveformButton, freqButton, spectroButton, audioButton, animButton, spiralButton] {
            bttn?.configuration?.baseBackgroundColor = buttonBackground
            bttn?.configuration?.baseForegroundColor = buttonForeground
        }
        
        for infobttn in [waveformInfo, freqInfo, spectroInfo, audioInfo, animInfo, spiralInfo] {
            infobttn?.tintColor = infoTint
        }
        
    }
    
//    func changeThemeSliderRegion() {
//
//    }

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

//        backgroundImageView.image = UIImage(named: "gw_artist_image.jpeg")
//        backgroundImageView.image = UIImage(named: "gw_spiral_purple.jpeg")
//        backgroundImageView.image = UIImage(named: "gw_spiral_bw.jpeg")
        backgroundImageView.image = UIImage(named: "Panorama_edited2.png")
        backgroundImageView.contentMode =  UIView.ContentMode.scaleAspectFill

    }

    @objc func keyboardWillHide(notification:NSNotification) {

//        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
//        scrollView.contentInset = contentInset

        scrollView.setContentOffset(CGPoint(x: 0, y: -navigationBarHeight), animated: true)
        
        scrollView.isScrollEnabled = false
    }
    

}

