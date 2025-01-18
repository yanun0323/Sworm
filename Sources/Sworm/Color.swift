import SwiftUI

#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#elseif os(macOS)
import AppKit
#endif
import SwiftUI

// MARK: Color Component
extension Color {
#if os(macOS)
    typealias SystemColor = NSColor
#else
    typealias SystemColor = UIColor
#endif
    
    public var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
#if os(macOS)
        guard let color = self.usingColorSpace() else {
            return nil
        }
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        // Note that non RGB color will raise an exception, that I don't now how to catch because it is an Objc exception.
#else
        guard SystemColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else {
            // Pay attention that the color should be convertible into RGB format
            // Colors using hue, saturation and brightness won't work
            return nil
        }
#endif
        
        return (r, g, b, a)
    }
    
#if os(macOS)
    func usingColorSpace() -> SystemColor? {
        if let color = SystemColor(self).usingColorSpace(.deviceRGB) {
            return color
        }
        
        if let color = SystemColor(self).usingColorSpace(.displayP3) {
            return color
        }
        
        if let color = SystemColor(self).usingColorSpace(.sRGB) {
            return color
        }
        return nil
    }
#endif
}

// MARK: Codable
extension Color: Codable {
    public enum CodingKeys: String, CodingKey {
        case red, green, blue, alpha
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let r = try container.decode(Double.self, forKey: .red)
        let g = try container.decode(Double.self, forKey: .green)
        let b = try container.decode(Double.self, forKey: .blue)
        let a = try container.decode(Double.self, forKey: .alpha)
        
        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
    public func encode(to encoder: Encoder) throws {
        guard let colorComponents = self.components else {
            throw DecodingError.valueNotFound(Color.self, .init(codingPath: [], debugDescription: "No Color Component"))
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(colorComponents.red, forKey: .red)
        try container.encode(colorComponents.green, forKey: .green)
        try container.encode(colorComponents.blue, forKey: .blue)
        try container.encode(colorComponents.alpha, forKey: .alpha)
    }
}
