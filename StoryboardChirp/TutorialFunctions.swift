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
        recenterTutorialView()
    }
    
    @IBAction func swipeRight(_ sender: Any) {
        print("swipe right")
        backTutorialPage()
        recenterTutorialView()
    }
    
    // the Start button at the last tutorial page
    @IBAction func tutorialEndPressed(_ sender: Any) {
        assert(currentTutorialPage == 0 || currentTutorialPage == totalTutorialPageCount - 1)
        if currentTutorialPage == totalTutorialPageCount - 1 {
            removeTutorial()
            // COMMENT out the following line: tutorial shows for non first time users as well.
//            UserDefaults.standard.set("Done", forKey: "Tutorial")
        } else {
            nextTutorialPage()
        }
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
        
        setupTutorialTargets()
        setupTutorialTitleText()
        setupTutorialContentText()
        setupTutorialImageName()
        
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
        
        tutorialTitle.textColor = .white
        tutorialContent.isHidden = true
        
        currentTutorialPage = 0
        
        adjustTutorial()
        
        updateToCurrentTutorial()
        
//        hideTutorialEndButton()
        showTutorialEndButton()
        
        recenterTutorialView()
    }
    
    func setupTutorialView() {
        tutorialView.backgroundColor = .black.withAlphaComponent(0.8)
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
        updateTutorialTitle()
        
//        tutorialContent.text = tutorialContentText[currentTutorialPage]
//        tutorialContent.sizeToFit()
//        tutorialContent.center = CGPoint(x: tutorialView.center.x, y: tutorialContent.center.y)
        
        updateChatBubble()
        updateHighlightWindow()
        
        updateTutorialImage()
        adjustTutorialImageView()
        
        pageDots.currentPage = currentTutorialPage
        
//        print("windowFrame.center: \(windowFrame.center)")
//        print("tutorialImageView.center: \(tutorialImageView.center)")
        
    }
    
    func updateTutorialTitle() {
        if currentTutorialPage == 0 || currentTutorialPage == totalTutorialPageCount - 1 {
            // only need title in these two pages
            tutorialTitle.isHidden = false
            tutorialTitle.text = tutorialTitleText[currentTutorialPage]
            tutorialTitle.sizeToFit()
            tutorialTitle.center = CGPoint(x: tutorialView.center.x, y: tutorialTitle.center.y)
        } else {
            tutorialTitle.isHidden = true
        }
    }
    
    func leaveFirstPage() {
        tutorialView.backgroundColor = .black.withAlphaComponent(0.3)
//        setupRedRect()
//        tutorialView.addSubview(redRect)
        hideTutorialEndButton()
        setupChatBubble()
        tutorialView.addSubview(chatBubble)
    }
    
    func enterFirstPage() {
        tutorialView.backgroundColor = .black.withAlphaComponent(0.8)
//        redRect.removeFromSuperview()
        showTutorialEndButton()
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
        tutorialView.backgroundColor = .black.withAlphaComponent(0.8)
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
        let target = tutorialTargets[currentTutorialPage]
        chatBubble.pointTo(screenFrame: UIScreen.main.bounds, itemFrame: target.frame,
                           xMin: sliderRegionView.frame.minX, xMax: spiralButton.frame.maxX,
                           yMin: windowFrame.frame.minY, yMax: spiralButton.frame.maxY)
        chatBubble.updatePageNum(num: currentTutorialPage)
    }
    
    func updateChatBubbleText() {
        chatBubble.updateTitle(text: tutorialTitleText[currentTutorialPage])
        chatBubble.updateContent(text: tutorialContentText[currentTutorialPage])
    }
    
    func updateHighlightWindow() {
        if currentTutorialPage > 0 && currentTutorialPage < totalTutorialPageCount - 1 {
            let target = tutorialTargets[currentTutorialPage]
            updateHighlightWindowPosition(to: target.frame)
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
        print("\n---\nnext page\n---\n")
        print("UIScreen.main.bounds: \(UIScreen.main.bounds)")
        print("self.view.frame: \(self.view.frame)")
        print("scrollView.frame: \(scrollView.frame)")
        print("contentView.frame: \(contentView.frame)")
        print("tutorialView.frame: \(tutorialView.frame)")
        print("\n---\n")
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
        print("\n---\nback page\n---\n")
        print("UIScreen.main.bounds: \(UIScreen.main.bounds)")
        print("self.view.frame: \(self.view.frame)")
        print("scrollView.frame: \(scrollView.frame)")
        print("contentView.frame: \(contentView.frame)")
        print("tutorialView.frame: \(tutorialView.frame)")
        print("\n---\n")
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
    
    func updateTutorialImage() {
        if currentTutorialPage == 7 || currentTutorialPage == 8 {
            // slider region and lightbulb button don't need images
            tutorialImageView.isHidden = true
        } else if currentTutorialPage == 4 {
            // audio, use system speaker image
            tutorialImageView.isHidden = false
            let tutorialImage = UIImage(systemName: tutorialImageName[currentTutorialPage])
            tutorialImageView.image = tutorialImage
            tutorialImageView.contentMode = .scaleAspectFit
        } else {
            tutorialImageView.isHidden = false
            let tutorialImage = UIImage(named: tutorialImageName[currentTutorialPage])
            tutorialImageView.image = tutorialImage
            tutorialImageView.contentMode = .scaleAspectFit
        }
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
    
    func setupTutorialTargets() {
        tutorialTargets = [UIView(), waveformButton, freqButton, spectroButton, audioButton,
                           animButton, spiralButton, sliderRegionView, tutorialButton, UIView()]
        assert(tutorialTargets.count == totalTutorialPageCount,
                "Number of pages \(totalTutorialPageCount) doesn't match number of targets \(tutorialTargets.count).")
    }
    
    func setupTutorialTitleText() {
        let welcomeTitle = "Welcome to Make Chirps!"
        let waveformTitle = "Waveform Plot"
        let frequencyTitle = "Frequency Plot"
        let spectroTitle = "Spectrogram Plot"
        let audioTitle = "Audio"
        let collisionTitle = "Collision Animation"
        let spiralTitle = "Spiral Animation"
        let sliderTitle = "Adjust Masses & Speed"
        let lightBulbTitle = "Review the Tutorial Again?"
        let tutorialEndTitle = "Get started!"
        tutorialTitleText = [welcomeTitle,
                             waveformTitle,
                             frequencyTitle,
                             spectroTitle,
                             audioTitle,
                             collisionTitle,
                             spiralTitle,
                             sliderTitle,
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
        let sliderContent = "Use these sliders to adjust the masses of stars and animation speed."
        let lightBulbContent = "Click on this button to recheck the tutorial anytime!"
        let tutorialEndContent = ""
        tutorialContentText = [welcomeContent,
                               waveformContent,
                               frequencyContent, 
                               spectroContent,
                               audioContent, 
                               collisionContent,
                               spiralContent,
                               sliderContent,
                               lightBulbContent,
                               tutorialEndContent]
        assert(tutorialContentText.count == totalTutorialPageCount,
                "Number of pages \(totalTutorialPageCount) doesn't match number of content \(tutorialContentText.count).")
    }
    
    func setupTutorialImageName() {
        let iconImage = "icon_image"
        let waveformImage = "waveform_example"
        let freqImage = "frequency_example"
        let spectroImage = "spectrogram_example"
        let audioImage = "speaker.2"
        let collisionImage = "collision_example"
        let spiralImage = "spiral_example"
        tutorialImageName = [iconImage,
                             waveformImage,
                             freqImage,
                             spectroImage,
                             audioImage,
                             collisionImage,
                             spiralImage,
                             "",
                             "",
                             iconImage]
        assert(tutorialImageName.count == totalTutorialPageCount,
                "Number of pages \(totalTutorialPageCount) doesn't match number of image names \(tutorialImageName.count).")
    }
    
    func recenterTutorialView() {
        tutorialView.frame.origin = CGPoint(x: scrollView.frame.minX, y: tutorialView.frame.minY)
    }
}
