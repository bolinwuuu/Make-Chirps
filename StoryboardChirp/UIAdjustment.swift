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
        adjustScrollViewAndContentView()
        
        // adjust frameRect & windowFrame
        adjustFrameRectAndWindowFramePortrait()

        // adjust axis labels
        adjustAxisLabelsPortrait()

        
        // adjust slider region view
        adjustSliderRegionViewPortrait()

        // adjust color theme button
        colorThemeButton.center = CGPoint(x: windowFrame.frame.maxX + 10,
                                          y: windowFrame.frame.minY + 100)

        // adjust functional and info buttons
        adjustButtonsPortrait()
        
        // adjust tutorial button
        adjustTutorialAndColorThemeButtonsPortrait()
        
        if displayingTutorial {
            adjustTutorialPortrait()
        }

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
        print("functional buttons frame: \(waveformButton.frame)")
        print("spectrogram button numberOfLines: \(spectroButton.titleLabel?.numberOfLines)")
        print("spectrogram button adjustsFontSize: \(spectroButton.titleLabel?.adjustsFontSizeToFitWidth)")
        print("tutorialView.frame \(tutorialView.frame)")

    }
    
    func landscapeUI() {
        adjustScrollViewAndContentView()
        
        // adjust windowFrame
        adjustFrameRectAndWindowFrameLanscape()

        // adjust axis labels
        adjustAxisLabelsLandscape()

        // adjust slider region view
        adjustSliderRegionViewLandscape()
        
        // adjust functinoal and info buttons
        adjustButtonsLandscape()
        
        // adjust tutorial button
        adjustTutorialAndColorThemeButtonsLandscape()
        
        if displayingTutorial {
            adjustTutorialLandscape()
        }
        
//        print("self.view.frame: \(self.view.frame)")
//        print("self.view.frame.maxY: \(self.view.frame.maxY)")
//        print("UIScreen.main.bound: \(UIScreen.main.bounds)")
//        print("centerFromTop: \(centerFromTop)")
//        print("contentView.frame: \(contentView.frame)")
//        print("backgroundimageview.frame: \(backgroundImageView.frame)")
//        print("frameRec: \(String(describing: frameRect))")
//        print("windowframe.frame: \(windowFrame.frame)")
//        print("windowframe.frame.maxY: \(windowFrame.frame.maxY)")
//        print("sliderregion.frame: \(sliderRegionView.frame)")
//        print("uiview.frame: \(uiview.frame)")
//        print("functional buttons frame: \(waveformButton.frame)")
//        print("toolbar height: \((self.tabBarController?.tabBar.frame.height)!)")
//        print("func button corner radius: \(waveformButton.layer.cornerRadius)")
//        print("collision button numberOfLines: \(animButton.titleLabel?.numberOfLines)")
//        print("collision button adjustsFontSize: \(animButton.titleLabel?.adjustsFontSizeToFitWidth)")
        printViewFrames(whichFunction: "landscape UI")
    }
    
    func adjustScrollViewAndContentView() {
        scrollView.frame = CGRect(x: 0, y: 0,
                                  width: UIScreen.main.bounds.width, height: scrollView.frame.height)
        contentView.frame = CGRect(x: 0, y: 0,
                                  width: UIScreen.main.bounds.width, height: contentView.frame.height)
    }
    
    func adjustFrameRectAndWindowFramePortrait() {
        centerFromTop = UIScreen.main.bounds.height / 3
        
        frameProp = UIDevice.current.userInterfaceIdiom == .pad ? 0.68 : 0.65
        
        let frameRect_w: Double = self.view.frame.width * frameProp
        let frameRect_h: Double = frameRect_w
//        let frameRect_x: Double = self.view.frame.width * (1 - frameProp) / 2
        let frameRect_x: Double = (self.view.frame.width - frameRect_w / (10/11)) / 2
        let frameRect_y: Double = centerFromTop - frameRect_h / (10/11) / 2
        
        // frame for displaying wavelength, frequency and spiral animation
        frameRect = CGRect(x: frameRect_x,
                           y: frameRect_y,
                           width: frameRect_w,
                           height: frameRect_h)
        // adjust windowFrame
        let windowProp = UIDevice.current.userInterfaceIdiom == .pad ? 0.765 : 0.816
        
        let window_w: Double = self.view.frame.width * windowProp
        let window_h: Double = window_w
//        let window_x: Double = self.view.frame.width * (1 - windowProp) / 2
        let window_x: Double = (self.view.frame.width - window_w) / 2
        let window_y: Double = centerFromTop - window_h / 2
        
        windowFrame.frame = CGRect(x: window_x, y: window_y, width: window_w, height: window_h)
        windowFrame.layer.borderWidth = window_w / 64
        windowFrame.layer.cornerRadius = window_w / 13
        
//        windowFrame.removeFromSuperview()
//        contentView.addSubview(windowFrame)
    }
    
    func adjustAxisLabelsPortrait() {
        let axisLabelFontSize = UIDevice.current.userInterfaceIdiom == .pad ? 17.0 : 14.0
        xAxisLabel.font = xAxisLabel.font.withSize(axisLabelFontSize)
        yAxisLabel.font = yAxisLabel.font.withSize(axisLabelFontSize)
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
                                        buttonLeftPadding: buttonLeftPadding / 2,
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
        let buttonFontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? PADBUTTONFONTSIZE : PHONEBUTTONFONTSIZE
//        let buttonFontSize: CGFloat = 18
        for bttn in [waveformButton, freqButton, spectroButton,
                     audioButton, animButton, spiralButton] {
            bttn!.configuration?.attributedTitle?.font = UIFont(name: "Helvetica", size: buttonFontSize)
//            bttn!.configuration?.titleAlignment = .center
            bttn!.frame = CGRect(origin: CGPoint(x: sliderRegionView.frame.maxX + buttonLeftPadding,
                                                y: buttonFrameY),
                                size: CGSize(width: buttonW, height: buttonH))
            bttn?.layer.shadowOffset = CGSize(width: 0, height: buttonH / 8)
            buttonFrameY += bttn!.frame.height + buttonUpperPadding
            
            bttn?.titleLabel?.numberOfLines = 1
            bttn?.titleLabel?.adjustsFontSizeToFitWidth = true
            bttn?.titleLabel?.lineBreakMode = .byClipping
            bttn?.titleLabel?.textAlignment = .center
        }
        animButton.titleLabel?.numberOfLines = 2
        spiralButton.titleLabel?.numberOfLines = 2
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
        let questionImage = UIImage(systemName: "questionmark.circle", withConfiguration: infoConfig)
        for questionbttn in [mass1Info, mass2Info, speedInfo] {
            questionbttn!.setImage(questionImage, for: .normal)
            questionbttn!.tintColor = .lightGray
        }
        mass1Info.center = CGPoint(x: mass1TextField.frame.maxX + infoLeftPadding, y: mass1TextField.center.y)
        mass2Info.center = CGPoint(x: mass2TextField.frame.maxX + infoLeftPadding, y: mass2TextField.center.y)
        speedInfo.center = CGPoint(x: speedLabel.frame.maxX + infoLeftPadding, y: speedLabel.center.y)
        
    }
    
    func adjustTutorialAndColorThemeButtonsPortrait() {
        tutorialButton.center = CGPoint(x: (windowFrame.frame.maxX + UIScreen.main.bounds.width) * 0.5,
                                        y: windowFrame.frame.minY + tutorialButton.frame.height * 2)

        colorThemeButton.center = CGPoint(x: tutorialButton.center.x,
                                          y: tutorialButton.center.y + colorThemeButton.frame.height * 1.5)
    }
    
    func adjustFrameRectAndWindowFrameLanscape() {
        centerFromTop = UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width / 3 : UIScreen.main.bounds.width / 4
        
//        frameProp = UIDevice.current.userInterfaceIdiom == .pad ? 0.75 : 0.6
        frameProp = UIDevice.current.userInterfaceIdiom == .pad ? 0.68 : 0.65
        
        let frameRect_h: Double = UIScreen.main.bounds.height * frameProp
        let frameRect_w: Double = frameRect_h
        let frameRect_y: Double = (self.view.frame.height - frameRect_h) / 2
        let frameRect_x: Double = centerFromTop - frameRect_w / 2
        
        // frame for displaying wavelength, frequency and spiral animation
        frameRect = CGRect(x: frameRect_x,
                           y: frameRect_y,
                           width: frameRect_w,
                           height: frameRect_h)
        // adjust windowFrame
        let windowProp = UIDevice.current.userInterfaceIdiom == .pad ? 0.765 : 0.816
        
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
        windowFrame.layer.cornerRadius = window_w / 13
//        windowFrame.removeFromSuperview()
//        contentView.addSubview(windowFrame)
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
    
    func adjustAxisLabelsLandscape() {
        adjustAxisLabelsPortrait()
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
                                        buttonLeftPadding: buttonLeftPadding / 2,
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
        let buttonFontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? PADBUTTONFONTSIZE : PHONEBUTTONFONTSIZE
//        let buttonFontSize: CGFloat = 18
        for bttn in [waveformButton, freqButton, spectroButton,
                     audioButton, animButton, spiralButton] {
            bttn!.configuration?.attributedTitle?.font = UIFont(name: "Helvetica", size: buttonFontSize)
//            bttn!.configuration?.titleAlignment = .center
            bttn!.frame = CGRect(origin: CGPoint(x: sliderRegionView.frame.maxX + buttonLeftPadding,
                                                y: buttonFrameY),
                                size: CGSize(width: buttonW, height: buttonH))
            
            bttn?.layer.shadowOffset = CGSize(width: 0, height: buttonH / 8)
            buttonFrameY += bttn!.frame.height + buttonUpperPadding
            
            bttn?.titleLabel?.numberOfLines = 1
            bttn?.titleLabel?.adjustsFontSizeToFitWidth = true
            bttn?.titleLabel?.lineBreakMode = .byClipping
            bttn?.titleLabel?.textAlignment = .center
            bttn?.titleLabel?.minimumScaleFactor = 0.5
        }
        animButton.titleLabel?.numberOfLines = 2
        spiralButton.titleLabel?.numberOfLines = 2
//        
//        spectroButton.titleLabel?.numberOfLines = 1
//        spectroButton.titleLabel?.adjustsFontSizeToFitWidth = true
//        spectroButton.titleLabel?.lineBreakMode = .byClipping
    }
    
    func adjustInfoButtonsLandscape(buttonLeftPadding: CGFloat,
                                   buttonUpperPadding: CGFloat) {
        adjustInfoButtonsPortrait(buttonLeftPadding: buttonLeftPadding, buttonUpperPadding: buttonUpperPadding)
    }
    
    func adjustTutorialAndColorThemeButtonsLandscape() {
        //        tutorialButton.center = CGPoint(x: (windowFrame.frame.maxX + UIScreen.main.bounds.width) * 0.5,
        //                                        y: windowFrame.frame.minY + tutorialButton.frame.height * 0.5)
        tutorialButton.center = CGPoint(x: windowFrame.frame.minX - tutorialButton.frame.width * 0.5,
                                        y: windowFrame.frame.minY + tutorialButton.frame.height)

        colorThemeButton.center = CGPoint(x: tutorialButton.center.x,
                                          y: tutorialButton.center.y + colorThemeButton.frame.height * 1.5)
    }
    
    func adjustTutorialImageView() {
        printViewFrames(whichFunction: "adjust tutorial image view begins")
        if currentTutorialPage == 0 || currentTutorialPage == totalTutorialPageCount - 1 {
            // show icon in the first & last pages
            let w = frameRect.width / 2
            let h = frameRect.height / 2
            tutorialImageView.frame = CGRect(x: tutorialView.center.x - w / 2, y: tutorialView.center.y - h / 2,
                                             width: w, height: h)
            tutorialImageView.center = tutorialView.center
        } else {
            tutorialImageView.frame = frameRect
            tutorialImageView.center = windowFrame.center
            
//            tutorialImageView.center = tutorialView.center
            printViewFrames(whichFunction: "adjust tutorial image view ends")
        }
    }
    
    func adjustTutorialSkipButton() {
        tutorialSkipButton.frame = CGRect(x: 0, y: 0,
                                          width: waveformButton.frame.width * (2/3), height: waveformButton.frame.height * (2/3))
        tutorialSkipButton.layer.cornerRadius = tutorialSkipButton.frame.height / 4
        
        tutorialSkipButton.backgroundColor = .lightGray
        tutorialSkipButton.tintColor = .white
//        tutorialSkipButton.layer.shadowOffset = CGSize(width: 0, height: tutorialSkipButton.frame.height / 8)
//        tutorialSkipButton.layer.shadowColor = UIColor.darkGray.cgColor
//        tutorialSkipButton.layer.shadowOpacity = 1.0
        
        tutorialSkipButton.center = CGPoint(x: tutorialSkipButton.frame.width * (2/3),
                                            y: windowFrame.frame.minY + tutorialSkipButton.frame.height * 2)
    }
    
    func adjustTutorialEndButton() {
        tutorialEndButton.frame = CGRect(x: 0, y: 0,
                                         width: waveformButton.frame.width * 1.25, height: waveformButton.frame.height * 1.25)
        tutorialEndButton.layer.cornerRadius = tutorialEndButton.frame.height / 4
        
        let buttonBackground = UIColor(red: 255/255, green: 120/255, blue: 40/255, alpha: 1)
        let buttonShadow = UIColor(red: 225/255, green: 85/255, blue: 0/255, alpha: 1)
        tutorialEndButton.backgroundColor = buttonBackground
        tutorialEndButton.tintColor = .white
        let fontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 40 : 25
        tutorialEndButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        tutorialEndButton.layer.shadowOffset = CGSize(width: 0, height: tutorialSkipButton.frame.height / 8)
        tutorialEndButton.layer.shadowColor = buttonShadow.cgColor
        tutorialEndButton.layer.shadowOpacity = 1.0
        tutorialEndButton.layer.shadowRadius = 2.0
        tutorialEndButton.layer.masksToBounds = false
        
        tutorialEndButton.center = CGPoint(x: tutorialView.center.x, y: tutorialView.frame.height * (3/4))
    }
    
    func adjustTutorial() {
        assert(displayingTutorial, "adjustTutorial() called when displayingTutorial == false")
        let deviceOrientation = UIApplication.shared.connectedScenes
                                // Keep only the first `UIWindowScene`
                                .first(where: { $0 is UIWindowScene })
                                // Get its associated windows
                                .flatMap({ $0 as? UIWindowScene })?.interfaceOrientation

        switch deviceOrientation {
        case .portrait:
            fallthrough
        case .portraitUpsideDown:
//            print("\n\nportrait orientation\n\n")
            adjustTutorialPortrait()
        case .landscapeLeft:
            fallthrough
        case .landscapeRight:
//            print("\n\nlanscape orientation\n\n")
            adjustTutorialLandscape()
        case .unknown:
            print("unknown orientation")
        case .none:
            print("none orientation")
        @unknown default:
            print("default orientation")
        }
    }
    
    func adjustTutorialPortrait() {
        adjustTutorialShared()
    }
    
    func adjustTutorialLandscape() {
        adjustTutorialShared()
    }
    
    func adjustTutorialShared() {
        adjustTutorialView()
//        tutorialView.frame = self.view.frame
        
//        tutorialImageView.center = tutorialView.center
        let fontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 50 : 30
        tutorialTitle.font = tutorialTitle.font.withSize(fontSize)
        tutorialTitle.sizeToFit()
        tutorialTitle.center = CGPoint(x: tutorialView.center.x, y: tutorialView.frame.height * (1/4))
        
        tutorialContent.font = tutorialContent.font.withSize(20)
        tutorialContent.sizeToFit()
        tutorialContent.center = CGPoint(x: tutorialView.center.x, y: tutorialView.frame.height * (2/3))

        pageDots.center = CGPoint(x: tutorialView.center.x, y: tutorialView.frame.height * (4/5))
        adjustTutorialEndButton()
        adjustTutorialSkipButton()
        
        adjustTutorialImageView()
        updateChatBubble()
        updateHighlightWindow()
        
        // this is used to solve a wierd bug happening when the app is changing orientation on the first tutorial page
        if currentTutorialPage == 0 {
            nextTutorialPage()
            backTutorialPage()
        } else if currentTutorialPage == totalTutorialPageCount - 1 {
            backTutorialPage()
            nextTutorialPage()
        }
    }
   
}
