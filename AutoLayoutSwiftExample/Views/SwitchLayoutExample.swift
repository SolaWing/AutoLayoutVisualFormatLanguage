//
//  SwitchLayoutExample.swift
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/12/13.
//  Copyright © 2015年 SW. All rights reserved.
//

import UIKit
import VFL

class SwitchLayoutExample: UIView {

    var views : [UIView]!
    var phase : UInt32 = 0
    var localConstraints : [NSLayoutConstraint]!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }

    func initialize() {
        self.backgroundColor = UIColor.grayColor()

        let yellowView = UIView(color: RGB(0xCCCC00))
        let blueView = UIView(color: RGB(0x0000FF))
        let redView = UIView(color: RGB(0xFF0000))
        let whiteView = UIView(color: RGB(0xFFFFFF))
        let blackView = UIView(color: RGB(0))

        self.views = [yellowView, blueView, redView, whiteView, blackView]
        for view in self.views {
            self.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }

        let button = UIButton(type: .Custom)
        button.setTitleColor(UIColor.blueColor(), forState:.Normal)
        button.setTitleColor(UIColor.whiteColor(), forState:.Highlighted)
        button.setTitle("Touch Me", forState:.Normal)
        button.addTarget(self, action:"touchButton", forControlEvents:.TouchUpInside)
        yellowView.addSubview(button)
        button.VFLFullInstall("X,Y") // center button in superview

        self.applyLayout()
    }

    func applyLayout() {
        if let constraints = self.localConstraints {
            constraints.deactivateConstraints()  // remove previous constraints
        }

        // yellowView at center, other views rotate according to _phase
        // rearrange views so 0:Yellow 1:rightView 2:bottomView 3:leftView 4:topView
        var views = Array(arrayLiteral: self.views[0])
        self.phase %= 8
        var i : UInt32
        for i = self.phase/2; i < 4; ++i {
            views.append( self.views[Int(i+1)] )
        }
        for i = 0; i < self.phase/2; ++i {
            views.append( self.views[Int(i+1)] )
        }

        /// hold created constraints for later deactive
        if (  (self.phase & 1) == 0 ) {
            self.localConstraints = views.VFLInstall([
                "|-[$3]-[$0(X,Y)]-[$1]-| WHY",
                "V:|-[$4]-[$0]-[$2]-| WHX"
                ].joinWithSeparator(";"))
        } else {
            self.localConstraints = views.VFLInstall([
                "|-[$3(Y=$2)]-20-[$0(X,Y)]-20-[$1(Y=$4)]-| WH",
                "V:|-[$4(X=$3)]-20-[$0]-20-[$2(X=$1)]-| WH"
                ].joinWithSeparator(";"))
        }
    }

    func touchButton() {
        ++(self.phase)
        self.applyLayout()

        UIView.animateWithDuration(0.25, animations:{
            self.layoutIfNeeded()
        })
    }
}
