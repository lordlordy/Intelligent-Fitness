//
//  WebViewController.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 18/07/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var htmlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let s = htmlString{
            loadHTML(html: s)
        }
        
        // Do any additional setup after loading the view.
    }
    
    private func loadHTML(html: String){
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let s = htmlString{
            loadHTML(html: s)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
