//
//  FileSystemCellView.swift
//  DragOutlineDemo
//
//  Created by Nicolás Miari on 2017/09/13.
//  Copyright © 2017 Nicolás Miari. All rights reserved.
//

import Cocoa

class FileSystemCellView: NSTableCellView {

    ///
    @IBOutlet weak var iconImageView: NSImageView!

    ///
    @IBOutlet weak var dragEndpoint: DragEndpoint!
}
