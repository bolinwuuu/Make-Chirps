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
        if currentTutorialPage == totalTutorialPageCount - 1 {
            // entering last page, show Start button
            showTutorialEndButton()
        }
        if currentTutorialPage < totalTutorialPageCount {
            // show the next page if not at the last page
            currentTutorialPage += 1
            updateToCurrentTutorial()
        }
    }
    
    @IBAction func swipeRight(_ sender: Any) {
        print("swipe right")
        if currentTutorialPage == totalTutorialPageCount {
            // swiping right from the last page, remove Start button
            hideTutorialEndButton()
        }
        if currentTutorialPage > 1 {
            // show the previous page if not at the first page
            currentTutorialPage -= 1
            updateToCurrentTutorial()
        }
    }
    
    // the Start button at the last tutorial page
    @IBAction func tutorialEndPressed(_ sender: Any) {
        removeTutorial()
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
        
//        if !displayingViews {
//            tutorialAddSubviews()
//        }

        if !tutorialView.isDescendant(of: self.view) {
            tutorialAddSubviews()
        }
        
        totalTutorialPageCount = pageDots.numberOfPages
//        print("Total tutorial page count: \(totalTutorialPageCount)")
        
        currentTutorialPage = 1
        
        adjustTutorial()
        
        updateToCurrentTutorial()
        
        hideTutorialEndButton()
        
    }
    
    func tutorialAddSubviews() {
        assert(displayingTutorial, "tutorialAddSubviews() called when displayingTutorial == false")
//        tutorialView = UIView()
        self.view.addSubview(tutorialView)
        tutorialView.addSubview(tutorialTitle)
//        tutorialTitle.text = "Tutorial Page " + String(currentTutorialPage)
        tutorialView.addSubview(tutorialImageView)
        tutorialView.addSubview(tutorialEndButton)
        tutorialView.addSubview(tutorialSkipButton)
        tutorialView.addSubview(pageDots)
//        pageDots.numberOfPages = totalTutorialPageCount
    }
    
    func updateToCurrentTutorial() {
        assert(displayingTutorial, "updateToCurrentTutorial() called when displayingTutorial == false")
        tutorialTitle.text = "Tutorial Page " + String(currentTutorialPage)
        tutorialTitle.sizeToFit()
        pageDots.currentPage = currentTutorialPage - 1
    }
    
    func removeTutorial() {
        displayingTutorial = false
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
}
