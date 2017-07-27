//
//  ViewController.swift
//  slider
//
//  Created by Giuseppe Capoluongo on 19/07/17.
//  Copyright © 2017 Giuseppe Capoluongo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CCVideoRangeSliderDelegate {
    
    // MARK: - Colors
    let lightBlue = UIColor(red: 0, green: 119/255, blue: 1, alpha: 0.5)
    let charcoalGray = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)
    
    var startTime = 0.0
    var endTime = 10.0
    
    var delegate: CCVideoRangeSliderDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        //customGraphics()
        initSlider()
    }
    
    @IBOutlet weak var videoRangeSlider: CCVideoRangeSlider!
    
    func initSlider(){
        videoRangeSlider.delegate = self
        videoRangeSlider.initSlider(startTime: 0.0, endTime: 9.0)
    }
    
    func didChangeValue(startTime: Float, endTime: Float) {
        print(startTime, endTime)
    }
    
    @IBOutlet weak var containerView: UIView!
    
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
        
        let viewWidth = Int(containerView.frame.width)
        
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
        
        // Create time labels
        let timeLabelLeft = UIView(frame: CGRect(x: 0, y: -5, width: 100, height: 50))
        timeLabelLeft.backgroundColor = .black
        
//        timeLabelLeft.text = "0.00"
        
        resizeSelectedZone()
        
        containerView.addSubview(rangeBackground)
        
        rangeBackground.addSubview(timeLabelLeft)
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
        let widthOnTotal = (Double(rangeSelected!.frame.width) * 100)/Double(rangeSelectionOriginalWidth!)
        
        let currentStartOriginX = pickerLeft!.frame.origin.x + pickerLeft!.frame.width
        let currentStartOnTotal = (Double(currentStartOriginX) * endTime)/Double(rangeSelectionOriginalWidth!) - 1
        
        let currentEndOriginX = pickerRight?.frame.origin.x
        let currentEndOnTotal = (Double(currentEndOriginX!) * endTime)/Double(rangeSelectionOriginalWidth!) - 1
        
        // Test purpose
        updateLabels(percentage: widthOnTotal, startTime: currentStartOnTotal, endTime: currentEndOnTotal)
        
        let roundedValue = getRoundedValues(startTime: currentStartOnTotal, endTime: currentEndOnTotal)
        
        return roundedValue
    }
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    
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
    
    func updateLabels(percentage: Double, startTime: Double, endTime: Double){
        var cStartTime = startTime
        var cEndTime = endTime
        
        
        if cStartTime < self.startTime || cStartTime - 0.2 <= self.startTime {
            cStartTime = self.startTime
        }
        if cEndTime > self.endTime || cEndTime + 0.2 >= self.endTime{
            cEndTime = self.endTime
        }
        
        percentageLabel.text = "\(Int(percentage))%"
        startTimeLabel.text = "\(cStartTime.roundTo(places: 2))"
        endTimeLabel.text = "\(cEndTime.roundTo(places: 2))"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        saveLastLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

