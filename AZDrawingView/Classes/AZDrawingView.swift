//
//  AZDrawingView.swift
//  AZDrawingView
//
//  Created by minkook yoo on 2022/01/06.
//

import Foundation

class AZDrawingView: UIView {
    
    // 1.0
    public var strokeWidth: CGFloat {
        get {
            return _strokeWidth
        }
        set {
            _strokeWidth = newValue
        }
    }
    
    //
    public var strokeColor: UIColor = UIColor.red
    
    //
    public var lineCap: CGLineCap = CGLineCap.round
    
    //
    public var maxHistoryCount: UInt = 10
    
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
    
    public func undo() {
        
    }
    
    public func redo() {
        
    }
    
    public func clear() {
        
    }
    
    //----------------------------------------------------------------------
    //----------------------------------------------------------------------
    //----------------------------------------------------------------------
    
    private var _strokeWidth: CGFloat = 1.0
    
    //
    private var imageView = UIImageView.init()
    
    //
    private var clearImage: UIImage?
    
    //
    private var commandHistory: NSArray = []
    private var currentCommandIndex: Int = 0
    
    
    
    private var previousPoint1: CGPoint = CGPoint.zero
    private var previousPoint2: CGPoint = CGPoint.zero
    private var currentPoint: CGPoint = CGPoint.zero
    
    private var isFirstDrawing: Bool = false
    
}


// override
extension AZDrawingView {
    
    override func layoutSubviews() {
        if imageView.frame == CGRect.zero {
            imageView.frame = self.bounds
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        
        previousPoint1 = touch.previousLocation(in: self)
        previousPoint2 = touch.previousLocation(in: self)
        currentPoint = touch.location(in: self)
        
        if !isFirstDrawing {
            isFirstDrawing = true

            UIGraphicsBeginImageContext(imageView.frame.size)
            clearImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let image = clearImage {
                executeCommandHistoryWithImage(image)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        
        previousPoint2 = previousPoint1
        previousPoint1 = touch.previousLocation(in: self)
        currentPoint = touch.location(in: self)
        
        let mid1 = midPoint(previousPoint1, previousPoint2)
        let mid2 = midPoint(currentPoint, previousPoint1)
        
        UIGraphicsBeginImageContext(imageView.frame.size)
        let currentContext = UIGraphicsGetCurrentContext()
        imageView.image?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height))
        
        guard let context = currentContext else {
            return
        }
        
        context.move(to: mid1)
        
        context.addQuadCurve(to: previousPoint1, control: mid2)
        
        context.setLineCap(self.lineCap)
        context.setLineWidth(self.strokeWidth)
        context.setStrokeColor(self.strokeColor.cgColor)
        
        context.strokePath()
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let image = imageView.image {
            executeCommandHistoryWithImage(image)
        }
        
    }
    
    func midPoint (_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) * 0.5, y: (p1.y + p2.y) * 0.5)
    }
    
}


extension AZDrawingView {

    func executeCommandHistoryWithImage (_ image: UIImage) {

        let history = commandHistory

        if history.count > 0 {
            //
        }
        
        let mutableHistory = NSMutableArray.init(array: history)
        mutableHistory.add(image)
        
        if mutableHistory.count > self.maxHistoryCount + 1 {
            mutableHistory.removeObject(at: 0)
        }
        
        commandHistory = NSArray.init(array: mutableHistory)
        currentCommandIndex = commandHistory.count - 1

    }

}
