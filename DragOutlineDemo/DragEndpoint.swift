//
//  DragEndpoint.swift
//  DragOutlineDemo
//
//  Created by Nicolás Miari on 2017/09/13.
//  Based on a similar file created by Rob Mayoff on 2017/04/28.
//

import Cocoa


protocol SourceEndpointOwner {
    var sourceEndpoint: DragEndpoint? { get }
}

@IBDesignable
class DragEndpoint: NSImageView {

    enum State {
        case idle
        case source
        case target
    }

    var state: State = State.idle {
        didSet {
            needsLayout = true
        }
    }

    public override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard case .idle = state else {
            return []
        }
        guard (sender.draggingSource() as? SourceEndpointOwner)?.sourceEndpoint != nil else {
            return []
        }
        state = .target
        return sender.draggingSourceOperationMask()
    }

    public override func draggingExited(_ sender: NSDraggingInfo?) {
        guard case .target = state else { return }
        state = .idle
    }

    public override func draggingEnded(_ sender: NSDraggingInfo?) {
        guard case .target = state else { return }
        state = .idle
    }

    public override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        //guard let controller = sender.draggingSource() as? ConnectionDragController else { return false }
        //controller.connect(to: self)
        return true
    }

    override init(frame: NSRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }

    private func commonInit() {
        wantsLayer = true
        register(forDraggedTypes: [kUTTypeData as String])
    }

    override func makeBackingLayer() -> CALayer {
        return shapeLayer
    }

    override var intrinsicContentSize: CGSize { return CGSize(width: 16, height: 16) }

    override func layout() {
        super.layout()

        setAppearanceForState()

        shapeLayer.path = CGPath(
            ellipseIn: bounds.insetBy(dx: shapeLayer.lineWidth / 2, dy: shapeLayer.lineWidth / 2),
            transform: nil)
    }

    private let shapeLayer = CAShapeLayer()

    private func setAppearanceForState() {
        shapeLayer.lineWidth = 3
        shapeLayer.lineJoin = kCALineJoinRound
        switch state {
        case .idle:
            shapeLayer.strokeColor = NSColor.darkGray.cgColor
            shapeLayer.fillColor = NSColor.clear.cgColor
        case .source:
            shapeLayer.strokeColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1).cgColor
            shapeLayer.fillColor =  NSColor.clear.cgColor
        case .target:
            shapeLayer.strokeColor = NSColor.alternateSelectedControlColor.cgColor
            shapeLayer.fillColor = NSColor.clear.cgColor
        }
    }

}
