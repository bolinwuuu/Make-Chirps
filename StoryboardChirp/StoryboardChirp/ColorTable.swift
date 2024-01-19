//
//  ColorTable.swift
//  StoryboardChirp
//
//  Created by Bolin Wu on 1/27/23.
//

import Foundation
import UIKit
import Accelerate
import Darwin
import SwiftUI
import Charts
typealias Color = UIColor

func brgValue(from value: Pixel_8) -> (red: Pixel_8,
                                       green: Pixel_8,
                                       blue: Pixel_8) {
    let normalizedValue = CGFloat(value) / 255
    
    // Define `hue` that's blue at `0.0` to red at `1.0`.
    let hue = 0.6666 - (0.6666 * normalizedValue)
    let brightness = sqrt(normalizedValue)

    let color = Color(hue: hue,
                      saturation: 1,
                      brightness: brightness,
                      alpha: 1)
    
    var red = CGFloat()
    var green = CGFloat()
    var blue = CGFloat()
    
    // switch red and green --> red at 255
    color.getRed(&green,
                 green: &red,
                 blue: &blue,
                 alpha: nil)
    
    return (Pixel_8(green * 255),
            Pixel_8(red * 255),
            Pixel_8(blue * 255))
}

var redTable: [Pixel_8] = (0 ... 255).map {
    return brgValue(from: $0).red
}

var greenTable: [Pixel_8] = (0 ... 255).map {
    return brgValue(from: $0).green
}

var blueTable: [Pixel_8] = (0 ... 255).map {
    return brgValue(from: $0).blue
}



