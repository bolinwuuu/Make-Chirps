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
        nextTutorialPage()
    }
    
    @IBAction func swipeRight(_ sender: Any) {
        print("swipe right")
        backTutorialPage()
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
        
//        totalTutorialPageCount = pageDots.numberOfPages
        pageDots.numberOfPages = totalTutorialPageCount
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
        
        updateChatBubble()
        updateHighlightWindow()
        
        pageDots.currentPage = currentTutorialPage
    }
    
    func leaveFirstPage() {
        tutorialView.backgroundColor = .black.withAlphaComponent(0.3)
//        setupRedRect()
//        tutorialView.addSubview(redRect)
        
        setupChatBubble()
        tutorialView.addSubview(chatBubble)
    }
    
    func enterFirstPage() {
        tutorialView.backgroundColor = .white.withAlphaComponent(1)
//        redRect.removeFromSuperview()
        chatBubble.removeFromSuperview()
        removeHighlightWindow()
    }
    
    func leaveLastPage() {
        tutorialView.backgroundColor = .black.withAlphaComponent(0.3)
        hideTutorialEndButton()
        showChatBubbleNextButton()
        setupChatBubble()
        tutorialView.addSubview(chatBubble)
    }
    
    func enterLastPage() {
        tutorialView.backgroundColor = .white.withAlphaComponent(1)
        showTutorialEndButton()
        hideChatBubbleNextButton()
        chatBubble.removeFromSuperview()
        removeHighlightWindow()
    }
    
    func setupChatBubble() {
        chatBubble = ChatBubble(frame: CGRect(x: tutorialView.center.x, y: tutorialView.center.y,
                                              width: 500, height: 200),
                                totalPageNumber: totalTutorialPageCount - 2)
        chatBubble.delegate = self
    }
    
    func didPressButtonInChatBubble(_ action: ChatBubble.Action) {
        switch action {
        case .closeBubble:
            removeTutorial()
        case .nextBubble:
            nextTutorialPage()
        case .backBubble:
            backTutorialPage()
        // Handle other actions
        }
    }
    
//    func setupRedRect() {
//        redRect = UIView(frame: waveformButton.frame)
//        redRect.layer.borderColor = UIColor.red.cgColor
//        redRect.layer.borderWidth = 10
//        redRect.layer.cornerRadius = 10
//        redRect.backgroundColor = .clear
//    }
    
    func updateChatBubble() {
        if currentTutorialPage > 0 && currentTutorialPage < totalTutorialPageCount - 1 {
            updateChatBubblePosition()
            chatBubble.updatePageNum(num: currentTutorialPage)
            updateChatBubbleText()
        }
    }
    
    func updateChatBubblePosition() {
        let buttonList = [waveformButton, freqButton, spectroButton, audioButton,
                          animButton, spiralButton, tutorialButton]
        let pointedButton = buttonList[currentTutorialPage - 1]
        let pointedPosition: CGPoint = CGPoint(x: CGFloat((pointedButton!.frame.minX)),
                                               y: CGFloat((pointedButton!.center.y)))
        chatBubble.pointTo(position: pointedPosition,
                           yMin: windowFrame.frame.minY, yMax: spiralButton.frame.maxY)
        chatBubble.updatePageNum(num: currentTutorialPage)
    }
    
    func updateChatBubbleText() {
        chatBubble.updateTitle(text: tutorialTitleText[currentTutorialPage])
        chatBubble.updateContent(text: tutorialContentText[currentTutorialPage])
    }
    
    func updateHighlightWindow() {
        if currentTutorialPage > 0 && currentTutorialPage < totalTutorialPageCount - 1 {
            let buttonList = [waveformButton, freqButton, spectroButton, audioButton,
                              animButton, spiralButton, tutorialButton]
            let pointedButton = buttonList[currentTutorialPage - 1]
            updateHighlightWindowPosition(to: pointedButton!.frame)
        }
    }
    
    func nextTutorialPage() {
        if currentTutorialPage == totalTutorialPageCount - 2 {
            // entering the last page, show Start button
            enterLastPage()
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
    
    func backTutorialPage() {
        if currentTutorialPage == totalTutorialPageCount - 1 {
            // swiping right from the last page, remove Start button
            leaveLastPage()
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
    
    // create the highlight window
    private func createMaskLayer() {
        let maskLayer = CAShapeLayer()
        
        // Create a path for the entire TutorialView
        let path = UIBezierPath(rect: tutorialView.bounds)
        
        // Add the "window" path if it's been set
        if !highlightRect.equalTo(.zero) {
            let windowPath = UIBezierPath(rect: highlightRect)
            path.append(windowPath)
        }
        
        // Use the even-odd fill rule to create the transparency effect
        maskLayer.fillRule = .evenOdd
        maskLayer.path = path.cgPath
        
        // Apply the mask to the TutorialView
        tutorialView.layer.mask = maskLayer
    }
    
    // update highlight window position
    func updateHighlightWindowPosition(to rect: CGRect) {
        highlightRect = rect // Update the window rectangle
        createMaskLayer() // Reapply the mask with the new window
    }
    
    func removeHighlightWindow() {
        highlightRect = .zero // Reset the window rectangle
        createMaskLayer() // Reapply the mask without the window
    }
    
    func removeTutorial() {
        displayingTutorial = false
//        if redRect != nil {
//            redRect.removeFromSuperview()
//        }
        if chatBubble != nil {
            chatBubble.removeFromSuperview()
        }
        removeHighlightWindow()
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
    
    func showChatBubbleNextButton() {
        chatBubble.nextButton.isHidden = false
        chatBubble.nextButton.isEnabled = true
    }
    
    func hideChatBubbleNextButton() {
        chatBubble.nextButton.isHidden = true
        chatBubble.nextButton.isEnabled = false
    }
    
    func setupTutorialTitleText() {
        let welcomeTitle = "Welcome to Make Chirps!"
        let waveformTitle = "Waveform Plot"
        let frequencyTitle = "Frequency Plot"
        let spectroTitle = "Spectrogram Plot"
        let audioTitle = "Audio"
        let collisionTitle = "Collision Animation"
        let spiralTitle = "Spiral Animation"
        let lightBulbTitle = "Review the Tutorial Again?"
        let tutorialEndTitle = "Get started!"
        tutorialTitleText = [welcomeTitle,
                             waveformTitle,
                             frequencyTitle,
                             spectroTitle,
                             audioTitle,
                             collisionTitle,
                             spiralTitle,
                             lightBulbTitle,
                             tutorialEndTitle]
        assert(tutorialTitleText.count == totalTutorialPageCount,
                "Number of pages \(totalTutorialPageCount) doesn't match number of title \(tutorialTitleText.count).")
    }
    
    func setupTutorialContentText() {
        let welcomeContent = "Welcome content"
        let waveformContent = "Click on this button to view the waveform plot."
        let frequencyContent = "Click on this button to view the frequency plot."
        let spectroContent = "Click on this button to view the spectrogram plot."
        let audioContent = "Click on this button to hear the audio."
        let collisionContent = "Click on this button to view the animation of star collisions."
        let spiralContent = "Click on this button to view the animation of gravitational wave spiral."
        let lightBulbContent = "Click on this button to recheck the tutorial anytime!"
        let tutorialEndContent = ""
        tutorialContentText = [welcomeContent,
                               waveformContent,
                               frequencyContent, 
                               spectroContent,
                               audioContent, 
                               collisionContent,
                               spiralContent,
                               lightBulbContent,
                               tutorialEndContent]
        assert(tutorialContentText.count == totalTutorialPageCount,
                "Number of pages \(totalTutorialPageCount) doesn't match number of content \(tutorialContentText.count).")
    }
}
