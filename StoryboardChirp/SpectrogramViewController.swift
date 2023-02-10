//
//  SpectrogramViewController.swift
//  StoryboardChirp
//
//  Created by Bolin Wu on 1/27/23.
//

import UIKit
import SwiftUI

class SpectrogramViewController: UIViewController {

//    var testSpect = Spectrogram(run_chirp: &testChirp)

    
    
    var spectView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        var spectUIIm = Spectrogram(run_chirp: &testChirp).genSpectrogram()
        
//        spectView = Spectrogram()
        spectView = UIView(frame: CGRect(x: 0, y: 0,
                                         width: self.view.frame.size.width,
                                         height: self.view.frame.size.width))
        
//        let myLayer = CALayer()
//        // let myImage = im
//        myLayer.frame = CGRect(x: 0, y: 0,
//                               width: self.view.frame.size.width,
//                               height: self.view.frame.size.width)
//        myLayer.contents = spectUIIm
//        print("line1")
//        spectView.layer.addSublayer(myLayer)
//        print("line2")
        
        spectView = UIImageView(image: spectUIIm)
        spectView.frame = CGRect(x: 0, y: 0,
                                 width: self.view.frame.size.width,
                                 height: self.view.frame.size.width)

        
        spectView.center = view.center
        
        self.view.bringSubviewToFront(spectView)
        
        view.addSubview(spectView)
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//
//    }
    
    
    
    
//    func Spectrogram() -> some View {
//        return Image(uiImage: spectUIIm)
//            .resizable()
//            .frame(width: 600, height: 470)
//            //.frame(width: 400, height: 470)
//
//
//    }

}
