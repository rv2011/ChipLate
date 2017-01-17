//
//  AppDelegate.swift
//  ChipLate
//
//  Created by David Kopec on 1/15/17.
//  Copyright © 2017 David Kopec. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var chip8View: Chip8View!
    
    var chip8: Chip8?
    var emuTimer: Timer?
    
    let concurrentQueue = DispatchQueue(label: "queuename", attributes: .concurrent)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func openDocument(sender: AnyObject) {
        print("openDocument got called")
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.begin { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                do {
                    let data: Data = try Data(contentsOf: openPanel.url!)
                    data.withUnsafeBytes({ (pointer: UnsafePointer<Byte>) in
                        let buffer = UnsafeBufferPointer(start: pointer, count: data.count)
                        let array = Array<Byte>(buffer)
                        self.chip8 = Chip8(rom: array)
                        self.chip8View.bitmapWidth = (self.chip8?.width)!
                        self.chip8View.bitmapHeight = (self.chip8?.height)!
                        self.emuTimer = Timer.scheduledTimer(timeInterval: 1/60.0, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
                    })
                    
                } catch {
                    print("error")
                }
            }
        }
    }
    
    func timerFired() {
        concurrentQueue.sync {
            chip8?.cycle()
            chip8View.bitmap = (chip8?.pixels)!
            chip8View.needsDisplay = true
        }
    }

}
