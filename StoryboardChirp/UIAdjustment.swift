//
//  UIAdjustment.swift
//  StoryboardChirp
//
//  Created by Bolin Wu on 10/6/23.
//

import Foundation
import SwiftUI
import UIKit
import Accelerate

extension ViewController {
    
    func adjustUIAccordingToOrientation() {
        contentView.frame.size.width = UIScreen.main.bounds.width
        backgroundImageView.frame = UIScreen.main.bounds
        backgroundImageView.contentMode =  UIView.ContentMode.scaleAspectFill
        let deviceOrientation = UIApplication.shared.connectedScenes
                                // Keep only the first `UIWindowScene`
                                .first(where: { $0 is UIWindowScene })
                                // Get its associated windows
                                .flatMap({ $0 as? UIWindowScene })?.interfaceOrientation

        switch deviceOrientation {
        case .portrait:
            fallthrough
        case .portraitUpsideDown:
            print("\n\nportrait orientation\n\n")
            portraitUI()
//            print("self.view.frame.maxY: \(self.view.frame.maxY)")
//            print("self.view.frame: \(self.view.frame)")
        case .landscapeLeft:
            fallthrough
        case .landscapeRight:
            print("\n\nlanscape orientation\n\n")
            landscapeUI()
            print("self.view.frame: \(self.view.frame)")
            print("self.view.frame.maxY: \(self.view.frame.maxY)")
            
        case .unknown:
            print("unknown orientation")
        case .none:
            print("none orientation")
        @unknown default:
            print("default orientation")
        }
    }
    
    func portraitUI() {
        // adjust frameRect & windowFrame
        let window_frame = adjustFrameRectAndWindowFramePortrait()
        let window_w = window_frame[0]
        let window_h = window_frame[1]
        let window_x = window_frame[2]

        // adjust axis labels
        adjustAxisLabelsPortrait(window_w: window_w, window_h: window_h, window_x: window_x)

        
        // adjust slider region view
        adjustSliderRegionViewPortrait()

        // adjust color theme button
        colorThemeButton.center = CGPoint(x: windowFrame.frame.maxX + 10,
                                          y: windowFrame.frame.minY + 100)

        // adjust functional and info buttons
        adjustButtonsPortrait()

        print("self.view.frame: \(self.view.frame)")
        print("self.view.frame.maxY: \(self.view.frame.maxY)")
        print("UIScreen.main.bound: \(UIScreen.main.bounds)")
        print("contentView.frame: \(contentView.frame)")
        print("backgroundimageview.frame: \(backgroundImageView.frame)")
        print("frameRec: \(String(describing: frameRect))")
        print("windowframe.frame: \(windowFrame.frame)")
        print("windowframe.frame.maxY: \(windowFrame.frame.maxY)")
        print("sliderregion.frame: \(sliderRegionView.frame)")
        print("uiview.frame: \(uiview.frame)")
        

//        if UIDevice.current.userInterfaceIdiom == .pad {
//
//        } else if UIDevice.current.userInterfaceIdiom == .phone {
//
//        }
    }
    
    func landscapeUI() {
        // adjust windowFrame
        let window_frame = adjustFrameRectAndWindowFrameLanscape()
        let window_w = window_frame[0]
        let window_h = window_frame[1]
        let window_x = window_frame[2]

        // adjust axis labels
        adjustAxisLabelsLandscape(window_w: window_w, window_h: window_h, window_x: window_x)

        // adjust slider region view
        adjustSliderRegionViewLandscape()
        
        // adjust functinoal and info buttons
        adjustButtonsLandscape()
        
        print("self.view.frame: \(self.view.frame)")
        print("self.view.frame.maxY: \(self.view.frame.maxY)")
        print("UIScreen.main.bound: \(UIScreen.main.bounds)")
        print("centerFromTop: \(centerFromTop)")
        print("contentView.frame: \(contentView.frame)")
        print("backgroundimageview.frame: \(backgroundImageView.frame)")
        print("frameRec: \(String(describing: frameRect))")
        print("windowframe.frame: \(windowFrame.frame)")
        print("windowframe.frame.maxY: \(windowFrame.frame.maxY)")
        print("sliderregion.frame: \(sliderRegionView.frame)")
        print("uiview.frame: \(uiview.frame)")
        print("functional buttons frame: \(waveformButton.frame)")
        print("toolbar height: \((self.tabBarController?.tabBar.frame.height)!)")
    }
    
    func adjustFrameRectAndWindowFramePortrait() -> [Double] {
        centerFromTop = UIScreen.main.bounds.height / 3
        
        frameProp = UIDevice.current.userInterfaceIdiom == .pad ? 0.75 : 0.8
        
        let frameRect_w: Double = self.view.frame.width * frameProp
        let frameRect_h: Double = frameRect_w
//        let frameRect_x: Double = self.view.frame.width * (1 - frameProp) / 2
        let frameRect_x: Double = (self.view.frame.width - frameRect_w) / 2
        let frameRect_y: Double = centerFromTop - frameRect_h / 2
        
        // frame for displaying wavelength, frequency and spiral animation
        frameRect = CGRect(x: frameRect_x,
                           y: frameRect_y,
                           width: frameRect_w * (10/11),
                           height: frameRect_h * (10/11))
        // adjust windowFrame
        let windowProp = frameProp * 1.02
        
        let window_w: Double = self.view.frame.width * windowProp
        let window_h: Double = window_w
//        let window_x: Double = self.view.frame.width * (1 - windowProp) / 2
        let window_x: Double = (self.view.frame.width - window_w) / 2
        let window_y: Double = centerFromTop - window_h / 2
        
        windowFrame.frame = CGRect(x: window_x, y: window_y, width: window_w, height: window_h)
        windowFrame.layer.borderWidth = window_w / 64
        windowFrame.layer.borderColor = UIColor.black.cgColor
        windowFrame.layer.cornerRadius = window_w / 13
        windowFrame.backgroundColor = UIColor.white
        
//        windowFrame.removeFromSuperview()
//        contentView.addSubview(windowFrame)
        
        return [window_w, window_h, window_x]
    }
    
    func adjustAxisLabelsPortrait(window_w: Double, window_h: Double, window_x: Double) {
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
    }
    
    func adjustSliderRegionViewPortrait() {
        sliderRegionView.frame = CGRect(origin: CGPoint(x: windowFrame.frame.origin.x,
                                                        y: windowFrame.frame.maxY),
                                        size: CGSize(width: windowFrame.frame.width * 2 / 3,
                                                     height: UIScreen.main.bounds.height - windowFrame.frame.maxY - (self.tabBarController?.tabBar.frame.height)!))
        sliderRegionView.layer.cornerRadius = sliderRegionView.frame.height / 14
        
        // adjust the sliders
        let sliderPadding: CGFloat = 0.05
        adjustSlidersPortrait(sliderPadding: sliderPadding)

        // adjust the labels in slider region
        let massLabelH = sliderRegionView.frame.height / 10
        let massLabelW = massLabelH * 6
        let massLabelCenterX = mass1Slider.center.x
        let massLabelCenterY = mass1Slider.frame.origin.y - massLabelH / 2
        let massLabelFontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 27 : 18
        adjustSliderLabelsPortrait(sliderPadding: sliderPadding,
                                   massLabelH: massLabelH,
                                   massLabelW: massLabelW,
                                   massLabelCenterX: massLabelCenterX,
                                   massLabelCenterY: massLabelCenterY,
                                   massLabelFontSize: massLabelFontSize)

        // adjust the textfields in slider region
        adjustSliderTextFieldPortrait(sliderPadding: sliderPadding,
                                      massLabelH: massLabelH,
                                      massLabelW: massLabelW,
                                      massLabelCenterX: massLabelCenterX,
                                      massLabelFontSize: massLabelFontSize)
    }
    
    func adjustSlidersPortrait(sliderPadding: CGFloat) {
//        let sliderPadding: CGFloat = 0.05
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
    }
    
    func adjustSliderLabelsPortrait(sliderPadding: CGFloat,
                                    massLabelH: CGFloat,
                                    massLabelW: CGFloat,
                                    massLabelCenterX: CGFloat,
                                    massLabelCenterY: CGFloat,
                                    massLabelFontSize: CGFloat) {
//        let massLabelH = sliderRegionView.frame.height / 10
//        let massLabelW = massLabelH * 6
//        let massLabelCenterX = mass1Slider.center.x
//        var massLabelCenterY = mass1Slider.frame.origin.y - massLabelH / 2
//        let massLabelFontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 27 : 18
        var massLabelCenterY_copy = massLabelCenterY
        for masslbl in [mass1Title, mass2Title, animationSpeedTitle] {
            masslbl!.font = masslbl!.font.withSize(massLabelFontSize)
            masslbl!.frame.size = CGSize(width: massLabelW, height: massLabelH)
            masslbl!.center = CGPoint(x: massLabelCenterX, y: massLabelCenterY_copy)
            massLabelCenterY_copy += sliderRegionView.frame.height * (1 - 2 * sliderPadding) / 3
        }
    }
    
    func adjustSliderTextFieldPortrait(sliderPadding: CGFloat,
                                       massLabelH: CGFloat,
                                       massLabelW: CGFloat,
                                       massLabelCenterX: CGFloat,
                                       massLabelFontSize: CGFloat) {
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
    }
    
    func adjustButtonsPortrait() {
        let buttonH = sliderRegionView.frame.height / 1.3 / 6
        let buttonLeftPadding: CGFloat = windowFrame.frame.width / 32
        let buttonUpperPadding: CGFloat = (sliderRegionView.frame.height - 6 * buttonH) / 5
        
        // adjust functional buttons
        adjustFunctionalButtonsPortrait(buttonH: buttonH,
                                        buttonLeftPadding: buttonLeftPadding,
                                        buttonUpperPadding: buttonUpperPadding)

        // adjust info buttons
        adjustInfoButtonsPortrait(buttonLeftPadding: buttonLeftPadding,
                                  buttonUpperPadding: buttonUpperPadding)
    }
    
    func adjustFunctionalButtonsPortrait(buttonH: CGFloat,
                                         buttonLeftPadding: CGFloat,
                                         buttonUpperPadding: CGFloat) {
//        let buttonH = sliderRegionView.frame.height / 1.3 / 6
//        let buttonLeftPadding: CGFloat = windowFrame.frame.width / 32
        let buttonW = (windowFrame.frame.width - sliderRegionView.frame.width - buttonLeftPadding) * 0.95
        var buttonFrameY: CGFloat = sliderRegionView.frame.origin.y
        let buttonFontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 18 : 13
        for bttn in [waveformButton, freqButton, spectroButton,
                     audioButton, animButton, spiralButton] {
            bttn!.configuration?.attributedTitle?.font = UIFont(name: "Helvetica", size: buttonFontSize)
            bttn!.configuration?.titleAlignment = .center
            bttn!.frame = CGRect(origin: CGPoint(x: sliderRegionView.frame.maxX + buttonLeftPadding,
                                                y: buttonFrameY),
                                size: CGSize(width: buttonW, height: buttonH))
            buttonFrameY += bttn!.frame.height + buttonUpperPadding
        }
    }
    
    func adjustInfoButtonsPortrait(buttonLeftPadding: CGFloat,
                                   buttonUpperPadding: CGFloat) {
        let infoSize = waveformButton.frame.height / 2
        let infoLeftPadding: CGFloat = buttonLeftPadding
        let infoCenterDist: CGFloat = waveformButton.frame.height + buttonUpperPadding
        var infoCenterY: CGFloat = waveformButton.center.y
        let infoConfig = UIImage.SymbolConfiguration(pointSize: infoSize, weight: .medium, scale: .small)
        let infoImage = UIImage(systemName: "info.circle", withConfiguration: infoConfig)
        for infobttn in [waveformInfo, freqInfo, spectroInfo,
                         audioInfo, animInfo, spiralInfo] {
            infobttn!.setImage(infoImage, for: .normal)
            infobttn!.center = CGPoint(x: waveformButton.frame.maxX + infoLeftPadding,
                                       y: infoCenterY)
            infoCenterY += infoCenterDist
        }
    }
    
    func adjustFrameRectAndWindowFrameLanscape() -> [Double]{
        centerFromTop = UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width / 3 : UIScreen.main.bounds.width / 4.5
        
        frameProp = UIDevice.current.userInterfaceIdiom == .pad ? 0.75 : 0.8
        
        let frameRect_h: Double = UIScreen.main.bounds.height * frameProp
        let frameRect_w: Double = frameRect_h
        let frameRect_y: Double = (self.view.frame.height - frameRect_h) / 2
        let frameRect_x: Double = centerFromTop - frameRect_w / 2
        
        // frame for displaying wavelength, frequency and spiral animation
        frameRect = CGRect(x: frameRect_x,
                           y: frameRect_y,
                           width: frameRect_w * (10/11),
                           height: frameRect_h * (10/11))
        // adjust windowFrame
        let windowProp = frameProp * 1.02
        
        let window_h: Double = UIScreen.main.bounds.height * windowProp
        let window_w: Double = window_h
//        let window_x: Double = self.view.frame.width * (1 - windowProp) / 2
        let window_y_pad = (UIScreen.main.bounds.height - window_h) / 2
        let window_y_phone = UIScreen.main.bounds.height - window_h - (self.tabBarController?.tabBar.frame.height)!
        let window_y: Double = UIDevice.current.userInterfaceIdiom == .pad ? window_y_pad : window_y_phone
        let window_x: Double = centerFromTop - window_w / 2
//        let window_y: Double = centerFromTop - window_h / 2
        
        windowFrame.frame = CGRect(x: window_x, y: window_y, width: window_w, height: window_h)
        windowFrame.layer.borderWidth = window_w / 64
        windowFrame.layer.borderColor = UIColor.black.cgColor
        windowFrame.layer.cornerRadius = window_w / 13
        windowFrame.backgroundColor = UIColor.white
        
//        windowFrame.removeFromSuperview()
//        contentView.addSubview(windowFrame)
        
        return [window_w, window_h, window_x]
    }
    
    func adjustSliderRegionViewLandscape() {
//        let navigationBarH = (self.navigationController?.navigationBar.frame.height ?? 0)
        let navigationBarH = UIScreen.main.bounds.maxX * 0.13
        print("navigation bar height: \(String(describing: navigationBarH))")
        let padH = ((UIScreen.main.bounds.maxX - windowFrame.frame.maxX) * 3 / 5)
        let phoneH = ((UIScreen.main.bounds.maxX - windowFrame.frame.maxX - navigationBarH) * 4 / 7)
        let sliderRegionViewH = UIDevice.current.userInterfaceIdiom == .pad ? padH : phoneH
        sliderRegionView.frame = CGRect(origin: CGPoint(x: windowFrame.frame.maxX,
                                                        y: windowFrame.frame.origin.y),
                                        size: CGSize(width: sliderRegionViewH,
                                                     height: windowFrame.frame.height))
        sliderRegionView.layer.cornerRadius = sliderRegionView.frame.height / 14
        
        // adjust the sliders
        let sliderPadding: CGFloat = 0.05
        adjustSlidersLandscape(sliderPadding: sliderPadding)

        // adjust the labels in slider region
        let massLabelH = sliderRegionView.frame.height / 10
        let massLabelW = massLabelH * 6
        let massLabelCenterX = mass1Slider.center.x
        let massLabelCenterY = mass1Slider.frame.origin.y - massLabelH / 2
        let massLabelFontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 27 : 18
        adjustSliderLabelsLandscape(sliderPadding: sliderPadding,
                                   massLabelH: massLabelH,
                                   massLabelW: massLabelW,
                                   massLabelCenterX: massLabelCenterX,
                                   massLabelCenterY: massLabelCenterY,
                                   massLabelFontSize: massLabelFontSize)

        // adjust the textfields in slider region
        adjustSliderTextFieldLandscape(sliderPadding: sliderPadding,
                                      massLabelH: massLabelH,
                                      massLabelW: massLabelW,
                                      massLabelCenterX: massLabelCenterX,
                                      massLabelFontSize: massLabelFontSize)
    }
    
    func adjustAxisLabelsLandscape(window_w: Double, window_h: Double, window_x: Double) {
        adjustAxisLabelsPortrait(window_w: window_w, window_h: window_h, window_x: window_x)
    }
    
    func adjustSlidersLandscape(sliderPadding: CGFloat) {
//        let sliderPadding: CGFloat = 0.05
        adjustSlidersPortrait(sliderPadding: sliderPadding)
    }
    
    func adjustSliderLabelsLandscape(sliderPadding: CGFloat,
                                        massLabelH: CGFloat,
                                        massLabelW: CGFloat,
                                        massLabelCenterX: CGFloat,
                                        massLabelCenterY: CGFloat,
                                        massLabelFontSize: CGFloat) {
        adjustSliderLabelsPortrait(sliderPadding: sliderPadding,
                                   massLabelH: massLabelH,
                                   massLabelW: massLabelW,
                                   massLabelCenterX: massLabelCenterX,
                                   massLabelCenterY: massLabelCenterY,
                                   massLabelFontSize: massLabelFontSize)
    }
    
    func adjustSliderTextFieldLandscape(sliderPadding: CGFloat,
                                       massLabelH: CGFloat,
                                       massLabelW: CGFloat,
                                       massLabelCenterX: CGFloat,
                                       massLabelFontSize: CGFloat) {
        adjustSliderTextFieldPortrait(sliderPadding: sliderPadding,
                                      massLabelH: massLabelH,
                                      massLabelW: massLabelW,
                                      massLabelCenterX: massLabelCenterX,
                                      massLabelFontSize: massLabelFontSize)
    }
    
    func adjustButtonsLandscape() {
        // adjust functional buttons
        let buttonH = sliderRegionView.frame.height / 1.3 / 6
        let buttonLeftPadding: CGFloat = windowFrame.frame.width / 32
        let buttonUpperPadding: CGFloat = (sliderRegionView.frame.height - 6 * buttonH) / 5
        adjustFunctionalButtonsLandscape(buttonH: buttonH,
                                        buttonLeftPadding: buttonLeftPadding,
                                        buttonUpperPadding: buttonUpperPadding)
        
        // adjust info buttons
        adjustInfoButtonsLandscape(buttonLeftPadding: buttonLeftPadding,
                                  buttonUpperPadding: buttonUpperPadding)
    }
    
    func adjustFunctionalButtonsLandscape(buttonH: CGFloat,
                                          buttonLeftPadding: CGFloat,
                                          buttonUpperPadding: CGFloat) {
//        let navigationBarH = (self.navigationController?.navigationBar.frame.height ?? 0)
        let navigationBarH = UIScreen.main.bounds.maxX * 0.13
        let buttonWPad = (UIScreen.main.bounds.maxX - sliderRegionView.frame.maxX - buttonLeftPadding) * 0.95 - waveformInfo.frame.width
        let buttonWPhone = (UIScreen.main.bounds.maxX - navigationBarH - sliderRegionView.frame.maxX - buttonLeftPadding) * 0.95 - waveformInfo.frame.width
        let buttonW = UIDevice.current.userInterfaceIdiom == .pad ? buttonWPad : buttonWPhone
        var buttonFrameY: CGFloat = sliderRegionView.frame.origin.y
        let buttonFontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 18 : 13
        for bttn in [waveformButton, freqButton, spectroButton,
                     audioButton, animButton, spiralButton] {
            bttn!.configuration?.attributedTitle?.font = UIFont(name: "Helvetica", size: buttonFontSize)
            bttn!.configuration?.titleAlignment = .center
            bttn!.frame = CGRect(origin: CGPoint(x: sliderRegionView.frame.maxX + buttonLeftPadding,
                                                y: buttonFrameY),
                                size: CGSize(width: buttonW, height: buttonH))
            buttonFrameY += bttn!.frame.height + buttonUpperPadding
        }
    }
    
    func adjustInfoButtonsLandscape(buttonLeftPadding: CGFloat,
                                   buttonUpperPadding: CGFloat) {
        adjustInfoButtonsPortrait(buttonLeftPadding: buttonLeftPadding, buttonUpperPadding: buttonUpperPadding)
    }
}
