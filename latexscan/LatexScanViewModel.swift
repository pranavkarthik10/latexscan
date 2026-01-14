//
//  LatexScanViewModel.swift
//  latexscan
//
//  Created by Pranav Karthik on 2026-01-14.
//

import SwiftUI
import AppKit
import Combine
import UserNotifications

@MainActor
class LatexScanViewModel: ObservableObject {
    @Published var isProcessing = false
    @Published var lastResult: String?
    @Published var errorMessage: String?
    @Published var apiKeySet: Bool = false
    
    private let geminiService = GeminiService()
    private var captureObserver: NSObjectProtocol?
    private var defaultsObserver: NSObjectProtocol?
    
    init() {
        checkApiKey()
        setupNotificationObserver()
        setupDefaultsObserver()
        requestNotificationPermission()
    }
    
    deinit {
        if let observer = captureObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = defaultsObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func setupDefaultsObserver() {
        defaultsObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.checkApiKey()
            }
        }
    }
    
    func checkApiKey() {
        apiKeySet = !geminiService.apiKey.isEmpty
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
    
    private func setupNotificationObserver() {
        captureObserver = NotificationCenter.default.addObserver(
            forName: .startScreenCapture,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.startCapture()
            }
        }
    }
    
    func startCapture() {
        guard apiKeySet else {
            errorMessage = "Please set your Gemini API key in Settings"
            return
        }
        
        errorMessage = nil
        
        // Run capture in background thread to avoid blocking
        Task.detached { [weak self] in
            await self?.captureScreenSelection()
        }
    }
    
    private func captureScreenSelection() async {
        let tempPath = NSTemporaryDirectory() + "latexscan_capture_\(UUID().uuidString).png"
        
        // Remove existing file if any
        try? FileManager.default.removeItem(atPath: tempPath)
        
        // Use macOS screencapture with interactive selection (-i) and no sound (-x)
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        task.arguments = ["-i", "-x", tempPath]
        
        do {
            try task.run()
            task.waitUntilExit()
            
            // Check if capture was successful (user didn't cancel)
            if FileManager.default.fileExists(atPath: tempPath) {
                if let imageData = FileManager.default.contents(atPath: tempPath) {
                    // Clean up temp file
                    try? FileManager.default.removeItem(atPath: tempPath)
                    
                    // Process on main actor
                    await MainActor.run {
                        self.processImage(imageData)
                    }
                } else {
                    await MainActor.run {
                        self.errorMessage = "Failed to read captured image"
                    }
                }
            } else {
                // User cancelled the capture - no error
                await MainActor.run {
                    self.errorMessage = nil
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Screen capture failed: \(error.localizedDescription)"
            }
        }
    }
    
    private func processImage(_ imageData: Data) {
        isProcessing = true
        lastResult = nil
        errorMessage = nil
        
        Task {
            do {
                let latex = try await geminiService.convertImageToLatex(imageData: imageData)
                self.lastResult = latex
                self.copyToClipboard()
                self.showNotification(latex: latex)
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isProcessing = false
        }
    }
    
    func copyToClipboard() {
        guard let latex = lastResult else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(latex, forType: .string)
    }
    
    private func showNotification(latex: String) {
        let content = UNMutableNotificationContent()
        content.title = "LaTeX Copied!"
        content.body = String(latex.prefix(100)) + (latex.count > 100 ? "..." : "")
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
