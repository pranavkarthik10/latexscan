//
//  ContentView.swift
//  latexscan
//
//  Created by Pranav Karthik on 2026-01-14.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LatexScanViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "function")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                Text("Latex Scan")
                    .font(.headline)
                Spacer()
                Button(action: { NSApp.terminate(nil) }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 8)
            
            Divider()
            
            // Status
            HStack {
                Circle()
                    .fill(viewModel.apiKeySet ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                Text(viewModel.apiKeySet ? "API Key Configured" : "API Key Missing")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                Label("Press **Cmd+Shift+L** to capture", systemImage: "keyboard")
                    .font(.subheadline)
                Label("Select area with math/equations", systemImage: "viewfinder")
                    .font(.subheadline)
                Label("LaTeX copied to clipboard", systemImage: "doc.on.clipboard")
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
            
            // Scan Button
            Button(action: {
                viewModel.startCapture()
            }) {
                HStack {
                    Image(systemName: "camera.viewfinder")
                    Text("Scan Now")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.apiKeySet)
            
            // Result area
            if viewModel.isProcessing {
                ProgressView("Converting to LaTeX...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if let latex = viewModel.lastResult {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Result:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button(action: {
                            viewModel.copyToClipboard()
                        }) {
                            Label("Copy", systemImage: "doc.on.doc")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        Text(latex)
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                    }
                    .frame(minHeight: 80, maxHeight: 180)
                    .background(Color.secondary.opacity(0.08))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                }
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
            
            // Settings link
            HStack {
                Spacer()
                SettingsLink {
                    Label("Settings", systemImage: "gear")
                        .font(.caption)
                }
            }
        }
        .padding()
        .frame(width: 320, height: 480)
    }
}

#Preview {
    ContentView()
}
