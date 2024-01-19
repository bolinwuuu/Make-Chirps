//
//  ThumbView.swift
//  ColorCreator
//
//  Created by Bolin Wu on 11/26/23.
//

import Foundation
import UIKit

final class ThumbView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        let darkOrange = UIColor(red: 175/255, green: 55/255, blue: 0/255, alpha: 1)
//        backgroundColor = UIColor(red: 183 / 255, green: 122 / 255, blue: 231 / 255, alpha: 1)
        backgroundColor = darkOrange
//        let middleView = UIView(frame: .init(x: frame.midX - 6, y: frame.midY - 6, width: 12, height: 12))
//        middleView.backgroundColor = darkOrange
//        middleView.layer.cornerRadius = 6
//        addSubview(middleView)
    }
}

// Step 4
extension UIView {

    var snapshot: UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let capturedImage = renderer.image { context in
            layer.render(in: context.cgContext)
        }
        return capturedImage
    }
}
