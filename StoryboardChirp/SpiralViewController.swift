//
//  SpiralViewController.swift
//  StoryboardChirp
//
//  Created by Bolin Wu on 2/27/23.
//

import UIKit
import SwiftUI

class SpiralViewController: UIViewController {
    let frameScale = 0.8
    var spiralView: UIView! = UIView()
    
    @IBOutlet weak var speedSlider: UISlider!
    
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var displayButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        testChirp.initSpiral()
        spiralView.isHidden = true
    }

    @IBAction func changeSpeed(_ sender: Any) {
        speedLabel.text = "x \(round(speedSlider.value * 100) / 100.0)"
    }
    @IBAction func pressDisplay(_ sender: Any) {
        self.spiralView.removeFromSuperview()
        
        let speedX = Double(speedSlider.value)
        let spiralUIIm = testChirp.genSpiralAnimation(speedX: speedX)
        
//        spectView = Spectrogram()
        spiralView = UIView(frame: CGRect(x: 0, y: 0,
                                         width: self.view.frame.size.width * frameScale,
                                         height: self.view.frame.size.width * frameScale))
        
        spiralView = UIImageView(image: spiralUIIm)
        spiralView.frame = CGRect(x: 0, y: 0,
                                 width: self.view.frame.size.width * frameScale,
                                 height: self.view.frame.size.width * frameScale)

        
        spiralView.center = view.center
        
        
        displayWithTime(duration: Double(spiralUIIm.duration))
    }
    
    func displayWithTime(duration: Double) {
//        self.view.bringSubviewToFront(spiralView)
        self.spiralView.removeFromSuperview()
        view.addSubview(spiralView)
        
        UIView.animate(withDuration: 0, delay: duration, animations: {
            self.spiralView.alpha = 0
        }) {_ in
            self.spiralView.removeFromSuperview()
            
        }
    }
//    func displayWithTime(duration: Double) {
//        spiralView.isHidden = false
//        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.transitionFlipFromTop, animations: {
//            self.spiralView.alpha = 0
//        }, completion: { finished in
//            self.spiralView.isHidden = true
//            self.spiralView.alpha = 1
//        })
//    }
    
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
        
//        testChirp.initSpiral()
//        let spiralUIIm = testChirp.genSpiralAnimation(speedX: Double(speedSlider.value))
//
////        spectView = Spectrogram()
//        spiralView = UIView(frame: CGRect(x: 0, y: 0,
//                                         width: self.view.frame.size.width * frameScale,
//                                         height: self.view.frame.size.width * frameScale))
//
//        spiralView = UIImageView(image: spiralUIIm)
//        spiralView.frame = CGRect(x: 0, y: 0,
//                                 width: self.view.frame.size.width * frameScale,
//                                 height: self.view.frame.size.width * frameScale)
//
//
//        spiralView.center = view.center
//
//        self.view.bringSubviewToFront(spiralView)
//
//        view.addSubview(spiralView)
//    }
}
