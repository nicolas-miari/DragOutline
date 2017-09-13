//
//  ViewController.swift
//  DragOutlineDemo
//
//  Created by Nicolás Miari on 2017/09/13.
//  Copyright © 2017 Nicolás Miari. All rights reserved.
//

import Cocoa

let reorderPasterboardType = "com.nicolasmiari.DragOutlineDemo"

class ViewController: NSViewController {

    @IBOutlet weak var outlineView: NSOutlineView!

    var root: Directory = Directory(name: "Root")

    var draggedNode: AnyObject?

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        loadDummyFileSystem()
    }

    private func loadDummyFileSystem() {
        let pictures = Directory(name: "Pictures")
        pictures.children = [1, 2, 3, 4, 5].map({ index in
            let picture = File(name: "Picture #\(index)")
            picture.parent = pictures
            return picture
        })
        pictures.parent = root
        root.children.append(pictures)

        let music = Directory(name: "Music")
        music.children = [1, 2, 3, 4].map({ index in
            let song = File(name: "Song #\(index)")
            song.parent = music
            return song
        })
        music.parent = root
        root.children.append(music)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        outlineView.delegate = self
        outlineView.dataSource = self
        outlineView.rowHeight = 24
        outlineView.register(forDraggedTypes: [reorderPasterboardType])
        outlineView.setDraggingSourceOperationMask(NSDragOperation(), forLocal: false)
        outlineView.setDraggingSourceOperationMask(NSDragOperation.every, forLocal: true)
        outlineView.reloadData()

        outlineView.expandItem(root, expandChildren: true)
    }
}

extension ViewController: NSOutlineViewDelegate {

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard tableColumn?.identifier == "OnlyColumn" else {
            return nil
        }
        guard let file = item as? File else {
            return nil
        }
        guard let view = outlineView.make(withIdentifier: "FileSystemCellView", owner: self) as? FileSystemCellView else {
            return nil
        }
        view.textField?.stringValue = file.name

        if file is Directory {
            view.dragEndpoint.isHidden = true
            view.iconImageView.image = NSImage(named: NSImageNameFolder)
        } else {
            view.dragEndpoint.isHidden = false
            view.iconImageView.image = NSImage(named: NSImageNameIconViewTemplate)
        }
        return view
    }
}

extension ViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return 1
        } else if let directory = item as? Directory {
            return directory.children.count
        } else {
            return 0
        }
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return root
        } else if let directory = item as? Directory {
            return directory.children[index]
        } else {
            fatalError("!!!")
        }
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return (item is Directory)
    }

    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        guard let file = item as? File else {
            return nil
        }
        return file.name
    }

    // MARK: Drag & Drop

    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        let pasteboardItem = NSPasteboardItem()
        pasteboardItem.setDataProvider(self, forTypes: [reorderPasterboardType])
        return pasteboardItem
    }

    func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItems draggedItems: [Any]) {
        if draggedItems.count > 0 {
            draggedNode = draggedItems[0] as AnyObject
            session.draggingPasteboard.setData(Data(), forType: reorderPasterboardType)
        }
    }

    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        guard item is Directory, draggedNode is File else {
            return NSDragOperation()
        }
        guard index != NSOutlineViewDropOnItemIndex else {
            return NSDragOperation()
        }
        return NSDragOperation.generic
    }

    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        guard let draggedItem = draggedNode else {
            fatalError("Error: Not dragging an item")
        }

        guard let srcParent = (draggedItem as? File)?.parent as? Directory else {
            return false
        }
        guard let dstParent = item as? Directory else {
            return false
        }

        let srcIndex = outlineView.childIndex(forItem: draggedItem)
        var dstIndex = index

        if dstIndex == NSOutlineViewDropOnItemIndex {
            dstIndex = 0 // This should never happen, prevented in validateDrop

        } else if dstIndex > srcIndex && srcParent === dstParent {
            dstIndex -= 1
        }

        guard srcIndex != dstIndex || srcParent !== dstParent  else {
            // Same parent and same index; skip:
            return false
        }

        // Update view (animated):
        outlineView.moveItem(at: srcIndex, inParent: srcParent, to: dstIndex, inParent: dstParent)

        // Update data model:
        if srcParent === dstParent {
            // Same-parent: swap
            let temp = srcParent.children[srcIndex]
            srcParent.children[srcIndex] = srcParent.children[dstIndex]
            srcParent.children[dstIndex] = temp
        } else {
            let file = srcParent.children.remove(at: srcIndex)
            dstParent.children.insert(file, at: dstIndex)
        }
        return true
    }

    @objc func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        self.draggedNode = nil
    }
}

extension ViewController: NSPasteboardItemDataProvider {
    func pasteboard(_ pasteboard: NSPasteboard?, item: NSPasteboardItem, provideDataForType type: String) {
        item.setString("Outline Pasteboard Item", forType: type)
    }
}
