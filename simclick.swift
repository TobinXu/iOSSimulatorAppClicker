import Cocoa

// simclick.swift - Simulate a mouse click at given coordinates
// Usage: swift simclick.swift <x> <y>
//   Coordinates: top-left origin (matching System Events window positions)
//   Swift/CGEvent requires bottom-left origin, so we convert automatically

guard CommandLine.arguments.count == 3,
      let x = Double(CommandLine.arguments[1]),
      let y = Double(CommandLine.arguments[2]) else {
    print("Usage: swift simclick.swift <x> <y>")
    exit(1)
}

// Convert from top-left (System Events) to bottom-left (CGEvent) coordinate system
let screenHeight = NSScreen.main?.frame.height ?? 0
let convertedY = screenHeight - y

let point = CGPoint(x: x, y: convertedY)

// Move mouse to position
let moveEvent = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved,
                        mouseCursorPosition: point, mouseButton: .left)
moveEvent?.post(tap: .cghidEventTap)

// Small delay
usleep(50000)

// Mouse down
let downEvent = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown,
                         mouseCursorPosition: point, mouseButton: .left)
downEvent?.post(tap: .cghidEventTap)

usleep(50000)

// Mouse up
let upEvent = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp,
                       mouseCursorPosition: point, mouseButton: .left)
upEvent?.post(tap: .cghidEventTap)

print("Clicked at (x:\(x), y:\(y)) → converted to (x:\(x), y:\(convertedY)) (bottom-left origin)")
