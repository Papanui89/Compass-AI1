#!/usr/bin/env swift

import Foundation

// Test script to verify JSON loading and decoding
print("Testing JSON loading and decoding...")

// Read the panic.json file
if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: "Compass AI/Resources/Flows/panic.json")) {
    print("✅ Successfully read JSON data")
    
    // Try to parse as dictionary to verify structure
    if let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
        print("✅ Successfully parsed JSON as dictionary")
        
        if let nodes = json["nodes"] as? [[String: Any]] {
            print("✅ Found \(nodes.count) nodes")
            
            // Check multiple nodes for options
            for (index, node) in nodes.enumerated() {
                let nodeId = node["id"] as? String ?? "unknown"
                print("🔍 Node \(index + 1): \(nodeId)")
                
                if let options = node["options"] as? [[String: Any]] {
                    print("✅ Node '\(nodeId)' has \(options.count) options")
                    for (optIndex, option) in options.enumerated() {
                        print("  Option \(optIndex + 1): \(option["text"] ?? "no text") -> \(option["nextNode"] ?? "no next")")
                    }
                    break // Found a node with options, stop here
                } else {
                    print("  No options")
                }
            }
        } else {
            print("❌ No nodes found in JSON")
        }
    } else {
        print("❌ Failed to parse JSON as dictionary")
    }
} else {
    print("❌ Failed to read JSON file")
}

print("Test completed.") 