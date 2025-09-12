//
//  MTHelpers.swift
//  MTTools
//
//  Created by Koi on 2025/9/12.
//

import UIKit
import Foundation

struct MTHelpers {
    
    private init() {}
}

// MARK: - UIScreen
extension MTHelpers {
    /// 设计基准宽
    private static let designWidth: CGFloat = 390.0
    /// 设计基准高
    private static let designHeight: CGFloat = 844.0
    // 主屏幕 bounds
    static let mainBounds: CGRect = UIScreen.main.bounds
    /// 屏幕宽
    static let screenWidth: CGFloat = mainBounds.size.width
    /// 屏幕高
    static let screenHeight: CGFloat = mainBounds.size.height
    /// 宽度比例
    static let widthScale: CGFloat = screenWidth / designWidth
    /// 高度比例
    static let heightScale: CGFloat = screenHeight / designHeight
    /// 宽度缩放
    static func scale(width: CGFloat) -> CGFloat {
        return widthScale * width
    }
    /// 高度缩放
    static func scale(height: CGFloat) -> CGFloat {
        return heightScale * height
    }
}

// MARK: - UIApplication
extension MTHelpers {
    /// 活跃场景
    static var activeScene: UIWindowScene? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first ??
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first
    }
    
    /// 主窗口
    static var keyWindow: UIWindow? {
        return activeScene?.windows
            .first { $0.isKeyWindow }
    }
    
    /// 安全区域顶部高度
    static var safeAreaTop: CGFloat {
        return keyWindow?.safeAreaInsets.top ?? 0.0
    }
    
    /// 安全区域底部高度
    static var safeAreaBottom: CGFloat {
        return keyWindow?.safeAreaInsets.bottom ?? 0.0
    }
    
    /// 场景代理
    static var sceneDelegate: SceneDelegate? {
        return activeScene?.delegate as? SceneDelegate
    }
}
