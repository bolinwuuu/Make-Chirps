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
        checkMassChange()
        removeViews()
        
//        chartView = LineChartView()
        xAxisLabel.isHidden = true
        yAxisLabel.isHidden = true
        
       // xAxisLabel.text = "Time (s)"
        // yAxisLabel.text = "Gravitational Wave Strain"
        
        chartView.frame = frameRect
        
        view.addSubview(chartView)
        
        let set = LineChartDataSet(entries: testChirp.waveformDataEntries())
        set.drawCirclesEnabled = false
        set.colors = [NSUIColor](repeating: .systemBlue, count: set.colors.count)
        set.lineWidth = testChirp.getChirpMass() / 3.7
        
        let data = LineChartData(dataSet: set)
        data.setDrawValues(false)
        
        chartView.center = windowFrame.center
        
        let xAxisLabel = UILabel()
                xAxisLabel.text = "Time (seconds)"
                xAxisLabel.textAlignment = .center
                xAxisLabel.translatesAutoresizingMaskIntoConstraints = false
                windowFrame.addSubview(xAxisLabel)
                
                let yAxisLabel = UILabel()
                yAxisLabel.text = "Gravitational Wave Strain"
                yAxisLabel.textAlignment = .center
                yAxisLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
                yAxisLabel.translatesAutoresizingMaskIntoConstraints = false
                windowFrame.addSubview(yAxisLabel)
        
        //xAxisLabel.center = chartView.center
        //yAxisLabel.center = chartView.center
        
        NSLayoutConstraint.activate([
                // X axis label constraints
                xAxisLabel.bottomAnchor.constraint(equalTo: windowFrame.bottomAnchor, constant: -14),
                xAxisLabel.centerXAnchor.constraint(equalTo: windowFrame.centerXAnchor),

                // Y axis label constraints
                yAxisLabel.leadingAnchor.constraint(equalTo: windowFrame.leadingAnchor, constant: -60),
                yAxisLabel.centerYAnchor.constraint(equalTo: windowFrame.centerYAnchor, constant: -33)
            ])

        
        chartView.data = data
        
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.axisLineColor = NSUIColor.lightGray
        chartView.xAxis.labelTextColor = .black // new
        
        chartView.leftAxis.axisLineColor = NSUIColor.lightGray
        chartView.leftAxis.labelTextColor = .black // new

        chartView.rightAxis.drawAxisLineEnabled = false
        chartView.rightAxis.drawLabelsEnabled = false
//
        chartView.legend.enabled = false
        
        chartView.animate(xAxisDuration: 2.5)
    }
}
