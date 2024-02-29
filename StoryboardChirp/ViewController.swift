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
    
//    @IBOutlet weak var mass1Slider: UISlider!
//    
//    @IBOutlet weak var mass2Slider: UISlider!
//    
//    @IBOutlet weak var speedSlider: UISlider!
    
    var mass1Slider: CustomSlider!
    
    var mass2Slider: CustomSlider!
    
    var speedSlider: CustomSlider!

    
//    @IBOutlet weak var mass1Label: UILabel!
//
//    @IBOutlet weak var mass2Label: UILabel!
    
    @IBOutlet weak var mass1Title: UILabel!
    
    @IBOutlet weak var mass2Title: UILabel!
    
    @IBOutlet weak var animationSpeedTitle: UILabel!
    
    @IBOutlet weak var mass1TextField: UITextField!
    
    @IBOutlet weak var mass2TextField: UITextField!
    
    @IBOutlet weak var speedLabel: UILabel!
    
    var xAxisLabel = UILabel()
    
    var yAxisLabel = UILabel()
    
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
    
    @IBOutlet weak var mass1Info: UIButton!
    
    @IBOutlet weak var mass2Info: UIButton!
    
    @IBOutlet weak var speedInfo: UIButton!
    
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
    var isLightTheme: Bool = false
    
    // UIImage for light theme button
    var lightThemeImage: UIImage!
    
    // UIImage for dark theme button
    var darkThemeImage: UIImage!
    
    var orientationChanged: Bool = false
    
    let PADBUTTONFONTSIZE: CGFloat = 17
    let PHONEBUTTONFONTSIZE: CGFloat = 12
    
    //------------------------------------------------------//
    //            Collsion Animation Variables              //
    
    // Declare properties for the two celestial bodies
    var body1: UIView = UIView()
    var body2: UIView = UIView()
    var concentric1: UIView = UIView()
    var concentric2: UIView = UIView()
    
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
    var animationdownSample: Int = 100
    
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
    
    //------------------------------------------------------//
    //            Tutorial Variables              //
    @IBOutlet weak var tutorialView: UIView!
    
    @IBOutlet weak var pageDots: UIPageControl!
    
    // the Start button that ends the tutorials
    @IBOutlet weak var tutorialEndButton: UIButton!
    
    @IBOutlet weak var tutorialImageView: UIImageView!
    
    @IBOutlet weak var tutorialTitle: UILabel!
    
    @IBOutlet weak var tutorialButton: UIButton!
    
    var currentTutorialPage: Int = 1
    var totalTutorialPageCount: Int = 3
    
    // true if the tutorial pages are displayed on the screen
    var displayingTutorial = false
    //        Collsion Animation Variables ends             //
    //------------------------------------------------------//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTutorialIfNeeded()
        
        setBackgroundImageView()
        
        view.backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        setupSliderRegion()
        
        setupButtons()
        
        adjustUIAccordingToOrientation()
        contentView.addSubview(windowFrame)
        
        uiview.isHidden = true
        
//        playButton.isHidden = true
//        playButton.isEnabled = false
        
        body1.isHidden = true
        body2.isHidden = true
        
        animInit()
        audioInit()

        scrollView.isScrollEnabled = false
        
        // for automatically scrolling up when the keyboard appears
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        //Looks for single or multiple taps.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
//        sliderRegionView.layer.cornerRadius = 30
        

    }
    
    override func viewWillTransition(to size: CGSize, 
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        orientationChanged = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if orientationChanged {
            adjustUIAccordingToOrientation()
            
            orientationChanged = false
        }
    }
    
    func setupButtons() {
        setupFunctionalButtons()
        
        setupInfoButtons()
        
        setupTutorialAndColorThemeButtons()
        
    }
    
    func setupFunctionalButtons() {
        let buttonBackground = UIColor(red: 255/255, green: 120/255, blue: 40/255, alpha: 1)
        let buttonForeground: UIColor = .white
        let buttonShadow = UIColor(red: 225/255, green: 85/255, blue: 0/255, alpha: 1)
        
        for bttn in [waveformButton, freqButton, spectroButton, audioButton, animButton, spiralButton] {
            // set up colors
            bttn?.configuration?.baseBackgroundColor = buttonBackground
            bttn?.configuration?.baseForegroundColor = buttonForeground
            bttn?.layer.shadowColor = buttonShadow.cgColor
            
            bttn?.layer.shadowOffset = CGSize(width: 0, height: (bttn?.frame.height)! / 8)
            bttn?.layer.shadowOpacity = 1.0
            bttn?.layer.shadowRadius = 2.0
            bttn?.layer.masksToBounds = false
            bttn?.layer.cornerRadius = 4.0
            bttn?.configuration?.cornerStyle = .large
//            bttn!.configuration?.attributedTitle?.font = UIFont(name: "Helvetica", size: buttonFontSize)
        }
    }
    
    func setupInfoButtons() {
        let infoTint = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        for infobttn in [waveformInfo, freqInfo, spectroInfo, audioInfo, animInfo, spiralInfo] {
            infobttn?.tintColor = infoTint
        }
    }
    
    func setupTutorialAndColorThemeButtons() {
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, 
                                                       scale: UIDevice.current.userInterfaceIdiom == .pad ? .large : .medium)
        
        lightThemeImage = UIImage(systemName: "sun.max.circle", withConfiguration: buttonConfig)
        
        darkThemeImage = UIImage(systemName: "moon.circle", withConfiguration: buttonConfig)

        if isLightTheme {
            setLightTheme()
        } else {
            setDarkTheme()
        }
        
        tutorialButton.setImage(UIImage(systemName: "lightbulb.circle", withConfiguration: buttonConfig), for: .normal)
    }
    
    func setupSliderRegion() {
        let opaqueDarkGray = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        
        // slider region
        setupSliders()
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
        
//        for slider in [mass1Slider, mass2Slider, speedSlider] {
//            slider?.tintColor = .systemBlue
//        }
        // slider region ends
        
//        changeThemeButton()
    }
    
    func setupSliders() {
        mass1Slider = CustomSlider(frame: CGRect())
        mass2Slider = CustomSlider(frame: CGRect())
        speedSlider = CustomSlider(frame: CGRect())
        
        mass1Slider.addTarget(self, action: #selector(self.mass1Change(_:)), for: .valueChanged)
        mass2Slider.addTarget(self, action: #selector(self.mass2Change(_:)), for: .valueChanged)
        speedSlider.addTarget(self, action: #selector(self.speedSliderChange(_:)), for: .valueChanged)
        
        sliderRegionView.addSubview(mass1Slider)
        sliderRegionView.addSubview(mass2Slider)
        sliderRegionView.addSubview(speedSlider)
        
        mass1Slider.maximumValue = 100
        mass1Slider.minimumValue = 1.4
        mass2Slider.maximumValue = 100
        mass2Slider.minimumValue = 1.4
        speedSlider.maximumValue = 1
        speedSlider.minimumValue = 0.01
        
//        mass1Slider.value = 20
//        mass2Slider.value = 20
//        speedSlider.value = 0.05
        mass1Slider.changeSliderValue(value: 20.0)
        mass2Slider.changeSliderValue(value: 20.0)
        speedSlider.changeSliderValue(value: 0.05)
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
//        mass1Slider.value = Float(roundedValue)
        mass1Slider.changeSliderValue(value: Float(roundedValue))
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
//        mass2Slider.value = Float(roundedValue)
        mass2Slider.changeSliderValue(value: Float(roundedValue))
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
        chartView.removeFromSuperview()
        
        for subview in windowFrame.subviews {
            subview.removeFromSuperview()
        }
        
        self.body1.removeFromSuperview()
        self.body2.removeFromSuperview()
        body1.isHidden = true
        body2.isHidden = true
        xAxisLabel.removeFromSuperview()
        yAxisLabel.removeFromSuperview()
    }
    
    @IBAction func colorThemeButtonPress(_ sender: Any) {
        isLightTheme = !isLightTheme
        if (!isLightTheme) {
            setDarkTheme()
            print("image set to moon")
        } else {
            setLightTheme()
            print("image set to sun")
        }
        print("color theme button pressed, light theme is \(isLightTheme)")
    }
    
    func setDarkTheme() {
        colorThemeButton.setImage(darkThemeImage, for: .normal)

        windowFrame.layer.borderColor = UIColor.darkGray.cgColor
        windowFrame.backgroundColor = .black
        
        xAxisLabel.textColor = .white
        yAxisLabel.textColor = .white
        
        if chartView.isDescendant(of: windowFrame) && chartView.window != nil {
            print("change chartView color to dark mode")
            chartView.xAxis.axisLineColor = NSUIColor.white
            chartView.leftAxis.axisLineColor = NSUIColor.white
            chartView.xAxis.labelTextColor = .white
            chartView.leftAxis.labelTextColor = .white
            chartView.animate(xAxisDuration: 0.01)
        }
    }
    
    func setLightTheme() {
        colorThemeButton.setImage(lightThemeImage, for: .normal)
        
        windowFrame.layer.borderColor = UIColor.black.cgColor
        windowFrame.backgroundColor = .white
        
        xAxisLabel.textColor = .black
        yAxisLabel.textColor = .black
        
        if chartView.isDescendant(of: windowFrame) && chartView.window != nil {
            print("change chartView color to light mode")
            chartView.xAxis.axisLineColor = NSUIColor.lightGray
            chartView.leftAxis.axisLineColor = NSUIColor.lightGray
            chartView.xAxis.labelTextColor = .black
            chartView.leftAxis.labelTextColor = .black
            chartView.animate(xAxisDuration: 0.01)
        }
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
        // add blank background image view
        backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        self.view.insertSubview(backgroundImageView, at: 0)
        self.view.sendSubviewToBack(backgroundImageView)
//        backgroundImageView.image = UIImage(named: "gw_artist_image.jpeg")
//        backgroundImageView.image = UIImage(named: "gw_spiral_purple.jpeg")
//        backgroundImageView.image = UIImage(named: "gw_spiral_bw.jpeg")
        backgroundImageView.image = UIImage(named: "Panorama_edited2.png")
        backgroundImageView.contentMode =  UIView.ContentMode.scaleAspectFill

    }

    @objc func keyboardWillHide(notification:NSNotification) {

//        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
//        scrollView.contentInset = contentInset

        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        scrollView.isScrollEnabled = false
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
}


