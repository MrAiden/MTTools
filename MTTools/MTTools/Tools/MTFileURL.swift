//
//  MTFileURL.swift
//  MTTools
//
//  Created by Koi on 2025/9/12.
//

import Foundation

struct MTFileURL {
    /// Documents 目录（用户生成的数据，会被iCloud备份）
    static var documents: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    /// Library 目录（应用支持文件，分为 Preferences 和 Caches）
    static var library: URL {
        return FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
    }
    
    /// Preferences 目录(应用偏好设置，如UserDefaults数据)
    static var preferences: URL {
        return library.appendingPathComponent("Preferences")
    }
    
    /// Caches 目录（缓存文件，不会被iCloud备份，可能被系统清理）
    static var caches: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    /// Temporary 目录（临时文件，应用退出后可能被清理）
    static var temporary: URL {
        return FileManager.default.temporaryDirectory
    }
}
