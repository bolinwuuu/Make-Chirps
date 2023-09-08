//
//  InfoPageVC.swift
//  StoryboardChirp
//
//  Created by Kurt Beyer on 9/7/23.
//

import Foundation
import UIKit
import PDFKit

class InfoPageVC: UIViewController {
    let pdfview = PDFView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pdfview)
        // credit to iOS Academy, https://www.youtube.com/watch?v=GaNYWnlV3R4
        guard let infoPdfURL = Bundle.main.url(forResource: "infotest", withExtension: "pdf") else {
            return
        }
        guard let pdfDoc = PDFDocument(url: infoPdfURL) else {
            return
        }
        // pdfview.document = PDFDocument()
        pdfview.pageShadowsEnabled = false
        pdfview.document = pdfDoc
        
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.image = UIImage(named: "gw_spiral_bw.jpeg") // Use your image name
        imageView.contentMode = .scaleAspectFill // Adjust as required
        self.view.addSubview(imageView)

        self.view.sendSubviewToBack(imageView)
        pdfview.pageBreakMargins = UIEdgeInsets.zero
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
  // let pct: Double = 0.2
        //let newRect = CGRectInset(view.bounds, CGRectGetWidth(view.bounds)*pct/2, CGRectGetHeight(view.bounds)*pct/2);

        pdfview.frame = view.bounds
        // pdfview.center
        pdfview.center = view.center
       // pdfview.backgroundColor = UIColor.clear
        pdfview.scaleFactor = 1.4
        pdfview.pageBreakMargins = UIEdgeInsets.zero
        
    }
}
