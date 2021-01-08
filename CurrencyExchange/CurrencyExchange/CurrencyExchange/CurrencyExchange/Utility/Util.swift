//
//  Util.swift
//  CurrencyExchange
//
//  Created by sanzrush on 8/1/21.
//

import Foundation
import UIKit

extension UITextField {
    func addDashedBorder(){
        backgroundColor = .clear
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "DashedTopLine"
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: frame.width / 2, y: frame.height*1.5)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.lineDashPattern = [6, 4]
        
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: frame.width, y: 0))
        shapeLayer.path = path
        
        layer.addSublayer(shapeLayer)
    }
    func checkEmpty() -> Bool{
        if self.text == ""{
            return true
        }
        return false
    }
}

func showAlert(title: String, message: String, viewController: UIViewController){
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

    viewController.present(alert, animated: true)
}
