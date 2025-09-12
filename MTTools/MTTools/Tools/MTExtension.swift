//
//  MTExtension.swift
//  MTTools
//
//  Created by Koi on 2025/9/12.
//

import UIKit
import Foundation

// MARK: - UIColor
extension UIColor {
    
    /// hex值转颜色
    /// - Parameters:
    ///   - rgb: hex值
    ///   - alpha: 透明度
    /// - Returns: 颜色
    class func hex(_ rgb: Int, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: ((CGFloat)((rgb & 0xFF0000) >> 16)) / 255.0, green: ((CGFloat)((rgb & 0xFF00) >> 8)) / 255.0, blue: ((CGFloat)(rgb & 0xFF)) / 255.0, alpha: alpha)
    }
    
    /// hex字符串转颜色
    /// - Parameters:
    ///   - hex: hex字符串
    ///   - alpha: 透明度
    /// - Returns: 颜色
    class func hex(_ hex: String, alpha: CGFloat = 1.0) -> UIColor {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = alpha
        
        let length = hexSanitized.count
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return UIColor.clear
        }
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return UIColor.clear
        }
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    /// 暗黑模式适配
    /// - Parameters:
    ///   - color: 默认颜色
    ///   - dark: 暗黑颜色
    /// - Returns: 颜色
    class func color(_ color: UIColor, dark: UIColor? = nil) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { $0.userInterfaceStyle == .dark ? (dark ?? color) : color }
        } else {
            return color
        }
    }
}

// MARK: - UIImage
extension UIImage {
    
    /// 根据颜色生成图片
    /// - Parameters:
    ///   - color: 颜色
    ///   - size: 图片尺寸
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1.0, height: 1.0)) {
        // 创建图形渲染器
        let renderer = UIGraphicsImageRenderer(size: size)
        // 渲染图片
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        // 获取图像数据
        guard let cgImage = image.cgImage else {
            return nil
        }
        // 调用系统初始化方法
        self.init(cgImage: cgImage)
    }
}
