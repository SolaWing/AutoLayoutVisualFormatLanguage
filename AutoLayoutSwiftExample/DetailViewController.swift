//
//  DetailViewController.swift
//  AutoLayoutSwiftExample
//
//  Created by SolaWing on 15/9/23.
//  Copyright © 2015年 SW. All rights reserved.
//

import UIKit
import VFL


func RGB(color:Int32) -> UIColor {
    return UIColor(red: CGFloat((color>>16)&0xff)/255.0,
        green: CGFloat(color>>8&0xff)/255.0,
        blue: CGFloat(color&0xff)/255.0, alpha: 1.0)
}

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!


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
            let appName : String = NSBundle.mainBundle()
                .objectForInfoDictionaryKey(kCFBundleNameKey as String) as! String
            let name = String(format: "%@.%@Example", appName,
                (detail as! String).stringByReplacingOccurrencesOfString(" ", withString:"") )
            print("name is \(name)")
            let view: UIView =  (objc_getClass(name)
                as! UIView.Type).init(frame: CGRectZero)
            self.view.addSubview(view)
            view.VFLFullInstall("Left,Right, Bottom,Top=\(self.topLayoutGuide).Bottom")
        }
    }

    func showBorder(v : UIView) -> UIView {
        v.layer.borderWidth = 1;
        v.layer.borderColor = UIColor.lightGrayColor().CGColor
        return v
    }

    func System_Visual_Layout() {
        print("System_Visual_Layout")
        
        let sv = UIScrollView(frame: self.view.frame)
        self.view.addSubview(sv)
        VFLFullInstall("|[0]|;V:[1][0]|", [sv, self.topLayoutGuide])

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
        tf.borderStyle = .Bezel
        v1.addSubview(btn)
        v1.addSubview(tf)

        // Standard Space
        VFLFullInstall("[btn]-[tf]", ["btn":btn, "tf":tf])
        // Width Constraint
        VFLInstall("[btn(>=100)]", ["btn":btn])
        // Connection to SuperView, vertically
        VFLInstall("V:|-[btn]-10-|", ["btn":btn])
        // add lack constraint
        VFLFullInstall("V:| [1(X)]-[0] X; H:|-[2(Y$3)];[3(>=100)]-|", [v1,l1,btn,tf])
        
        let v2 = UIView()
        showBorder(v2)
        sv.addSubview(v2)
        let green = UIView(); green.backgroundColor = RGB(0xff00)
        let blue = UIView(); blue.backgroundColor = RGB(0xff)
        v2.addSubview(green); v2.addSubview(blue)
        VFLFullInstall("[green][blue]", ["green":green, "blue":blue])

        // EqualWidth And Priority
        VFLInstall("[green(==blue@20)]", ["green":green, "blue":blue])
        // Multiplier Predicates And With different Priority
        VFLFullInstall("[green(>=70,<=100@999,>=120@30)]", ["green":green])
        // add lack constraint
        VFLFullInstall("V:[0]-[1] X; |[2(30,==$3,T$3)]|; H:|[2]; [3]|", [v1,v2,green,blue])

        // a complete Line
        let l2 = UILabel(); l2.text = "Complete Line"
        let v3 = UIView()
        showBorder(v3)
        sv.addSubview(l2)
        sv.addSubview(v3)

        let b1 = UIButton(type: UIButtonType.System)
        b1.setTitle("Find", forState: UIControlState.Normal)
        let b2 = UIButton(type: UIButtonType.System)
        b2.setTitle("Find Next", forState: UIControlState.Normal)
        let t1 = UITextField(); t1.borderStyle = UITextBorderStyle.Bezel
        v3.addSubview(b1)
        v3.addSubview(b2)
        v3.addSubview(t1)
        // full line
        VFLFullInstall("|-[b1]-[b2]-[t1(>=50)]-| b", ["b1":b1, "b2":b2, "t1":t1])
        // lack constraints
        VFLFullInstall("V:[0]-[1]-[2] X; H:|-[3]; [5]-|; V:|-[3]-|", [v2,l2,v3,b1,b2,t1])
    }

    func Basic() {
        let v1 = UIView()
        v1.backgroundColor = UIColor.redColor()

        let v2 = UIView()
        v2.backgroundColor = UIColor.greenColor()

        let v3 = UIView()
        v3.backgroundColor = UIColor.blueColor()

        var env:[String : AnyObject] = ["v1":v1, "v2":v2, "v3":v3]
        for (_, v) in env {
            view.addSubview(v as! UIView)
        }
        env["top"] = topLayoutGuide

        let big = VFLFullInstall("|-[v1]-[v2]-| WHY; |-[v3]-|;" +
            "V:[top]-[v1]-[v3(v1*0.5)]-|", env)
        let small = VFLConstraints("[v1(0,X=R*0.25)];[v2(0,X=R*0.75)];[v3(0,X)];" +
            "V:[v1(0,Y=B*0.25)]; [v2(0,Y=B*0.25)];[v3(0,Y=B*0.75)]", env)

        let animation = { [unowned self] () in
            big.deactivateConstraints()
            (small as NSArray).activateConstraints()
            UIView.animateWithDuration(1, delay:0,
                options:[.Repeat, .Autoreverse],
                animations: { () -> Void in
                    self.view.layoutIfNeeded()
                }, completion: nil)
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), animation)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

