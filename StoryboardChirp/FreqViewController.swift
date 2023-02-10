//
//  FreqViewController.swift
//  StoryboardChirp
//
//  Created by Bolin Wu on 1/27/23.
//

import UIKit
import Charts

class FreqViewController: UIViewController, ChartViewDelegate {

    var freqChart = LineChartView()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        freqChart.delegate = self
        
        freqChart.frame = CGRect(x: 0, y: 0,
                                   width: self.view.frame.size.width,
                                   height: self.view.frame.size.width)
        
        freqChart.center = view.center
        
        view.addSubview(freqChart)
        
        let set = LineChartDataSet(entries: testChirp.freqDataEntries())
        set.drawCirclesEnabled = false
        set.colors = [NSUIColor](repeating: .systemBlue, count: set.colors.count)
        set.lineWidth = 30
        
        let data = LineChartData(dataSet: set)
        data.setDrawValues(false)
        
        freqChart.data = data
        
        
        freqChart.xAxis.labelPosition = .bottom
        freqChart.xAxis.axisLineColor = NSUIColor.lightGray
        freqChart.xAxis.labelTextColor = .lightGray
        
        freqChart.leftAxis.axisLineColor = NSUIColor.lightGray
        freqChart.leftAxis.labelTextColor = .lightGray
        
//        spiralChart.xAxis.drawGridLinesEnabled = false
//        spiralChart.leftAxis.drawGridLinesEnabled = false
        freqChart.rightAxis.drawGridLinesEnabled = false
//
//        spiralChart.xAxis.drawAxisLineEnabled = false
//        spiralChart.leftAxis.drawAxisLineEnabled = false
        freqChart.rightAxis.drawAxisLineEnabled = false
//
//        spiralChart.xAxis.drawLabelsEnabled = false
//        spiralChart.leftAxis.drawLabelsEnabled = false
        freqChart.rightAxis.drawLabelsEnabled = false
//
        freqChart.legend.enabled = false
        
        
        
        freqChart.animate(xAxisDuration: 2.5)
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        freqChart.delegate = self
////        Chart(testSpiral.createSpiral(), id: \.x_val) {
////            LineMark(
////                x: .value("Time", $0.x_val),
////                y: .value("Waveform Value", $0.y_val)
////            )
////        }
//        
//    }
//
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        
//    }

}
