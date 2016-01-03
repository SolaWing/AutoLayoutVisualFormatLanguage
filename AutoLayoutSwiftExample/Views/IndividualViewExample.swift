//  Gihhub: https://github.com/SolaWing/AutoLayoutVisualFormatLanguage
//
//  IndividualViewExample.swift
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/12/14.
//  Copyright © 2015年 SW. All rights reserved.
//

import UIKit
import VFL

class IndividualViewExample: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }

    func initialize() {
        var lastView : UIView = self
        var totalWidth : CGFloat = 0, totalHeight : CGFloat  = 0
        let margin = 2
        while totalWidth < 320 && totalHeight < 320 {
            let randomColor = arc4random()%0x1000000
            let view = UIView(color: RGB(randomColor))
            view.showBorder()
            self.addSubview(view)

            let width: CGFloat = CGFloat(arc4random()%20 + 10)
            let height: CGFloat = CGFloat(arc4random()%20 + 10)
            totalWidth += width; totalHeight += height

            // put view in the inner of lastView
            //
            // specify each margin, you can write fullname, or first char for simple. eg: Left => L
            // attr2 default equal to attr1, you may omit it if it's same.
            // view call VFLFullInstall is $0, other param begin from $1
            view.VFLFullInstall(format:["Left>=$1+$4, Right<=$1-$4, Top>=$1+$4, Bottom<=$1-$4",
                "Width=$1.Width-$2@999, Height=$1-$3@999, X@1, Y@1"].joinWithSeparator(","),
                lastView, width, height, margin)

            lastView = view;
        }

        // use x, y key to ref last view origin
        lastView.VFLInstall("x: X@999, y: Y@999")
    }

    func updateCenter(offset p:CGPoint) {
        VFLConstraintForKey("x").constant = p.x
        VFLConstraintForKey("y").constant = p.y
    }

    func updateCenter(var p:CGPoint) {
        p.x -= self.bounds.size.width / 2
        p.y -= self.bounds.size.height / 2
        self.updateCenter(offset: p)
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        self.updateCenter(touches.first!.locationInView(self))
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        self.updateCenter(touches.first!.locationInView(self))
    }
}
