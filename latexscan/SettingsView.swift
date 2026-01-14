//
//  SettingsView.swift
//  latexscan
//
//  Created by Pranav Karthik on 2026-01-14.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("gemini_api_key") private var apiKey: String = ""
    @AppStorage("launch_at_login") private var launchAtLogin: Bool = false
    @State private var showApiKey: Bool = false
    
    var body: some View {
        TabView {
            // General Tab
            Form {
                Section {
                    LabeledContent("Hotkey") {
                        Text("Cmd + Shift + L")
                            .font(.system(.body, design: .monospaced))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    Toggle("Launch at Login", isOn: $launchAtLogin)
                        .onChange(of: launchAtLogin) { _, newValue in
                            setLaunchAtLogin(enabled: newValue)
                        }
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label("General", systemImage: "gear")
            }
            
            // API Tab
            Form {
                Section {
                    HStack {
                        if showApiKey {
                            TextField("Gemini API Key", text: $apiKey)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            SecureField("Gemini API Key", text: $apiKey)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        Button(action: { showApiKey.toggle() }) {
                            Image(systemName: showApiKey ? "eye.slash" : "eye")
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Text("Get your API key from [Google AI Studio](https://makersuite.google.com/app/apikey)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    HStack {
                        Circle()
                            .fill(apiKey.isEmpty ? Color.red : Color.green)
                            .frame(width: 8, height: 8)
                        Text(apiKey.isEmpty ? "API Key Required" : "API Key Configured")
                            .font(.caption)
                    }
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label("API", systemImage: "key")
            }
            
            // About Tab
            Form {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "function")
                            .font(.system(size: 48))
                            .foregroundColor(.accentColor)
                        
                        Text("LaTeX Scanner")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Version 1.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Divider()
                        
                        Text("Capture any math equation on screen and instantly convert it to LaTeX using Google's Gemini AI.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label("About", systemImage: "info.circle")
            }
        }
        .frame(width: 400, height: 250)
    }
    
    private func setLaunchAtLogin(enabled: Bool) {
        // In a production app, you would use SMAppService or LaunchAtLogin package
        // For now, this is a placeholder
    }
}

#Preview {
    SettingsView()
}
