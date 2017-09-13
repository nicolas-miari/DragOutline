//
//  OutlineView.swift
//  DragOutlineDemo
//
//  Created by Nicolás Miari on 2017/09/13.
//  Copyright © 2017 Nicolás Miari. All rights reserved.
//

import Cocoa

class OutlineView: NSOutlineView, SourceEndpointOwner {

    var sourceEndpoint: DragEndpoint?

    private var lineOverlay: LineOverlay?

    // MARK: - Drag-Connect

    func trackDrag(forMouseDownEvent mouseDownEvent: NSEvent, in sourceEndpoint: DragEndpoint) {
        self.sourceEndpoint = sourceEndpoint
        let pasterboardItem = NSPasteboardItem(pasteboardPropertyList: "AAA", ofType: kUTTypeData as String)!
        let item = NSDraggingItem(pasteboardWriter: pasterboardItem)
        let session = sourceEndpoint.beginDraggingSession(with: [item], event: mouseDownEvent, source: self)
        session.animatesToStartingPositionsOnCancelOrFail = false
    }

    override func mouseDown(with event: NSEvent) {
        if let source = self.window?.contentView?.hitTest(event.locationInWindow) as? DragEndpoint {
            trackDrag(forMouseDownEvent: event, in: source)
        } else {
            self.sourceEndpoint = nil
            super.mouseDown(with: event)
        }
    }

    override func validateProposedFirstResponder(_ responder: NSResponder, for event: NSEvent?) -> Bool {
        if responder is DragEndpoint {
            return true
        }
        return super.validateProposedFirstResponder(responder, for: event)
    }

    override func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
        if  let endpoint = sourceEndpoint {

            // Center line start at the geometric cente rof the DragEndPoint:
            let center = CGPoint(x: endpoint.bounds.width/2, y: endpoint.bounds.height/2)
            let windowCenter = endpoint.convert(center, to: nil)
            let windowRect = CGRect(origin: windowCenter, size: CGSize.zero)
            guard let screenRect = window?.convertToScreen(windowRect) else {
                fatalError("!!!")
            }
            sourceEndpoint?.state = .source
            lineOverlay = LineOverlay(startScreenPoint: screenRect.origin, endScreenPoint: screenPoint)
        }
        super.draggingSession(session, willBeginAt: screenPoint)
    }

    override func draggingSession(_ session: NSDraggingSession, movedTo screenPoint: NSPoint) {
        lineOverlay?.endScreenPoint = screenPoint
    }

    override func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        lineOverlay?.removeFromScreen()
        sourceEndpoint?.state = .idle

        // TEST
        super.draggingSession(session, endedAt: screenPoint, operation: operation)
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if let endpoint = sourceEndpoint {
            return endpoint.draggingEntered(sender)
        } else {
            return super.draggingEntered(sender)
        }
    }
}

