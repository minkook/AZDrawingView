//
//  AZDrawingView.swift
//  AZDrawingView
//
//  Created by minkook yoo on 2022/01/06.
//

import Foundation

//@IBDesignable
open class AZDrawingView: UIView {

    // 1.0
    @IBInspectable public var strokeWidth: CGFloat {
        get {
            return _strokeWidth
        }
        set {
            _strokeWidth = newValue
        }
    }

    //
    @IBInspectable public var strokeColor: UIColor = UIColor.red

    //
    @IBInspectable public var lineCap: CGLineCap = CGLineCap.round

    //
    public var maxHistoryCount: UInt = 10
    
    //
    public func clear() { executeClear() }
    
    //
    public func undo() { executeUndo() }

    //
    public func redo() { executeRedo() }

    //----------------------------------------------------------------------
    //----------------------------------------------------------------------
    //----------------------------------------------------------------------

    private var _strokeWidth: CGFloat = 1.0

    //
    private var imageView = UIImageView.init()

    //
    private var clearImage: UIImage = UIImage()
    
    //
    private var commandHistory: Array<UIImage> = []
    private var currentCommandIndex: Int = 0
    
    private var previousPoint1: CGPoint = CGPoint.zero
    private var previousPoint2: CGPoint = CGPoint.zero
    private var currentPoint: CGPoint = CGPoint.zero

    private var isFirstDrawing: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        
        self .addSubview(imageView)
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.cornerRadius = 5
    }
    
}


// override
extension AZDrawingView {

    override open func layoutSubviews() {
        if imageView.frame == CGRect.zero {
            imageView.frame = self.bounds
        }
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard let touch = touches.first else { return }

        previousPoint1 = touch.previousLocation(in: self)
        previousPoint2 = touch.previousLocation(in: self)
        currentPoint = touch.location(in: self)

        if !isFirstDrawing {
            isFirstDrawing = true

            UIGraphicsBeginImageContext(imageView.frame.size)
            let currentImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            if let image = currentImage {
                clearImage = image
                executeCommandHistoryWithImage(clearImage)
            }
        }
    }

    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard let touch = touches.first else { return }

        previousPoint2 = previousPoint1
        previousPoint1 = touch.previousLocation(in: self)
        currentPoint = touch.location(in: self)

        let mid1 = midPoint(previousPoint1, previousPoint2)
        let mid2 = midPoint(currentPoint, previousPoint1)

        UIGraphicsBeginImageContext(imageView.frame.size)
        let currentContext = UIGraphicsGetCurrentContext()
        imageView.image?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height))

        guard let context = currentContext else { return }

        context.move(to: mid1)

        context.addQuadCurve(to: mid2, control: previousPoint1)

        context.setLineCap(self.lineCap)
        context.setLineWidth(self.strokeWidth)
        context.setStrokeColor(self.strokeColor.cgColor)

        context.strokePath()

        imageView.image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        if let image = imageView.image {
            executeCommandHistoryWithImage(image)
        }

    }

    func midPoint(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) * 0.5, y: (p1.y + p2.y) * 0.5)
    }

}


private extension AZDrawingView {

    func executeCommandHistoryWithImage(_ image: UIImage) {

        var history = commandHistory

        if history.count > 0 {
            if 0 <= currentCommandIndex && currentCommandIndex < commandHistory.count - 1 {
                history = Array(history[0..<currentCommandIndex + 1])
            }
        }
        
        let mutableHistory = NSMutableArray.init(array: history)
        mutableHistory.add(image)

        if mutableHistory.count > self.maxHistoryCount + 1 {
            mutableHistory.removeObject(at: 0)
        }

        commandHistory = Array(_immutableCocoaArray: mutableHistory) // NSArray.init(array: mutableHistory)
        currentCommandIndex = commandHistory.count - 1

    }
    
    func executeClear() {
        
        if currentCommandIndex == 0 { return }
        
        commandHistory = []
        currentCommandIndex = 0
        imageView.image = clearImage
        executeCommandHistoryWithImage(clearImage)
        
    }
    
    func executeUndo() {
        
        if currentCommandIndex <= 0 { return }
        
        currentCommandIndex -= 1
        imageView.image = commandHistory[currentCommandIndex]
        
    }
    
    func executeRedo() {
        
        if currentCommandIndex >= commandHistory.count - 1 { return }
        
        currentCommandIndex += 1
        imageView.image = commandHistory[currentCommandIndex]
        
    }

}
