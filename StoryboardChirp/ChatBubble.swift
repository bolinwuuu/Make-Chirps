//
//  ChatBubble.swift
//  StoryboardChirp
//
//  Created by Bolin Wu on 3/21/24.
//

import UIKit

class ChatBubble: UIView {

    var upperView: UIView!
    var lowerView: UIView!
    
    var upperColor: UIColor = UIColor(red: 130/255, green: 130/255, blue: 130/255, alpha: 1)
    var lowerColor: UIColor = .darkGray
    var titleColor: UIColor = .white
    var textColor: UIColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    
    var currPageNum: Int = 1
    let totalPageNum: Int = 8
    var pageNumLabel: UILabel!
    
    var closeButton: UIButton!
    var nextButton: UIButton!
    var backButton: UIButton!
    let nextButtonSize: CGSize = CGSize(width: 50, height: 20)
    
    var chatTitle: UILabel!
    var chatText: UILabel!
    
    var titleFontSize: CGFloat = 25.0
    var textFontSize: CGFloat = 20.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    
    func moveTo(new_origin: CGPoint) {
        upperView.frame.origin = new_origin
        lowerView.frame.origin = CGPoint(x: upperView.frame.minX, y: upperView.frame.maxY)
    }
    
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
        let shapeLayer = CAShapeLayer()
        let path = UIBezierPath()
        // tail dimensions
        let tailWidth: CGFloat = 20.0
        let tailHeight: CGFloat = 40.0
        let tailPosition = lowerView.frame.height * 0.5 // Adjust this to move the tail up or down
        
        // Add tail
        path.move(to: CGPoint(x: lowerView.frame.maxX, y: tailPosition))
        path.addLine(to: CGPoint(x: lowerView.frame.maxX + tailWidth, y: tailPosition + (tailHeight / 2)))
        path.addLine(to: CGPoint(x: lowerView.frame.maxX, y: tailPosition + tailHeight))
        
        path.close()
        
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = lowerColor.cgColor // Customize bubble color
        
        lowerView.layer.addSublayer(shapeLayer)
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
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .heavy,
                                                       scale: .small)
        closeButton.setImage(UIImage(systemName: "xmark", withConfiguration: buttonConfig), for: .normal)
        closeButton.tintColor = textColor
        closeButton.frame = CGRect(x: 0, y: 0,
                                   width: upperView.frame.height / 2.5, height: upperView.frame.height / 2.5)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        upperView.addSubview(closeButton)
        closeButton.center = CGPoint(x: upperView.frame.width * (14/15), y: upperView.center.y)
    }
    
    private func addNextButton() {
        nextButton = UIButton(type: .system)
        nextButton.tintColor = titleColor
        nextButton.frame.size = nextButtonSize
        nextButton.setTitle("Next", for: .normal)
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 50)
        nextButton.titleLabel?.adjustsFontSizeToFitWidth = true
        nextButton.titleLabel?.minimumScaleFactor = 0.3
        nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        lowerView.addSubview(nextButton)
        nextButton.center = CGPoint(x: lowerView.frame.width * (7/8), y: lowerView.frame.height * (5/6))
    }
    
    private func addBackButton() {
        backButton = UIButton(type: .system)
        backButton.tintColor = textColor
        backButton.frame.size = nextButtonSize
        backButton.setTitle("Back", for: .normal)
        backButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 50)
        backButton.titleLabel?.adjustsFontSizeToFitWidth = true
        backButton.titleLabel?.minimumScaleFactor = 0.3
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
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
        chatText.frame = CGRect(x: lowerView.frame.width * (1/25), y: chatTitle.frame.maxY + lowerView.frame.height * (1/30),
                                width: lowerView.frame.width * 0.8, height: lowerView.frame.height * 0.5)
        chatText.textColor = textColor
        lowerView.addSubview(chatText)
    }
    
    @objc func closeButtonPressed() {
        print("close button pressed")
    }
    
    @objc func nextButtonPressed() {
        print("next button pressed")
    }
    
    @objc func backButtonPressed() {
        print("back button pressed")
    }

    func updatePageNum(num: Int) {
        currPageNum = num + 1
        pageNumLabel.text = String(currPageNum) + "/" + String(totalPageNum)
        pageNumLabel.sizeToFit()
    }

}
