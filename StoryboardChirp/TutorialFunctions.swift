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
            pageDots.currentPage = currentTutorialPage - 1
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
            pageDots.currentPage = currentTutorialPage - 1
        }
    }
    
    // the Start button at the last tutorial page
    @IBAction func tutorialEndPressed(_ sender: Any) {
        removeTutorial()
//        UserDefaults.standard.set("Done", forKey: "Tutorial")
    }
    
    func setupTutorialIfNeeded() {
        if isFirstTimeUser() {
            setupTutorial()
        }
    }
    
    // set up tutorial pages for first-time users
    // (tutorial views already on the screen)
    func setupTutorial() {
        displayingTutorial = true
        
        totalTutorialPageCount = pageDots.numberOfPages
        
        hideTutorialEndButton()
        
//        tutorialTitle.centerXAnchor.constraint(equalTo: tutorialView.centerXAnchor).isActive = true
        
    }
    
    func updateToCurrentTutorial() {
        pageDots.currentPage = currentTutorialPage - 1
    }
    
    func removeTutorial() {
        displayingTutorial = false
        tutorialView.removeFromSuperview()
        pageDots.isHidden = true
        hideTutorialEndButton()
        tutorialImageView.removeFromSuperview()
        tutorialTitle.isHidden = true
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
