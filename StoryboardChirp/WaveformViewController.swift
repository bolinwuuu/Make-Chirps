//
//  WaveformViewController.swift
//  StoryboardChirp
//
//  Created by Bolin Wu on 1/27/23.
//

import UIKit
import Charts

class WaveformViewController: UIViewController, ChartViewDelegate {
    
//    let RunChirp1 = Run_Chirp( mass1: 10, mass2: 30)

//    @IBAction func AudioButton(_ sender: UIButton) {
//        testChirp.saveWav([testChirp.make_h_float(h: testChirp.h), testChirp.make_h_float(h: testChirp.h)])
//    }
    
    var waveformChart = LineChartView()
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        waveformChart.delegate = self
////        Chart(testSpiral.createSpiral(), id: \.x_val) {
////            LineMark(
////                x: .value("Time", $0.x_val),
////                y: .value("Waveform Value", $0.y_val)
////            )
////        }
//
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        waveformChart.delegate = self
        
        waveformChart.frame = CGRect(x: 0, y: 0,
                                   width: self.view.frame.size.width * 3 / 4,
                                   height: self.view.frame.size.width * 3 / 4)
        
        waveformChart.center = view.center
        
        view.addSubview(waveformChart)
        
        let set = LineChartDataSet(entries: testChirp.waveformDataEntries())
        set.drawCirclesEnabled = false
        set.colors = [NSUIColor](repeating: .systemBlue, count: set.colors.count)
        set.lineWidth = 30
        
        let data = LineChartData(dataSet: set)
        data.setDrawValues(false)
        
        waveformChart.data = data
        
        
        waveformChart.xAxis.labelPosition = .bottom
        waveformChart.xAxis.axisLineColor = NSUIColor.lightGray
        waveformChart.xAxis.labelTextColor = .lightGray
        
        waveformChart.leftAxis.axisLineColor = NSUIColor.lightGray
        waveformChart.leftAxis.labelTextColor = .lightGray
        
        
//        spiralChart.xAxis.drawGridLinesEnabled = false
//        spiralChart.leftAxis.drawGridLinesEnabled = false
//        spiralChart.rightAxis.drawGridLinesEnabled = false
//
//        spiralChart.xAxis.drawAxisLineEnabled = false
//        spiralChart.leftAxis.drawAxisLineEnabled = false
        waveformChart.rightAxis.drawAxisLineEnabled = false
//
//        spiralChart.xAxis.drawLabelsEnabled = false
//        spiralChart.leftAxis.drawLabelsEnabled = false
        waveformChart.rightAxis.drawLabelsEnabled = false
//
        waveformChart.legend.enabled = false
        
        waveformChart.animate(xAxisDuration: 2.5)
    }
//
//    func refreshView() {
//        loadView()
//    }
    
    @IBAction func refreshView(_ sender: Any) {
//        viewWillAppear(true)
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//

//    }
//
}

