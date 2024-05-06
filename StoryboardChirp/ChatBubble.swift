//
//  ChatBubble.swift
//  StoryboardChirp
//
//  Created by Bolin Wu on 3/21/24.
//

import UIKit

protocol ChatBubbleDelegate: AnyObject {
    func didPressButtonInChatBubble(_ action: ChatBubble.Action)
}

class ChatBubble: UIView {
    enum Action {
        case closeBubble
        case nextBubble
        case backBubble
        // Add more actions for additional buttons
    }
    weak var delegate: ChatBubbleDelegate?

    var upperView: UIView!
    var lowerView: UIView!
    var bubbleTail: UIView!
    
    var upperColor: UIColor = UIColor(red: 130/255, green: 130/255, blue: 130/255, alpha: 1)
    var lowerColor: UIColor = .darkGray
    var titleColor: UIColor = .white
    var textColor: UIColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    
    var currPageNum: Int = 1
    var totalPageNum: Int = 7
    var pageNumLabel: UILabel!
    
    var closeButton: UIButton!
    var nextButton: UIButton!
    var backButton: UIButton!
    let nextButtonSize: CGSize = CGSize(width: 50, height: 20)
    
    var chatTitle: UILabel!
    var chatText: UILabel!
    
    var titleFontSize: CGFloat = 25.0
    var textFontSize: CGFloat = 20.0
    
    init(frame: CGRect, totalPageNumber: Int) {
        super.init(frame: frame)
        totalPageNum = totalPageNumber
//        self.backgroundColor = .clear // Ensure transparent background
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        self.backgroundColor = .clear // Ensure transparent background
        setupSubviews()
    }
    
    private func setupSubviews() {
        setupBackground()
        addTail()
        setupPageNum()
        addCloseButton()
        addNextButton()
        addBackButton()
        addChatTitle()
        addChatText()
    }
    
    func pointTo(screenFrame: CGRect, itemFrame: CGRect,
                 xMin: CGFloat, xMax: CGFloat, yMin: CGFloat, yMax: CGFloat) {
        let dir = pointDirection(screenFrame: screenFrame, itemFrame: itemFrame)
        print("point", dir)
        switch dir {
        case "left":
            let target = CGPoint(x: itemFrame.maxX, y: itemFrame.midY)
            pointHorizontally(position: target, dir: "left", yMin: yMin, yMax: yMax)
        case "right":
            let target = CGPoint(x: itemFrame.minX, y: itemFrame.midY)
            pointHorizontally(position: target, dir: "right", yMin: yMin, yMax: yMax)
        case "up":
            let target = CGPoint(x: itemFrame.midX, y: itemFrame.maxY)
            pointVertically(position: target, dir: "up", xMin: xMin, xMax: xMax)
        case "down":
            let target = CGPoint(x: itemFrame.midX, y: itemFrame.minY)
            pointVertically(position: target, dir: "down", xMin: xMin, xMax: xMax)
        default:
            print("error in pointTo")
        }
    }
    
    func pointDirection(screenFrame: CGRect, itemFrame: CGRect) -> String {
        if itemFrame.midX < screenFrame.width / 2 {
            // item in left
            if screenFrame.width - itemFrame.maxX > self.frame.width {
                // point left
                return "left"
            } else if itemFrame.midY < screenFrame.height / 2 {
                // point up
                return "up"
            } else {
                // point down
                return "down"
            }
        } else {
            // item in right
            if itemFrame.minX > self.frame.width {
                // point right
                return "right"
            } else if itemFrame.midY < screenFrame.height / 2 {
                // point up
                return "up"
            } else {
                // point down
                return "down"
            }
        }
        return "error in pointDirection"
    }
    
    func pointHorizontally(position: CGPoint, dir: String, yMin: CGFloat, yMax: CGFloat) {
        assert(dir == "left" || dir == "right")
        defaultTail(dir: dir)
        let padding: CGFloat = 10
        var centerY = position.y - tailY() + self.frame.height / 2
        if centerY - self.frame.height / 2 < yMin {
            moveTailTo(newY: bubbleTail.frame.height / 2)
            centerY = position.y - tailY() + self.frame.height / 2
        } else if centerY + self.frame.height / 2 > yMax {
            moveTailTo(newY: self.frame.height - bubbleTail.frame.height / 2)
            centerY = position.y - tailY() + self.frame.height / 2
        }
        var centerX: CGFloat = 0
        if dir == "right" {
            centerX = position.x - padding - bubbleTail.frame.width - self.frame.width / 2
        } else {
            centerX = position.x + padding + bubbleTail.frame.width + self.frame.width / 2
        }
        self.center = CGPoint(x: centerX, y: centerY)
        
    }
    
    func pointVertically(position: CGPoint, dir: String, xMin: CGFloat, xMax: CGFloat) {
        assert(dir == "up" || dir == "down")
        defaultTail(dir: dir)
        let padding: CGFloat = 10
        var centerX = position.x - tailX() + self.frame.width / 2
        if centerX - self.frame.width / 2 < xMin {
            moveTailTo(newX: bubbleTail.frame.width / 2)
            centerX = position.x - tailX() + self.frame.width / 2
        } else if centerX + self.frame.width / 2 > xMax {
            moveTailTo(newX: self.frame.width - bubbleTail.frame.width / 2)
            centerX = position.x - tailX() + self.frame.width / 2
        }
        var centerY: CGFloat = 0
        if dir == "down" {
            centerY = position.y - padding - bubbleTail.frame.height - self.frame.height / 2
        } else {
            centerX = position.y + padding + bubbleTail.frame.height + self.frame.height / 2
        }
        self.center = CGPoint(x: centerX, y: centerY)
        
    }
    
    func tailX() -> CGFloat {
        return bubbleTail.center.x
    }
    
    func tailY() -> CGFloat {
        return bubbleTail.center.y
    }
    
    func moveTailTo(newCenter: CGPoint) {
        bubbleTail.center = newCenter
    }
    
    func moveTailTo(newX: CGFloat) {
        bubbleTail.center = CGPoint(x: newX, y: bubbleTail.center.y)
    }
    
    func moveTailTo(newY: CGFloat) {
        bubbleTail.center = CGPoint(x: bubbleTail.center.x, y: newY)
    }
    
    func defaultTail(dir: String) {
        let defaultX = lowerView.center.y + bubbleTail.frame.width / 2
        let defaultY = lowerView.center.y + bubbleTail.frame.height / 2
        switch dir {
        case "left":
            moveTailTo(newCenter: CGPoint(x: lowerView.frame.minX, y: defaultY))
        case "right":
            moveTailTo(newCenter: CGPoint(x: lowerView.frame.maxX, y: defaultY))
        case "up":
            moveTailTo(newCenter: CGPoint(x: defaultX, y: upperView.frame.minX))
        case "down":
            moveTailTo(newCenter: CGPoint(x: defaultX, y: lowerView.frame.maxY))
        default:
            print("default dir: right")
            moveTailTo(newCenter: CGPoint(x: lowerView.frame.maxX, y: defaultY))
        }
//        let defaultY = lowerView.center.y + bubbleTail.frame.height / 2
//        moveTailTo(newY: defaultY)
    }
    
//    func moveTo(new_origin: CGPoint) {
//        upperView.frame.origin = new_origin
//        lowerView.frame.origin = CGPoint(x: upperView.frame.minX, y: upperView.frame.maxY)
//    }
    
    private func setupBackground() {
        upperView = UIView(frame: CGRect(x: 0, y: 0,
                                         width: self.frame.width, height: self.frame.height / 5))
        upperView.backgroundColor = upperColor
        upperView.layer.cornerRadius = 10
        upperView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Top left and top right corners
        self.addSubview(upperView)
        
        lowerView = UIView(frame: CGRect(x: upperView.frame.minX, y: upperView.frame.maxY,
                                         width: upperView.frame.width, height: self.frame.height - upperView.frame.height))
        lowerView.backgroundColor = lowerColor
        lowerView.layer.cornerRadius = 10
        lowerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] // Bottom left and bottom right corners
        self.addSubview(lowerView)
    }
    
    private func addTail() {
        let w: CGFloat = 40
        let h: CGFloat = 40
        bubbleTail = UIView(frame: CGRect(x: lowerView.frame.maxX - w / 2, y: lowerView.center.y,
                                          width: w, height: h))
        bubbleTail.backgroundColor = .clear
        drawTail()
        self.addSubview(bubbleTail)
        self.sendSubviewToBack(bubbleTail)
    }
    
    private func drawTail() {
        let shapeLayer = CAShapeLayer()
        let path = UIBezierPath()
        
        // Add tail
        path.move(to: CGPoint(x: bubbleTail.frame.width / 2, y: 0))
        path.addLine(to: CGPoint(x: bubbleTail.frame.width, y: bubbleTail.frame.height / 2))
        path.addLine(to: CGPoint(x: bubbleTail.frame.width / 2, y: bubbleTail.frame.height))
        path.addLine(to: CGPoint(x: 0, y: bubbleTail.frame.height / 2))
        
        path.close()
        
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = lowerColor.cgColor // Customize bubble color
        
        bubbleTail.layer.addSublayer(shapeLayer)
    }
    
    private func setupPageNum() {
        pageNumLabel = UILabel()
        pageNumLabel.text = String(currPageNum) + "/" + String(totalPageNum)
        pageNumLabel.font = UIFont.boldSystemFont(ofSize: pageNumLabel.font.pointSize)
        pageNumLabel.sizeToFit()
        pageNumLabel.textColor = titleColor
        upperView.addSubview(pageNumLabel)
        pageNumLabel.center = CGPoint(x: upperView.frame.width / 15, y: upperView.center.y)
    }
    
    private func addCloseButton() {
        closeButton = UIButton(type: .system)
        closeButton.tag = 1
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .heavy,
                                                       scale: .small)
        closeButton.setImage(UIImage(systemName: "xmark", withConfiguration: buttonConfig), for: .normal)
        closeButton.tintColor = textColor
        closeButton.frame = CGRect(x: 0, y: 0,
                                   width: upperView.frame.height / 2.5, height: upperView.frame.height / 2.5)
        closeButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        upperView.addSubview(closeButton)
        closeButton.center = CGPoint(x: upperView.frame.width * (14/15), y: upperView.center.y)
    }
    
    private func addNextButton() {
        nextButton = UIButton(type: .system)
        nextButton.tag = 2
        nextButton.tintColor = titleColor
        nextButton.frame.size = nextButtonSize
        nextButton.setTitle("Next", for: .normal)
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 50)
        nextButton.titleLabel?.adjustsFontSizeToFitWidth = true
        nextButton.titleLabel?.minimumScaleFactor = 0.3
        nextButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        lowerView.addSubview(nextButton)
        nextButton.center = CGPoint(x: lowerView.frame.width * (7/8), y: lowerView.frame.height * (5/6))
    }
    
    private func addBackButton() {
        backButton = UIButton(type: .system)
        backButton.tag = 3
        backButton.tintColor = textColor
        backButton.frame.size = nextButtonSize
        backButton.setTitle("Back", for: .normal)
        backButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 50)
        backButton.titleLabel?.adjustsFontSizeToFitWidth = true
        backButton.titleLabel?.minimumScaleFactor = 0.3
        backButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        lowerView.addSubview(backButton)
        backButton.center = CGPoint(x: lowerView.frame.width * (1/8), y: lowerView.frame.height * (5/6))
    }
    
    private func addChatTitle() {
        chatTitle = UILabel()
        chatTitle.text = "Test Title"
        chatTitle.font = UIFont.boldSystemFont(ofSize: titleFontSize)
        chatTitle.textAlignment = .left
        chatTitle.frame = CGRect(x: lowerView.frame.width * (1/25), y: lowerView.frame.height * (1/16),
                                 width: lowerView.frame.width * 0.8, height: 30)
        chatTitle.textColor = titleColor
        lowerView.addSubview(chatTitle)
    }
    
    private func addChatText() {
        chatText = UILabel()
        chatText.text = "Test text content. Test text content. Test text content. Test text content. Test text content. Test text content. Test text content. Test text content."
        chatText.font = chatText.font.withSize(textFontSize)
        chatText.numberOfLines = 0
        chatText.lineBreakMode = .byWordWrapping
        chatText.textAlignment = .left
        chatText.frame = CGRect(x: lowerView.frame.width * (1/25), y: chatTitle.frame.maxY,
                                width: lowerView.frame.width * 0.8, height: lowerView.frame.height * 0.5)
        chatText.textColor = textColor
        lowerView.addSubview(chatText)
    }
    
    @objc func buttonPressed(sender: UIButton) {
        switch sender.tag {
        case 1:
            print("close button pressed")
            delegate?.didPressButtonInChatBubble(.closeBubble)
        case 2:
            print("next button pressed")
            delegate?.didPressButtonInChatBubble(.nextBubble)
        case 3:
            print("back button pressed")
            delegate?.didPressButtonInChatBubble(.backBubble)
        // Handle other buttons
        default:
            break
        }
    }
    
//    @objc func closeButtonPressed() {
//        print("close button pressed")
//    }
//    
//    @objc func nextButtonPressed() {
//        print("next button pressed")
//    }
//    
//    @objc func backButtonPressed() {
//        print("back button pressed")
//    }

    func updatePageNum(num: Int) {
        currPageNum = num
        pageNumLabel.text = String(currPageNum) + "/" + String(totalPageNum)
        pageNumLabel.sizeToFit()
    }
    
    func updateTitle(text: String) {
        chatTitle.text = text
    }
    
    func updateContent(text: String) {
        chatText.text = text
    }

}
