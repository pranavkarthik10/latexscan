//
//  latexscanApp.swift
//  latexscan
//
//  Created by Pranav Karthik on 2026-01-14.
//

import SwiftUI
import AppKit
import Carbon.HIToolbox

@main
struct latexscanApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "function", accessibilityDescription: "LaTeX Scanner")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // Create the popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 400)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: ContentView())
        
        // Register global hotkey (Cmd+Shift+L)
        registerHotKey()
        
        // Hide from dock
        NSApp.setActivationPolicy(.accessory)
        
        // Request accessibility permissions if needed
        requestAccessibilityPermissions()
    }
    
    func requestAccessibilityPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options)
    }
    
    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    func registerHotKey() {
        // Register Cmd+Shift+L as global hotkey
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x4C545853) // "LTXS"
        hotKeyID.id = 1
        
        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = UInt32(kEventHotKeyPressed)
        
        // Install event handler
        let handlerBlock: EventHandlerUPP = { (nextHandler, theEvent, userData) -> OSStatus in
            var hotKeyID = EventHotKeyID()
            GetEventParameter(theEvent, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
            
            if hotKeyID.id == 1 {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .startScreenCapture, object: nil)
                }
            }
            return noErr
        }
        
        InstallEventHandler(GetApplicationEventTarget(), handlerBlock, 1, &eventType, nil, &eventHandler)
        
        // Cmd+Shift+L: keycode 37 = L, cmdKey = 256, shiftKey = 512
        let modifiers: UInt32 = UInt32(cmdKey | shiftKey)
        RegisterEventHotKey(UInt32(kVK_ANSI_L), modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
    }
}

extension Notification.Name {
    static let startScreenCapture = Notification.Name("startScreenCapture")
}
