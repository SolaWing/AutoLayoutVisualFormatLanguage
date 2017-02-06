//  Gihhub: https://github.com/SolaWing/AutoLayoutVisualFormatLanguage
//
//  SystemVisualLayoutExample.swift
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/12/12.
//  Copyright © 2015年 SW. All rights reserved.
//

import UIKit
import VFL

class SystemVisualLayoutExample: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }

    func initialize() {
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(scrollView)

        let containerView = UIView()
        scrollView.addSubview(containerView)
        // if content View not fill Height, center it.
        containerView.VFLFullInstall("L,R, W=|,Y@500, T>=0, B")

        let titleLabel = UILabel(title: "System Visual Layout\nPlease see code", color: RGB(0))
        containerView.addSubview(titleLabel)

        /** First View */
        let v1 = self.firstExampleView()
        v1.showBorder()
        containerView.addSubview(v1)
        // add lack constraint:
        [titleLabel, v1].VFLFullInstall("V:|-[0(X)]-[1] X")

        /** Second View */
        let v2 = self.secondExampleView()
        v2.showBorder()
        containerView.addSubview(v2)
        // add lack constraint
        [v1,v2].VFLFullInstall("V:[0]-[1] X;")

        /** third complete Line View */
        let completeLineLabel = UILabel(title: "Complete Line", color: RGB(0))
        let v3 = self.completeLineView()
        v3.showBorder()
        containerView.addSubview(completeLineLabel)
        containerView.addSubview(v3)

        // add lack constraints for containters
        [v2, completeLineLabel, v3].VFLFullInstall("V:[0]-20-[1]-[2]-| X;")
    }

    func firstExampleView() -> UIView {
        let view = UIView()
        let button = UIButton(type: UIButtonType.custom)
        button.layer.borderWidth = 1;
        button.layer.cornerRadius = 5;
        button.backgroundColor = UIColor.blue

        let textField = UITextField()
        textField.borderStyle = UITextBorderStyle.bezel
        view.addSubview(button)
        view.addSubview(textField)

        let env = ["button":button, "textField":textField]
        /// Standard Space
        env.VFLFullInstall("[button]-[textField]")
        /// Width Constraint
        env.VFLInstall("[button(>=100)]")
        /// Connection to SuperView, vertically
        env.VFLInstall("V:|-10-[button]-10-|")

        // add lack constraint
        env.VFLInstall("|-[button]; [textField (>=100, Y=$button)]-|")

        return view
    }

    func secondExampleView() -> UIView {
        let view = UIView()
        let greenView = UIView(color: RGB(0x00FF00))
        let blueView = UIView(color: RGB(0x0000FF))
        view.addSubview(greenView)
        view.addSubview(blueView)

        let env = ["green":greenView, "blue":blueView]
        /// FlushView
        env.VFLFullInstall("[green][blue]")
        /// EqualWidth And Priority set to 20
        env.VFLInstall("[green(==blue@20)]")
        /// Multiplier Predicates And With different Priority
        env.VFLInstall("[green(>=70, <=100@999, >=120@30)]")

        // add lack constraint
        env.VFLInstall("H:|[green]; [blue]|; V:|[green(30, ==blue, Top=blue)]|;")

        return view
    }

    func completeLineView() -> UIView {
        let view = UIView()
        let find = UIButton(type: .system)
        find.setTitle("Find", for: UIControlState());
        let findNext = UIButton(type: .system)
        findNext.setTitle("Find Next", for: UIControlState())
        let textField = UITextField()
        textField.borderStyle = .bezel
        view.addSubview(find)
        view.addSubview(findNext)
        view.addSubview(textField)

        /// a complete Line
        let d : [String : Any] = ["find":find, "findNext":findNext, "textField":textField, "minWidth": 50]
        d.VFLFullInstall("|-[find]-[findNext]-[textField(>=minWidth)]-| b; V:|-[find]-|")

        return view
    }

}
