//
//  CustomSlider.swift
//  ColorCreator
//
//  Created by Bolin Wu on 11/26/23.
//

import Foundation
import UIKit

final class CustomSlider: UISlider {

    private var baseLayer = CALayer() // Step 3
    private var trackLayer = CAGradientLayer() // Step 7
    private var thumbView = ThumbView()
    
    var lastTumbSize = 0.0
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setup()
    }
    
//    public func customFrame() {
//        baseLayer.frame = .init(x: 0, y: frame.height / 4, width: frame.width, height: frame.height / 2)
//        baseLayer.cornerRadius = baseLayer.frame.height / 2
//        trackLayer.frame = .init(x: 0, y: frame.height / 4, width: 0, height: frame.height / 2)
//        trackLayer.cornerRadius = trackLayer.frame.height / 2
//    }
    
    public func changeSliderValue(value: Float) {
        self.value = value
        valueChanged(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        baseLayer.frame = .init(x: 0, y: frame.height / 4, width: frame.width, height: frame.height / 2)
        baseLayer.cornerRadius = baseLayer.frame.height / 2
        
        valueChanged(self)
        
        if lastTumbSize != frame.height {
            lastTumbSize = frame.height
            createThumbImageView()

        }
    }

    private func setup() {
        clear()
        createBaseLayer() // Step 3
        createThumbImageView() // Step 5
        configureTrackLayer() // Step 7
        addUserInteractions() // Step 8
    }

    private func clear() {
        tintColor = .clear
        maximumTrackTintColor = .clear
        backgroundColor = .clear
        thumbTintColor = .clear
    }

    // Step 3
    private func createBaseLayer() {
        baseLayer.borderWidth = 1
        baseLayer.borderColor = UIColor.lightGray.cgColor
        baseLayer.masksToBounds = true
        baseLayer.backgroundColor = UIColor.white.cgColor
        baseLayer.frame = .init(x: 0, y: frame.height / 4, width: frame.width, height: frame.height / 2)
        baseLayer.cornerRadius = baseLayer.frame.height / 2
        layer.insertSublayer(baseLayer, at: 0)
    }

    // Step 7
    private func configureTrackLayer() {
        let lightOrange = UIColor(red: 255/255, green: 120/255, blue: 40/255, alpha: 1)
        let darkOrange = UIColor(red: 175/255, green: 55/255, blue: 0/255, alpha: 1)
//        let firstColor = UIColor(red: 210/255, green: 152/255, blue: 238/255, alpha: 1).cgColor
//        let secondColor = UIColor(red: 166/255, green: 20/255, blue: 217/255, alpha: 1).cgColor
        let firstColor = lightOrange.cgColor
        let secondColor = firstColor
        trackLayer.colors = [firstColor, secondColor]
        trackLayer.startPoint = .init(x: 0, y: 0.5)
        trackLayer.endPoint = .init(x: 1, y: 0.5)
        trackLayer.frame = .init(x: 0, y: frame.height / 4, width: 0, height: frame.height / 2)
        trackLayer.cornerRadius = trackLayer.frame.height / 2
        layer.insertSublayer(trackLayer, at: 1)
    }

    // Step 8
    private func addUserInteractions() {
        addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
    }

    @objc private func valueChanged(_ sender: CustomSlider) {
        // Step 10
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        // Step 9
        let thumbRectA = thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
        trackLayer.frame = .init(x: 0, y: frame.height / 4, width: thumbRectA.midX, height: frame.height / 2)
        // Step 10
        CATransaction.commit()
    }

    // Step 5
    private func createThumbImageView() {
        let thumbSize = frame.height
//        let thumbView = ThumbView(frame: .init(x: 0, y: 0, width: 30, height: thumbSize))
        thumbView.frame = .init(x: 0, y: 0, width: thumbSize / 4, height: thumbSize)
        thumbView.layer.cornerRadius = thumbView.frame.width / 2
        let thumbSnapshot = thumbView.snapshot
        setThumbImage(thumbSnapshot, for: .normal)
        // Step 6
        setThumbImage(thumbSnapshot, for: .highlighted)
        setThumbImage(thumbSnapshot, for: .application)
        setThumbImage(thumbSnapshot, for: .disabled)
        setThumbImage(thumbSnapshot, for: .focused)
        setThumbImage(thumbSnapshot, for: .reserved)
        setThumbImage(thumbSnapshot, for: .selected)
    }
}
