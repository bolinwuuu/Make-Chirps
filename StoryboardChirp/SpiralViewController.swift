//
//  SpiralViewController.swift
//  StoryboardChirp
//
//  Created by Bolin Wu on 2/27/23.
//

import UIKit
import SwiftUI

class SpiralViewController: UIViewController {

    var spiralView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        

        testChirp.initSpiral()
        let spiralUIIm = testChirp.genSpiralAnimation()
        
//        spectView = Spectrogram()
        spiralView = UIView(frame: CGRect(x: 0, y: 0,
                                         width: self.view.frame.size.width,
                                         height: self.view.frame.size.width))
        
        spiralView = UIImageView(image: spiralUIIm)
        spiralView.frame = CGRect(x: 0, y: 0,
                                 width: self.view.frame.size.width,
                                 height: self.view.frame.size.width)

        
        spiralView.center = view.center
        
        self.view.bringSubviewToFront(spiralView)
        
        view.addSubview(spiralView)
    }

}
