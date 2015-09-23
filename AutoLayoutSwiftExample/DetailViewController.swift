//
//  DetailViewController.swift
//  AutoLayoutSwiftExample
//
//  Created by SolaWing on 15/9/23.
//  Copyright © 2015年 SW. All rights reserved.
//

import UIKit

func showBorder(v : UIView) -> UIView {
    v.layer.borderWidth = 1;
    v.layer.borderColor = UIColor.lightGrayColor().CGColor
    return v
}

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            let name = (detail as! String).stringByReplacingOccurrencesOfString(" ", withString: "_")
            let sel = sel_getUid(name)
            self.performSelector(sel)
        }
    }



    func System_Visual_Layout() {
        print("System_Visual_Layout")
        let sv = UIScrollView(frame: self.view.frame)
        self.view.addSubview(sv)
        [sv,self.topLayoutGuide].installFullConstraintsWithVisualFormat("|[0]|;V:[1][0]|")

        let l1 = UILabel(); l1.text = "System Visual Layout"
        sv.addSubview(l1)
        showBorder(l1)

        let v1 = UIView()
        showBorder(v1)
        sv.addSubview(v1)

        let btn = UIButton(type: UIButtonType.System)
        showBorder(btn)
        btn.layer.cornerRadius = 5.0
        btn.backgroundColor = UIColor.blueColor()

        let tf = UITextField()
        tf.borderStyle = UITextBorderStyle.Bezel
        v1.addSubview(btn)
        v1.addSubview(tf)

        // Standard Space
        ["btn":btn, "tf":tf].installFullConstraintsWithVisualFormat("[btn]-[tf]")
        // Width Constraint
        ["btn":btn].installConstraintsWithVisualFormat("[btn(>=100)]")
        // Connection to SuperView, vertically
        ["btn":btn].installConstraintsWithVisualFormat("V:|-[btn]-10-|")
        // add lack constraint
        [v1,l1,btn,tf].installFullConstraintsWithVisualFormat("V:|[1(X|)]-[0] X; H:|-[2(Y$3)];[3(>=100)]-|")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

