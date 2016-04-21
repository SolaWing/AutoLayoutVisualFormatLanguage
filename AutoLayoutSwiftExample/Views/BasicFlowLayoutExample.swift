//  Gihhub: https://github.com/SolaWing/AutoLayoutVisualFormatLanguage
//
//  BasicFlowLayoutExample.swift
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/12/13.
//  Copyright © 2015年 SW. All rights reserved.
//

import UIKit
import VFL

class BasicFlowLayoutExample: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }

    func initialize() {
        let leftView = UIView(color: RGB(0x00FF00))
        let centerView = UIView(color: RGB(0xFF0000))
        let rightView = UIView(color: RGB(0x00FF00))
        self.addSubview(leftView)
        self.addSubview(centerView)
        self.addSubview(rightView)

        let minusButton = UIButton(type: .Custom)
        minusButton.setTitle("-", forState:.Normal)
        minusButton.setTitleColor(RGB(0x0000FF), forState:.Normal)
        minusButton.backgroundColor = UIColor.whiteColor()
        minusButton.addTarget(self, action:"clickMinusButton", forControlEvents:.TouchUpInside)
        leftView.addSubview(minusButton)

        let plusButton = UIButton(type: .Custom)
        plusButton.setTitle("+", forState:.Normal)
        plusButton.setTitleColor(RGB(0x0000FF), forState:.Normal)
        plusButton.backgroundColor = UIColor.whiteColor()
        plusButton.addTarget(self, action:"clickPlusButton", forControlEvents:.TouchUpInside)
        rightView.addSubview(plusButton)

        // create flow layout from left to right.
        // specify all views in predicate statement are equal width, equal height, equal centerY at end (WHY)
        //
        // use ; to seperate statement
        // save space in global weak table to ref later
        // support string interpolation (when use [], auto join with separator ";")
        VFL.fullInstall([
            "|-(space0:0)-[\(leftView)]-(space1:0)-[\(centerView)]-(space2:0)-[\(rightView)]-(space3:0)-| WHY",
            "V:|-[\(centerView)]-|;"])

        // pos button at superview center
        minusButton.VFLFullInstall("X,Y")
        plusButton.VFLFullInstall("X,Y")
    }

    func clickMinusButton() {
        // add space to minus width
        if var space = VFLConstraintForKey("space0")?.constant {
            if space > 60 { return }
            space += 10;
            for var i = 0; i < 4; ++i {
                VFLConstraintForKey(String(format:"space%d", i) )!.constant = space;
            }

            UIView.animateWithDuration(0.25, animations:{
                self.layoutIfNeeded()
            })
        }
    }

    func clickPlusButton() {
        // minus space to add width
        if var space = VFLConstraintForKey("space0")?.constant {
            if space == 0 { return }
            space -= 10;
            for var i = 0; i < 4; ++i {
                VFLConstraintForKey(String(format:"space%d", i) )!.constant = space;
            }

            UIView.animateWithDuration(0.25, animations:{
                self.layoutIfNeeded()
            })
        }
    }

}
