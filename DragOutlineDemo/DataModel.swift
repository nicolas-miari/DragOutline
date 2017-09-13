//
//  DataModel.swift
//  DragOutlineDemo
//
//  Created by Nicolás Miari on 2017/09/13.
//  Copyright © 2017 Nicolás Miari. All rights reserved.
//

import Foundation

/// A file has a name and a parent in the hierarchy.
///
class File {
    var name: String
    var parent: File?

    init(name: String) {
        self.name = name
    }
}

/// A directory is just a file that can take children (this conceptualization is 
/// consistent with the NSFileManager API: `-fileExistsAtPath:isDirectory:`).
///
class Directory: File {
    var children = [File]()
}
