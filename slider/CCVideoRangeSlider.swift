//
//  CCVideoRangeSlider.swift
//  slider
//
//  Created by Giuseppe Capoluongo on 20/07/17.
//  Copyright © 2017 Giuseppe Capoluongo. All rights reserved.
//

import UIKit

class CCVideoRangeSlider: UIView {
    
    // MARK: - Colors
    let lightBlue = UIColor(red: 0, green: 119/255, blue: 1, alpha: 0.5)
    let charcoalGray = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)
    
    var startTime = 0.0
    var endTime = 10.0
    
    var delegate: CCVideoRangeSliderDelegate?
    
    func initSlider(startTime: Float, endTime: Float){
        self.startTime = Double(startTime)
        self.endTime = Double(endTime)
        customGraphics()
    }

    var rangeSelected: UIView?
    var pickerLeft: UIView?
    var pickerRight: UIView?
    
    var pickerStartX: Int?
    var pickerEndX: Int?
    
    var pickerLeftLastX: Int?
    var pickerRightLastX: Int?
    
    var minRightDraggableX: Int?
    var minLeftDraggableX: Int?
    
    var maxRightDraggableX: Int?
    var maxLeftDraggableX: Int?
    
    func customGraphics(){
        
        let viewWidth = Int(self.frame.width)
        
        let viewHeight = 65
        let rangeBackground = UIView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight))
        rangeBackground.layer.cornerRadius = 5
        rangeBackground.backgroundColor = .lightGray
        
        let pickerWidth = 30
        
        pickerStartX = 0
        pickerEndX = Int(rangeBackground.frame.width) - pickerWidth
        
        pickerLeft = UIView(frame: CGRect(x: pickerStartX!, y: -5, width: pickerWidth, height: 75))
        pickerRight = UIView(frame: CGRect(x: pickerEndX!, y: -5, width: pickerWidth, height: 75))
        
        pickerLeft?.layer.cornerRadius = 3
        pickerRight?.layer.cornerRadius = 3
        
        pickerRight?.backgroundColor = charcoalGray
        pickerLeft?.backgroundColor = charcoalGray
        
        let panGestureRight = UIPanGestureRecognizer(target: self, action: #selector(detectPanRight(_:)))
        let panGestureLeft = UIPanGestureRecognizer(target: self, action: #selector(detectPanLeft(_:)))
        
        pickerLeft?.addGestureRecognizer(panGestureLeft)
        pickerRight?.addGestureRecognizer(panGestureRight)
        
        minLeftDraggableX = 0 + pickerWidth/2
        minRightDraggableX = viewWidth - pickerWidth/2
        
        maxRightDraggableX = Int(Double(pickerWidth) * 1.5)
        maxLeftDraggableX = viewWidth - Int(Double(pickerWidth) * 1.5)
        
        saveLastLocation()
        
        rangeSelected = UIView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight))
        rangeSelected?.backgroundColor = lightBlue
        
        rangeBackground.addSubview(rangeSelected!)
        
        rangeBackground.addSubview(pickerLeft!)
        rangeBackground.addSubview(pickerRight!)
        
        resizeSelectedZone()
        
        self.addSubview(rangeBackground)
    }
    
    func saveLastLocation(){
        pickerRightLastX = Int((pickerRight?.center.x)!)
        print(pickerRightLastX!)
        pickerLeftLastX = Int((pickerLeft?.center.x)!)
    }
    
    var rangeSelectionOriginalWidth: CGFloat?
    
    func resizeSelectedZone(){
        let leftDistance = (pickerLeft?.frame.origin.x)! + (pickerLeft?.frame.width)!
        let rightDistance = (pickerRight?.frame.origin.x)!
        let width = rightDistance - leftDistance
        let x = leftDistance
        rangeSelected?.frame.size.width = width
        rangeSelected?.frame.origin.x = x
        if (rangeSelectionOriginalWidth == nil){
            rangeSelectionOriginalWidth = rangeSelected!.frame.width
        }
    }
    
    @objc func detectPanRight(_ recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translation(in: recognizer.view?.superview)
        let toMove = pickerRightLastX! + Int(translation.x)
        if toMove < minRightDraggableX! && toMove > maxRightDraggableX! {
            recognizer.view?.center.x = CGFloat(toMove)
        }
        resizeSelectedZone()
        readCurrentValue()
    }
    @objc func detectPanLeft(_ recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translation(in: recognizer.view?.superview)
        let toMove = pickerLeftLastX! + Int(translation.x)
        if toMove > minLeftDraggableX! && toMove < maxLeftDraggableX!{
            recognizer.view?.center.x = CGFloat(toMove)
        }
        resizeSelectedZone()
        readCurrentValue()
    }
    
    // MARK: - Calc
    
    /*
     Do this by calc the percentage:
     If I have a 2 mins video
     I remove the 20% (in seconds) of 120s > 120s - 20%(120) = 96s
     */
    
    func readCurrentValue(){
        let values = calcTime()
        delegate?.didChangeValue(startTime: Float(values.startTime), endTime: Float(values.endTime))
    }
    
    func calcTime() -> (startTime: Double, endTime: Double){
//        let widthOnTotal = (Double(rangeSelected!.frame.width) * 100)/Double(rangeSelectionOriginalWidth!) ** PERCENTAGE TO CUT - TEST PURPOSE
        
        let currentStartOriginX = pickerLeft!.frame.origin.x + pickerLeft!.frame.width
        let currentStartOnTotal = (Double(currentStartOriginX) * endTime)/Double(rangeSelectionOriginalWidth!) - 1
        
        let currentEndOriginX = pickerRight?.frame.origin.x
        let currentEndOnTotal = (Double(currentEndOriginX!) * endTime)/Double(rangeSelectionOriginalWidth!) - 1
        
        let roundedValue = getRoundedValues(startTime: currentStartOnTotal, endTime: currentEndOnTotal)
        
        return roundedValue
    }
    
    func getRoundedValues(startTime: Double, endTime: Double) -> (startTime: Double, endTime: Double){
        var cStartTime = startTime
        var cEndTime = endTime
        
        // Skip 0.2
        
        if cStartTime < self.startTime || cStartTime - 0.2 <= self.startTime {
            cStartTime = self.startTime
        }
        if cEndTime > self.endTime || cEndTime + 0.2 >= self.endTime{
            cEndTime = self.endTime
        }
        
        return (cStartTime, cEndTime)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        saveLastLocation()
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
