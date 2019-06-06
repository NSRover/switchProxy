//
//  AppDelegate.swift
//  SwitchProxy
//
//  Created by Nirbhay Agarwal on 04/06/2019.
//  Copyright © 2019 Nirbhay Agarwal. All rights reserved.
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        initialseButton()
        startTimer()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        guard let status = check() else {
            turn(on: false)
            return false
        }
        
        turn(on: !status)
        return false
    }
}

// MARK: - Menubar icon
extension AppDelegate {
    
    func initialseButton() {
        guard let button = statusItem.button else { return }
        button.action = #selector(showMenu(_:))
        showUnknownState()
    }
    
    @objc func showMenu(_ sender: Any?) {
        let answer = dialogOKCancel(question: "Quit?", text: "Clicking the icon kills the app. \n\nTo use the app, simply (re)launch \"SwitchProxy\" from spotlight.")
        if answer {
            terminateApp()
        }
    }
    
    private func terminateApp() {
        NSApplication.shared.terminate(self)
    }
    
    func dialogOKCancel(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Quit")
        alert.addButton(withTitle: "🖖🏽")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    func showUnknownState() {
        let img = NSImage(named: "problem.png")
        img?.isTemplate = true
        statusItem.button?.image = img
        statusItem.button?.tag = 2 //unknown
    }
    
    func updateButton(isOn: Bool) {
        guard let button = statusItem.button else {
            showUnknownState()
            return
        }
        
        var image:NSImage?
        var needsUpdate = false
        
        if isOn && button.tag != 1 {
            image = NSImage(named: "enable.png")
            button.tag = 1
            needsUpdate = true
        } else if !isOn && button.tag != 0 {
            image = NSImage(named: "disable.png")
            button.tag = 0
            needsUpdate = true
        }
        
        guard needsUpdate,
        let img = image else {
            return
        }
        img.isTemplate = true
        button.image = img
    }
}

// MARK: - Timer
extension AppDelegate {
    
    private func startTimer() {
        var _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(AppDelegate.checkProxy), userInfo: nil, repeats: true)
    }
    
    @objc private func checkProxy() {
        guard let status = check() else {
            turn(on: false)
            return
        }
        
        updateButton(isOn: status)
    }
    
    private func check() -> Bool? {
        let prefix = "Auto Proxy Discovery: "
        let bash: CommandExecuting = Bash()
        guard let lsOutput = bash.execute(commandName: "networksetup", arguments: ["-getproxyautodiscovery", "Wi-Fi"]),
            lsOutput.hasPrefix(prefix) else {
                return nil
        }
        
        let statusString = String(lsOutput.dropFirst(prefix.count)).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
        switch statusString {
        case "on":
            return true
        case "off":
            return false
        default:
            return nil
        }
    }
    
    private func turn(on: Bool) {
        showUnknownState()
        let bash: CommandExecuting = Bash()
        guard let _ = bash.execute(commandName: "networksetup", arguments: ["-setproxyautodiscovery", "Wi-Fi", on ? "on" : "off"]) else {
            return
        }
    }
}

