//  Gihhub: https://github.com/SolaWing/AutoLayoutVisualFormatLanguage
//
//  DetailViewController.swift
//  AutoLayoutSwiftExample
//
//  Created by SolaWing on 15/9/23.
//  Copyright © 2015年 SW. All rights reserved.
//

import UIKit
import VFL

class DetailViewController: UIViewController {

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
            self.navigationItem.title = detailItem as? String
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            let appName : String = Bundle.main
                .object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
            let name = String(format: "%@.%@Example", appName,
                (detail as! String).replacingOccurrences(of: " ", with:"") )
            print("name is \(name)")
            let view: UIView =  (objc_getClass(name)
                as! UIView.Type).init(frame: CGRect.zero)
            self.view.addSubview(view)
            view.VFLFullInstall("Left,Right, Bottom,Top=\(self.topLayoutGuide).Bottom")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

