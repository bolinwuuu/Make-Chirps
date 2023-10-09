//
//  InfoPageVC.swift
//  StoryboardChirp
//
//  Created by Kurt Beyer on 9/7/23.
//

import Foundation
import UIKit
import PDFKit
import WebKit

class InfoPageVC: UIViewController, WKUIDelegate {
    
    /*
    let pdfview = PDFView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pdfview)
        
        let label = UILabel(frame: CGRect(x: 100, y: 200, width: 220, height: 50))
        label.text = "Welcome to my app!";
        view.addSubview(label)
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
        */
    
    var webView: WKWebView!
      
      override func loadView() {
          let webConfiguration = WKWebViewConfiguration()
          webView = WKWebView(frame: .zero, configuration: webConfiguration)
          webView.uiDelegate = self
          view = webView
      }


      override func viewDidLoad() {
          super.viewDidLoad()
          self.navigationController?.navigationBar.isHidden = true
          let myURL = URL(string:"https://chirp-dev.kurtb.net")
          let myRequest = URLRequest(url: myURL!)
          webView.load(myRequest)
      }
        
    }
  /*
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
 /*  // let pct: Double = 0.2
        //let newRect = CGRectInset(view.bounds, CGRectGetWidth(view.bounds)*pct/2, CGRectGetHeight(view.bounds)*pct/2);

        pdfview.frame = view.bounds
        // pdfview.center
       // pdfview.center = view.center
       // pdfview.backgroundColor = UIColor.clear
        pdfview.scaleFactor = 1.4
        pdfview.pageBreakMargins = UIEdgeInsets.zero */
        
    }
   */

