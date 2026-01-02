import SwiftUI
import AppKit
import UniformTypeIdentifiers

@main
struct CitmanApp: App {
    // 1. Force the app to run as a regular GUI application.
    // This fixes the issue where keyboard input goes to Xcode instead of the app window.
    init() {
        NSApplication.shared.setActivationPolicy(.regular)
        
        // Delay activation slightly to ensure the window system is ready
        DispatchQueue.main.async {
            NSApplication.shared.activate(ignoringOtherApps: true)
            NSApplication.shared.windows.first?.makeKeyAndOrderFront(nil)
        }
    }

    var body: some Scene {
        DocumentGroup(newDocument: CitmanDocument()) { file in
            ContentView(document: file.$document)
        }
        .commands {
            // 2. Add standard macOS menu bar items
            
            // Enables "Sidebar" options in the View menu
            SidebarCommands()
            
            // Enables "Find", "Spelling", "Substitutions" in the Edit menu
            TextEditingCommands()
            
            // Enables Toolbar customization
            ToolbarCommands()
            
            // Adds standard window management (Minimize, Zoom)
            // WindowCommands are included by default in DocumentGroup, but explicit doesn't hurt.
        }
    }
}
