//
//  VC_Acknowledgements.swift
//  StoryboardChirp
//
//  Created by Kurt Beyer on 9/7/23.
//Test

import Foundation
import UIKit
import PDFKit
import WebKit

class VC_Acknowledgements: UIViewController, WKUIDelegate {
    
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
          //let myURL = URL(string:"https://chirp-dev.kurtb.net/acknowledgements.html")
          //let myRequest = URLRequest(url: myURL!)
              //webView.load(myRequest)
          if let htmlPath = Bundle.main.url(forResource: "acknowledgements", withExtension: "html", subdirectory: "ligohtml/html") {
              let request = URLRequest(url: htmlPath)
              webView.load(request)
          }
      }
        
}
