//
//  DetailViewController.swift
//  CapitalCities
//
//  Created by Julian Moorhouse on 12/08/2019.
//  Copyright © 2019 Mindwarp Consultancy Ltd. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    @IBOutlet var webView: WKWebView!
    
    var capital: Capital!
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }

    override func viewDidLoad() {
        
        title = capital.title
        
        if let url = URL(string: capital.wikiUrl) {
            webView.load(URLRequest(url: url))
        }
    }
}
