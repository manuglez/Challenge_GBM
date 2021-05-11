//
//  UIView+Extension.swift
//  GBM_Challenge
//
//  Created by Manuel Gonzalez on 10/05/21.
//

import UIKit

extension UIView {
    func roundBorders() {
        let radius = frame.size.height / 2.0
        layer.cornerRadius  = radius
        layer.masksToBounds = true
    }
    
    func colorBorder(_ color: UIColor){
        layer.borderWidth = 2
        layer.borderColor = color.cgColor
    }
}
