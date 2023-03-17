//
//  ViewController.swift
//  StoryboardChirp
//
//  Created by Bolin Wu on 1/27/23.
//

import UIKit
import Charts
import AVFoundation

class ViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var mass1: UISlider!
    
    @IBOutlet weak var mass2: UISlider!
    
    @IBOutlet weak var speedSlider: UISlider!
    
    @IBOutlet weak var mass1Label: UILabel!
    
    @IBOutlet weak var mass2Label: UILabel!
    
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var intializeButton: UIButton!
    
    @IBOutlet weak var waveformButton: UIButton!
    
    @IBOutlet weak var freqButton: UIButton!
    
    @IBOutlet weak var spectroButton: UIButton!
    
    @IBOutlet weak var audioButton: UIButton!
    
    @IBOutlet weak var spiralButton: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    
    var uiview: UIView = UIView()
    
    var chartView = LineChartView()
    
    var frameRect: CGRect!
    
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        frameRect = CGRect(x: self.view.frame.size.width * 0.175,
                           y: 150,
                           width: self.view.frame.size.width * 0.65,
                           height: self.view.frame.size.width * 0.65)
        
        uiview.isHidden = true
        
        playButton.isHidden = true
        playButton.isEnabled = false
    }

    @IBAction func mass1Change(_ sender: Any) {
        mass1Label.text = "\(round(mass1.value * 100) / 100.0)"
    }
    
    @IBAction func mass2Change(_ sender: Any) {
        mass2Label.text = "\(round(mass2.value * 100) / 100.0)"
    }
    
    @IBAction func initializePress(_ sender: Any) {
        let m1 = Double(mass1.value)
        let m2 = Double(mass2.value)
        
        removeViews()
        
        testChirp.changeMasses(mass1: m1, mass2: m2)
//        testSpect.refresh(run_chirp: &testChirp)
//        spectUIIm = testSpect.genSpectrogram()
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
        removeViews()
        
        playButton.isHidden = false
        playButton.isEnabled = true
        
        let soundURL = testChirp.saveWav1([testChirp.make_h_float(h: testChirp.h), testChirp.make_h_float(h: testChirp.h)])
        
        do{
            //Initialize audioPlayer node
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
        }
        catch{
            print("Could not intitialize AVAudioPlayer with the file")
        }
    }
    
    
    @IBAction func playButtonPress(_ sender: Any) {
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
    }
    
    
    @IBAction func speedSliderChange(_ sender: Any) {
        speedLabel.text = "x \(round(speedSlider.value * 100) / 100.0)"
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
    }
}

