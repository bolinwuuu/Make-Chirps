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
            // entering last page, show Start button
            showTutorialEndButton()
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
        
        tutorialTitleText = [TUTORIALTITLE0, TUTORIALTITLE1, TUTORIALTITLE2,
                          TUTORIALTITLE3, TUTORIALTITLE4, TUTORIALTITLE5, TUTORIALTITLE6, TUTORIALTITLE7]
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
        tutorialView.backgroundColor = .white
        tutorialView.alpha = 1
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
        tutorialTitle.text = tutorialTitleText[currentTutorialPage]
        tutorialTitle.sizeToFit()
        tutorialTitle.center = CGPoint(x: tutorialView.center.x, y: tutorialView.frame.height * (1/4))
        pageDots.currentPage = currentTutorialPage
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
