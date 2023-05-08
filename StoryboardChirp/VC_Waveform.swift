//
//  ViewController_Waveform.swift
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
}
