//  Gihhub: https://github.com/SolaWing/AutoLayoutVisualFormatLanguage
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
        self.backgroundColor = UIColor.gray

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

        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.blue, for:UIControl.State())
        button.setTitleColor(UIColor.white, for:.highlighted)
        button.setTitle("Touch Me", for:UIControl.State())
        button.addTarget(self, action:#selector(SwitchLayoutExample.touchButton), for:.touchUpInside)
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
        for i in self.phase/2 ..< 4 {
            views.append( self.views[Int(i+1)] )
        }
        for i in 0 ..< self.phase/2 {
            views.append( self.views[Int(i+1)] )
        }

        /// hold created constraints for later deactive
        if (  (self.phase & 1) == 0 ) {
            self.localConstraints = views.VFLInstall([
                "|-[$3]-[$0(X,Y)]-[$1]-| WHY",
                "V:|-[$4]-[$0]-[$2]-| WHX"
                ].joined(separator: ";"))
        } else {
            self.localConstraints = views.VFLInstall([
                "|-[$3(Y=$2)]-20-[$0(X,Y)]-20-[$1(Y=$4)]-| WH",
                "V:|-[$4(X=$3)]-20-[$0]-20-[$2(X=$1)]-| WH"
                ].joined(separator: ";"))
        }
    }

    @objc func touchButton() {
        (self.phase) += 1
        self.applyLayout()

        UIView.animate(withDuration: 0.25, animations:{
            self.layoutIfNeeded()
        })
    }
}
