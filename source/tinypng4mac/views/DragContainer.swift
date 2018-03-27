//
//  DragContainer.swift
//  tinypng
//
//  Created by kyle on 16/6/30.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

import Cocoa

protocol DragContainerDelegate {
	func draggingEntered();
	func draggingExit();
	func draggingFileAccept(_ files:Array<URL>);
}

class DragContainer: NSView {
	var delegate : DragContainerDelegate?
	
	let acceptTypes = ["png", "jpg", "jpeg"]
	
	let normalColor: CGFloat = 0.95
	let highlightColor: CGFloat = 0.99
	let borderColor: CGFloat = 0.85
	
	override func awakeFromNib() {
		super.awakeFromNib()

		self.register(forDraggedTypes: [NSFilenamesPboardType, NSURLPboardType, NSPasteboardTypeTIFF]);
	}
	
	override func draw(_ dirtyRect: NSRect) {
		
	}
	
	override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
//		self.layer?.backgroundColor = NSColor(white: highlightColor, alpha: 1).CGColor;
        
        //这里不做扩展检查，支持查找整个目录
//        let res = checkExtension(sender)
		if let delegate = self.delegate {
			delegate.draggingEntered();
		}
//        if res {
			return NSDragOperation.generic
//        }
//        return NSDragOperation()
	}
	
	override func draggingExited(_ sender: NSDraggingInfo?) {
//		self.layer?.backgroundColor = NSColor(white: normalColor, alpha: 1).CGColor;
		if let delegate = self.delegate {
			delegate.draggingExit();
		}
	}
	
	override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
//		self.layer?.backgroundColor = NSColor(white: normalColor, alpha: 1).CGColor;
		return true
	}
	
	override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
		var files = Array<URL>()
		if let board = sender.draggingPasteboard().propertyList(forType: NSFilenamesPboardType) as? NSArray {
            
            let manager = FileManager.default
            
			for path in board {
				let url = URL(fileURLWithPath: path as! String)
                
                if self.isFolder(path as! String) {
                    //查找目录下所有的资源文件
//                    let directorys = try? manager.contentsOfDirectory(atPath: path as! String)
                    let enumeratorAtURLValues = manager.enumerator(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles, errorHandler: nil)?.allObjects
//                    debugPrint("enumeratorAtURL: \(String(describing: enumeratorAtURL?.allObjects))");
                    
                    for path1 in enumeratorAtURLValues! {
                        let fileExtension = (path1 as! URL).pathExtension.lowercased()
                        if acceptTypes.contains(fileExtension) {
                            files.append(path1 as! URL)
                        }
                    }
                }
                else
                {
                    let fileExtension = url.pathExtension.lowercased()
                    if acceptTypes.contains(fileExtension) {
                        files.append(url)
                    }
                }
			}
		}
        
        debugPrint(String(describing: files))
		
		if self.delegate != nil {
			self.delegate?.draggingFileAccept(files);
		}
		
		return true
	}
    
    func isFolder(_ path: String) -> Bool {
        
        var isFolder:ObjCBool = false;
        
        let manager = FileManager.default
        return manager.fileExists(atPath: path, isDirectory:&isFolder);
    }
	
	func checkExtension(_ draggingInfo: NSDraggingInfo) -> Bool {
		if let board = draggingInfo.draggingPasteboard().propertyList(forType: NSFilenamesPboardType) as? NSArray {
			for path in board {
				let url = URL(fileURLWithPath: path as! String)
				let fileExtension = url.pathExtension.lowercased()
				if acceptTypes.contains(fileExtension) {
					return true
				}
			}
		}
		return false
	}

}
