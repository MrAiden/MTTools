//
//  UIButton+Position.swift
//  MTTools
//
//  Created by Koi on 2025/9/12.
//

import UIKit
import Foundation

extension UIButton {
    /// 图片位置
    enum ImagePosition: Int, CaseIterable {
        case left       // 图片在左
        case right      // 图片在右
        case top        // 图片在上
        case bottom     // 图片在下
    }
    
    /// 调整图片位置
    /// - Parameters:
    ///   - position: 位置
    ///   - spacing: 间距
    ///   - cache: 是否缓存计算结果
    func image(position: UIButton.ImagePosition, spacing: CGFloat, shouldCache: Bool = true) {
        // 1、备基础数据（处理空值情况）
        let imageSize = currentImage?.size ?? .zero
        let titleSize = currentTitle?.size(withAttributes: [.font: titleLabel?.font ?? .systemFont(ofSize: 17)]) ?? .zero
        let fontHash = titleLabel?.font.hashValue ?? 0
        
        // 2、检查缓存
        if shouldCache {
            let cacheKey = makeCacheKey(title: currentTitle, imageSize: imageSize, fontHash: fontHash, position: position, spacing: spacing)
            if let cachedInsets = ImagePositionCacheManager.shared.cache.object(forKey: cacheKey as NSString) {
                applyInsets(cachedInsets)
                return
            }
        }
        
        // 3、计算边缘偏移
        let cachedInsets = calculateInsets(position: position, imageSize: imageSize, titleSize: titleSize, spacing: spacing)
        
        // 4、应用偏移并缓存
        applyInsets(cachedInsets)
        if shouldCache {
            let cacheKey = makeCacheKey(title: currentTitle, imageSize: imageSize, fontHash: fontHash, position: position, spacing: spacing)
            ImagePositionCacheManager.shared.cache.setObject(cachedInsets, forKey: cacheKey as NSString)
        }
    }
    
    /// 应用计算好的偏移
    private func applyInsets(_ cache: EdgeInsetsCache) {
        imageEdgeInsets = cache.image
        titleEdgeInsets = cache.title
        contentEdgeInsets = cache.content
    }
    
    /// 生成唯一缓存键
    private func makeCacheKey(title: String?, imageSize: CGSize, fontHash: Int, position: ImagePosition, spacing: CGFloat) -> String {
        let titleHash = title?.hashValue ?? 0
        let imageSizeHash = "\(imageSize.width)x\(imageSize.height)".hashValue
        return String(format: "%d_%d_%d_%d_%.0f", titleHash, imageSizeHash, fontHash, position.rawValue, spacing)
    }
    
    /// 核心，计算不同位置的边缘偏移
    private func calculateInsets(position: ImagePosition, imageSize: CGSize, titleSize: CGSize, spacing: CGFloat) -> UIButton.EdgeInsetsCache {
        let cachedInsets = EdgeInsetsCache()
        
        switch position {
        case .left:
            // 图片在左
            let imageInset = UIEdgeInsets(top: 0, left: -spacing * 0.5, bottom: 0, right: spacing * 0.5)
            let titleInset = UIEdgeInsets(top: 0, left: spacing * 0.5, bottom: 0, right: -spacing * 0.5)
            let contentInset = UIEdgeInsets(top: 0, left: spacing * 0.5, bottom: 0, right: spacing * 0.5)
            cachedInsets.image = imageInset
            cachedInsets.title = titleInset
            cachedInsets.content = contentInset
        case .right:
            // 图片在右
            let imageInset = UIEdgeInsets(top: 0, left: titleSize.width + spacing * 0.5, bottom: 0, right: -(titleSize.width + spacing * 0.5))
            let titleInset = UIEdgeInsets(top: 0, left: -(imageSize.width + spacing * 0.5), bottom: 0, right: imageSize.width + spacing * 0.5)
            let contentInset = UIEdgeInsets(top: 0, left: spacing * 0.5, bottom: 0, right: spacing * 0.5)
            cachedInsets.image = imageInset
            cachedInsets.title = titleInset
            cachedInsets.content = contentInset
        case .top, .bottom:
            // 计算偏移
            /// 图片偏移
            let imageOffsetX: CGFloat = titleSize.width * 0.5
            let imageOffsetY: CGFloat = imageSize.height * 0.5 + spacing * 0.5
            
            /// 标题偏移
            let titleOffsetX: CGFloat = imageSize.width * 0.5
            let titleOffsetY: CGFloat = titleSize.height * 0.5 + spacing * 0.5
            /// 内容变化
            let changedWidth = min(titleSize.width, imageSize.width)
            let changedHeight = min(titleSize.height, imageSize.height) + spacing
            
            var imageInset: UIEdgeInsets = .zero
            var titleInset: UIEdgeInsets = .zero
            var contentInset: UIEdgeInsets = .zero
            
            if position == .top {
                // 图片在上
                imageInset = UIEdgeInsets(top: -imageOffsetY, left: imageOffsetX, bottom: imageOffsetY, right: -imageOffsetX)
                titleInset = UIEdgeInsets(top: titleOffsetY, left: -titleOffsetX, bottom: -titleOffsetY, right: titleOffsetX)
                contentInset = UIEdgeInsets(top: imageOffsetY, left: -changedWidth * 0.5, bottom: changedHeight - imageOffsetY, right: -changedWidth * 0.5)
            } else {
                // 图片在下
                imageInset = UIEdgeInsets(top: imageOffsetY, left: imageOffsetX, bottom: -imageOffsetY, right: -imageOffsetX)
                titleInset = UIEdgeInsets(top: -titleOffsetY, left: -titleOffsetX, bottom: titleOffsetY, right: titleOffsetX)
                contentInset = UIEdgeInsets(top: changedHeight - imageOffsetY, left: -changedWidth * 0.5, bottom: imageOffsetY, right: -changedWidth * 0.5)
            }
            cachedInsets.image = imageInset
            cachedInsets.title = titleInset
            cachedInsets.content = contentInset
        }
        return cachedInsets
    }
}

// 缓存相关类（独立封装，职责单一）
private extension UIButton {
    /// 缓存模型：存储计算好边缘偏移
    class EdgeInsetsCache: NSObject {
        var image: UIEdgeInsets = .zero
        var title: UIEdgeInsets = .zero
        var content: UIEdgeInsets = .zero
    }
    
    /// 缓存管理器
    class ImagePositionCacheManager: NSObject {
        static let shared = ImagePositionCacheManager()
        private override init() {} // 禁止外部初始化
        
        /// 缓存容器（限制最大缓存数量，避免内存增长）
        let cache = NSCache<AnyObject, UIButton.EdgeInsetsCache>()
        
        // 提供清除缓存的方法（方便外部主动更新）
        func clearCache() {
            cache.removeAllObjects()
        }
    }
}
