//
//  TutorialFunctions.swift
//  StoryboardChirp
//
//  Created by Bolin Wu on 2/28/24.
//

import SwiftUI
import UIKit
import AVFoundation
import Accelerate

extension ViewController {
    @IBAction func swipeLeft(_ sender: Any) {
        print("swipe left")
        if currentTutorialPage == totalTutorialPageCount - 2 {
            // entering the last page, show Start button
            showTutorialEndButton()
        } else if currentTutorialPage == 0 {
            // leaving the first page
            leaveFirstPage()
        }
        if currentTutorialPage < totalTutorialPageCount - 1 {
            // show the next page if not at the last page
            currentTutorialPage += 1
            updateToCurrentTutorial()
        }
    }
    
    @IBAction func swipeRight(_ sender: Any) {
        print("swipe right")
        if currentTutorialPage == totalTutorialPageCount - 1 {
            // swiping right from the last page, remove Start button
            hideTutorialEndButton()
        } else if currentTutorialPage == 1 {
            // entering the first page
            enterFirstPage()
        }
        if currentTutorialPage > 0 {
            // show the previous page if not at the first page
            currentTutorialPage -= 1
            updateToCurrentTutorial()
        }
    }
    
    // the Start button at the last tutorial page
    @IBAction func tutorialEndPressed(_ sender: Any) {
        removeTutorial()
        // COMMENT out the following line: tutorial shows for non first time users as well.
//        UserDefaults.standard.set("Done", forKey: "Tutorial")
    }
    
    @IBAction func tutorialSkipButtonPressed(_ sender: Any) {
        removeTutorial()
    }
    
    @IBAction func tutorialButtonPressed(_ sender: Any) {
        setupTutorial()
        
    }
    
    func setupTutorialIfNeeded() {
        if isFirstTimeUser() {
            setupTutorial()
        }
    }
    
    // set up tutorial pages
    func setupTutorial() {
        displayingTutorial = true
        
        setupTutorialTitleText()
        setupTutorialContentText()
        
//        if !displayingViews {
//            tutorialAddSubviews()
//        }
        
        setupTutorialView()

        if !tutorialView.isDescendant(of: self.view) {
            tutorialAddSubviews()
        }
        
        totalTutorialPageCount = pageDots.numberOfPages
//        print("Total tutorial page count: \(totalTutorialPageCount)")
        
        currentTutorialPage = 0
        
        adjustTutorial()
        
        updateToCurrentTutorial()
        
        hideTutorialEndButton()
        
    }
    
    func setupTutorialView() {
        tutorialView.backgroundColor = .white.withAlphaComponent(1)
        tutorialView.alpha = 1
        
        pageDots.backgroundColor = .green
        pageDots.layer.cornerRadius = 20
    }
    
    func tutorialAddSubviews() {
        assert(displayingTutorial, "tutorialAddSubviews() called when displayingTutorial == false")
//        tutorialView = UIView()
        self.view.addSubview(tutorialView)
        tutorialView.addSubview(tutorialTitle)
        tutorialView.addSubview(tutorialContent)
//        tutorialTitle.text = "Tutorial Page " + String(currentTutorialPage)
        tutorialView.addSubview(tutorialImageView)
        tutorialView.addSubview(tutorialEndButton)
        tutorialView.addSubview(tutorialSkipButton)
        tutorialView.addSubview(pageDots)
//        pageDots.numberOfPages = totalTutorialPageCount
    }
    
    func updateToCurrentTutorial() {
        assert(displayingTutorial, "updateToCurrentTutorial() called when displayingTutorial == false")
        tutorialTitle.text = tutorialTitleText[currentTutorialPage]
        tutorialTitle.sizeToFit()
        tutorialTitle.center = CGPoint(x: tutorialView.center.x, y: tutorialTitle.center.y)
        
        tutorialContent.text = tutorialContentText[currentTutorialPage]
        tutorialContent.sizeToFit()
        tutorialContent.center = CGPoint(x: tutorialView.center.x, y: tutorialContent.center.y)
        
        pageDots.currentPage = currentTutorialPage
    }
    
    func leaveFirstPage() {
        tutorialView.backgroundColor = .white.withAlphaComponent(0.3)
        setupRedRect()
        tutorialView.addSubview(redRect)
    }
    
    func enterFirstPage() {
        tutorialView.backgroundColor = .white.withAlphaComponent(1)
        redRect.removeFromSuperview()
    }
    
    func setupRedRect() {
        redRect = UIView(frame: waveformButton.frame)
        redRect.layer.borderColor = UIColor.red.cgColor
        redRect.layer.borderWidth = 10
        redRect.layer.cornerRadius = 10
        redRect.backgroundColor = .clear
    }
    
    func removeTutorial() {
        displayingTutorial = false
        if redRect != nil {
            redRect.removeFromSuperview()
        }
        tutorialView.removeFromSuperview()
//        pageDots.isHidden = true
        hideTutorialEndButton()
//        tutorialImageView.removeFromSuperview()
//        tutorialTitle.isHidden = true
    }
    
    func isFirstTimeUser() -> Bool {
        let i = UserDefaults.standard.string(forKey: "Tutorial")
        return i != "Done"
    }
    
    func showTutorialEndButton() {
        tutorialEndButton.isHidden = false
        tutorialEndButton.isEnabled = true
    }
    
    func hideTutorialEndButton() {
        tutorialEndButton.isHidden = true
        tutorialEndButton.isEnabled = false
    }
    
    func setupTutorialTitleText() {
        let welcomeTitle = "Welcome to Make Chirps!"
        let waveformTitle = "Waveform Plot"
        let frequencyTitle = "Frequency Plot"
        let spectroTitle = "Spectrogram Plot"
        let audioTitle = "Audio"
        let collisionTitle = "Collision Animation"
        let spiralTitle = "Spiral Animation"
        let tutorialEndTitle = "Get started!"
        tutorialTitleText = [welcomeTitle,
                             waveformTitle,
                             frequencyTitle,
                             spectroTitle,
                             audioTitle,
                             collisionTitle,
                             spiralTitle,
                             tutorialEndTitle]
        assert(tutorialTitleText.count == pageDots.numberOfPages,
                "Number of pages \(pageDots.numberOfPages) doesn't match number of title \(tutorialTitleText.count).")
    }
    
    func setupTutorialContentText() {
        let welcomeContent = "Welcome content"
        let waveformContent = "Click on this button to view the waveform plot."
        let frequencyContent = "Click on this button to view the frequency plot."
        let spectroContent = "Click on this button to view the spectrogram plot."
        let audioContent = "Click on this button to hear the audio."
        let collisionContent = "Click on this button to view the animation of star collisions."
        let spiralContent = "Click on this button to view the animation of gravitational wave spiral."
        let tutorialEndContent = ""
        tutorialContentText = [welcomeContent,
                               waveformContent,
                               frequencyContent, 
                               spectroContent,
                               audioContent, 
                               collisionContent,
                               spiralContent,
                               tutorialEndContent]
        assert(tutorialContentText.count == pageDots.numberOfPages,
                "Number of pages \(pageDots.numberOfPages) doesn't match number of title \(tutorialContentText.count).")
    }
}
