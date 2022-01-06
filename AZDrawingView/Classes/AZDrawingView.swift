//
//  AZDrawingView.swift
//  AZDrawingView
//
//  Created by minkook yoo on 2022/01/06.
//

import Foundation

open class AZDrawingView: UIView {
    
    
    // default to 1.0
    @IBInspectable public var strokeWidth: CGFloat = 1.0
    
    
    // default to red
    @IBInspectable public var strokeColor: UIColor = UIColor.red
    
    
    // default to lineCapRound
    public var lineCap: CGLineCap = CGLineCap.round
    
    
    // current image
    public var currentDrawingImage: UIImage {
        get {
            if currentCommandIndex == 0 {
                return clearImage
            } else {
                return commandHistory[currentCommandIndex]
            }
        }
    }
    
    
    // undo & redo History Count
    public var maxHistoryCount: UInt {
        get { return _maxHistoryCount }
        set { _maxHistoryCount = min(newValue, 100) }
    }
    
    
    // remove all history
    public var availableClear: Bool { get { return commandHistory.count > 0 } }
    public func clear() { executeClear() }
    
    
    // undo
    public var availableUndo: Bool { get { return currentCommandIndex > 0 } }
    public func undo() { executeUndo() }
    
    
    // redo
    public var availableRedo: Bool { get { return currentCommandIndex < commandHistory.count - 1 } }
    public func redo() { executeRedo() }
    
    
    // debug guide
    public var debugGuideLine: Bool {
        get {
            return _debugGuideLine
        }
        set {
            _debugGuideLine = newValue
            self.layer.borderWidth = _debugGuideLine ? 1.0 : 0.0
            self.layer.borderColor = UIColor.red.cgColor
            self.layer.cornerRadius = 5
        }
    }
    
    
    
    //----------------------------------------------------------------------
    //----------------------------------------------------------------------
    //----------------------------------------------------------------------
    
    private var _maxHistoryCount: UInt = 10

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
    
    private var _debugGuideLine: Bool = false
    
    
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
    }
    
}


// MARK: override
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


// MARK: execute
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
        
        if !availableClear { return }
        
        commandHistory = []
        currentCommandIndex = 0
        imageView.image = clearImage
        executeCommandHistoryWithImage(clearImage)
        
    }
    
    func executeUndo() {
        
        if !availableUndo { return }
        
        currentCommandIndex -= 1
        imageView.image = commandHistory[currentCommandIndex]
        
    }
    
    func executeRedo() {
        
        if !availableRedo { return }
        
        currentCommandIndex += 1
        imageView.image = commandHistory[currentCommandIndex]
        
    }

}
