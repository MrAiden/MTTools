//
//  MTSQLite.swift
//  MTTools
//
//  Created by Koi on 2025/9/12.
//

import Foundation
import SQLite

/// 避免与系统方法冲突
typealias MTExpression = SQLite.Expression

// MARK: - MTSQLite
protocol MTSQLite: MTSQLiteType, Codable {
    init()
    /// 自增id，外部不进行设置
    var rowid: Int64 { get set }
    /// 忽略属性名
    func ignoredPropertys() -> [String]
}

// MARK: - MTSQLite
extension MTSQLite {
    /// 忽略的属性名
    func ignoredPropertys() -> [String] {
        return []
    }
    
    /// 插入
    mutating func insert() {
        if let rowid: Int64 = MTSQLiteManager.insert(self) {
            self.rowid = rowid
        }
    }
    
    /// 先删除再插入
    mutating func insert(delete predicate: MTExpression<Bool>) {
        if let rowid: Int64 = MTSQLiteManager.insert(self, delete: predicate) {
            self.rowid = rowid
        }
    }
    
    /// 更新
    func update() {
        if rowid > 0 {
            MTSQLiteManager.update(self)
        } else {
            MTDebug("更新失败，rowid为空")
        }
    }
    
    /// 删除
    func delete() {
        MTSQLiteManager.delete(self)
    }
    
    /// 最后一个
    static func last() -> Self? {
        guard let result: [String: Any] = MTSQLiteManager.last(Self.init()) else {
            return nil
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
            
            let decoder = JSONDecoder()
            
            let model = try decoder.decode(Self.self, from: jsonData)
            return model
        } catch {
            MTDebug("查找失败，Error:\(error)")
            return nil
        }
    }
    
    /// 条件查找
    static func filter(_ predicate: MTExpression<Bool>) -> Self? {
        guard let result: [String: Any] = MTSQLiteManager.filter(Self.init(), predicate: predicate) else {
            return nil
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
            
            let decoder = JSONDecoder()
            
            let model = try decoder.decode(Self.self, from: jsonData)
            return model
        } catch {
            MTDebug("查找失败，Error:\(error)")
            return nil
        }
    }
    
    /// 条件更新
    static func update(_ predicate: MTExpression<Bool>, values: Setter...) {
        MTSQLiteManager.update(Self.init(), predicate: predicate, values: values)
    }
    
    /// 条件删除
    static func delete(_ predicate: MTExpression<Bool>) {
        MTSQLiteManager.delete(Self.init(), predicate: predicate)
    }
    
    /// 清空表
    static func clear() {
        MTSQLiteManager.clear(Self.init())
    }
    
    /// 删除表
    private static func drop() {
        MTSQLiteManager.drop(Self.init())
    }
}

// MARK: - Array.CRSQLite
extension Array where Element: MTSQLite {
    /// 批量保存
    @discardableResult
    mutating func inserts() -> Bool {
        if let rowids: [Int64] = MTSQLiteManager.inserts(self), rowids.count == count {
            for (index, rowid) in rowids.enumerated() {
                self[index].rowid = rowid
            }
            return true
        }
        return false
    }
    
    @discardableResult
    mutating func inserts(delete predicate: MTExpression<Bool>) -> Bool {
        if let rowids: [Int64] = MTSQLiteManager.inserts(self, delete: predicate), rowids.count == count {
            for (index, rowid) in rowids.enumerated() {
                self[index].rowid = rowid
            }
            return true
        }
        return false
    }
    
    /// 条件查找
    static func filter(_ predicate: MTExpression<Bool>) -> [Element]? {
        guard let results: [[String: Any]] = MTSQLiteManager.filters(Element.init(), predicate: predicate) else {
            return nil
        }
        do {
            // 将字典数组转换为JSON数据
            let jsonData = try JSONSerialization.data(withJSONObject: results,options: [])
            let decoder = JSONDecoder()
            // 解码为模型数组
            let models = try decoder.decode([Element].self, from: jsonData)
            return models
        } catch {
            MTDebug("查找失败，Error:\(error)")
            return nil
        }
    }
}

// MARK: - MTSQLite.fileprivate
fileprivate extension MTSQLite {
    /// 获取所有可存储的属性
    func readAllSQLiteChildren() -> [MTSQLiteChild] {
        let mirror = Mirror(reflecting: self)
        var children = [(label: String?, value: Any)]()
        children += mirror.children
        
        var currentMirror = mirror
        while let superclassChildren = currentMirror.superclassMirror?.children {
            children += superclassChildren
            currentMirror = currentMirror.superclassMirror!
        }
        
        var result = [MTSQLiteChild]()
        var ignores = ignoredPropertys()
        if let index = ignores.firstIndex(of: MTSQLiteManager.rowid) {
            ignores.remove(at: index)
        }
        children.forEach { (child) in
            if let label = child.label, !ignores.contains(label) {
                let type = valueType(child.value)
                if type != .unsupported {
                    result.append(MTSQLiteChild(key: label, value: child.value, type: type))
                }
            }
        }
        return result
    }
}

// MARK: MTSQLiteManager
fileprivate struct MTSQLiteManager {
    /// 主键key
    static let rowid: String = "rowid"
    /// 自增主键
    private static let rowidColumn: MTExpression<Int64> = MTExpression<Int64>(rowid)
    /// 单例
    public static let manager: MTSQLiteManager = MTSQLiteManager()
    /// 连接数据库
    var db: Connection?
    /// 存储路径
    private let filePath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    /// 数据库名
    private let fileName: String = "MTSQLite.sqlite3"
    /// 已建了表数组
    private static var tables: [String] = []
    
    /// 初始化方法
    private init() {
        if db == nil {
            do {
                db = try Connection("\(filePath)/\(fileName)")
                db?.busyTimeout = 5.0
            } catch {
                MTError("SQLite Connection Error:\(error)")
            }
        }
    }
    
    // MARK: create table
    /// 创建表
    private static func createTable(_ sqlite: MTSQLite) {
        guard let db = manager.db else {
            MTError("SQLite is not connected")
            return
        }
        let name = String(describing: type(of: sqlite))
        if MTSQLiteManager.tables.contains(name) {
            return
        }
        let table = Table(name)
        let children = sqlite.readAllSQLiteChildren()
        do {
            try db.run(table.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { builder in
                children.forEach { child in
                    builder.column(child)
                }
            }))
            MTSQLiteManager.tables.append(name)
        } catch {
            MTError("Table:\(name), crate error: \(error)")
        }
        // 新增列
        do {
            let statement = "PRAGMA table_info(\(name))"
            let existingColumns = try db.prepare(statement).compactMap({ $0[1] as? String })
            try db.transaction {
                try children.forEach { child in
                    if !existingColumns.contains(child.key) {
                        try db.run(table.addChild(child))
                        MTDebug("Table:\(name), add column: \(child.key)")
                    }
                }
            }
        } catch {
            MTError("Table:\(name), add column error: \(error)")
        }
    }
    
    // MARK: - insert
    
    fileprivate static func insert(_ sqlite: MTSQLite, delete predicate: MTExpression<Bool>? = nil) -> Int64? {
        guard let db = manager.db else {
            return nil
        }
        MTSQLiteManager.createTable(sqlite)
        let name = String(describing: type(of: sqlite))
        let table = Table(name)
        /// 如果有删除条件，先删除
        if let predicate = predicate {
            do {
                let delete = table.filter(predicate).delete()
                try db.run(delete)
                MTDebug("Table:\(name), delete success")
            } catch {
                MTError("Table:\(name), delete error: \(error)")
            }
        }
        /// 插入
        let children = sqlite.readAllSQLiteChildren()
        let values: [Setter] = children.compactMap({ child in
            if child.isPrimaryKey {
                return nil
            }
            return child.setter
        })
        do {
            let insert = table.insert(values)
            let rowid = try db.run(insert)
            MTDebug("Table:\(name), insert success")
            return rowid
        } catch {
            MTError("Table:\(name), insert error: \(error)")
            return nil
        }
    }
    
    /// 批量插入
    fileprivate static func inserts(_ sqlites: [MTSQLite], delete predicate: MTExpression<Bool>? = nil) -> [Int64]? {
        guard let db = manager.db, !sqlites.isEmpty else {
            return nil
        }
        /// 如果有删除条件，先删除
        if let sqlite = sqlites.first, let predicate = predicate {
            MTSQLiteManager.createTable(sqlite)
            let name = String(describing: type(of: sqlite))
            let table = Table(name)
            do {
                let delete = table.filter(predicate).delete()
                try db.run(delete)
                MTDebug("Table:\(name), delete success")
            } catch {
                MTError("Table:\(name), delete error: \(error)")
            }
        }
        /// 插入
        var rowids: [Int64] = []
        var tablename: String = ""
        do {
            try db.transaction {
                for sqlite in sqlites {
                    MTSQLiteManager.createTable(sqlite)
                    // 保存
                    let name = String(describing: type(of: sqlite))
                    tablename = name
                    let table = Table(name)
                    let children = sqlite.readAllSQLiteChildren()
                    let values: [Setter] = children.compactMap({ child in
                        if child.isPrimaryKey {
                            return nil
                        }
                        return child.setter
                    })
                    let insert = table.insert(values)
                    let rowid = try db.run(insert)
                    rowids.append(rowid)
                }
            }
            MTDebug("Table:\(tablename), insert success")
        } catch {
            MTError("Table:\(tablename), insert error:\(error)")
            return nil
        }
        return rowids
    }
    
    // MARK: update
    /// 更新数据
    fileprivate static func update(_ sqlite: MTSQLite) {
        guard let db = manager.db else {
            return
        }
        MTSQLiteManager.createTable(sqlite)
        let name = String(describing: type(of: sqlite))
        let table = Table(name)
        let children = sqlite.readAllSQLiteChildren()
        let values: [Setter] = children.compactMap({ child in
            if child.isPrimaryKey {
                return nil
            }
            return child.setter
        })
        /// 更新
        do {
            let update = table.filter(rowidColumn == sqlite.rowid).update(values)
            try db.run(update)
            MTDebug("Table:\(name), update success")
        } catch {
            MTError("Table:\(name), update error: \(error)")
        }
    }
    
    /// 更新数据
    fileprivate static func update(_ sqlite: MTSQLite, predicate: MTExpression<Bool>, values: [Setter]) {
        guard let db = manager.db else {
            return
        }
        MTSQLiteManager.createTable(sqlite)
        let name = String(describing: type(of: sqlite))
        let table = Table(name)
        do {
            let update = table.filter(predicate).update(values)
            try db.run(update)
            MTDebug("Table:\(name), update success")
        } catch {
            MTError("Table:\(name), update error: \(error)")
        }
    }
    
    // MARK: delete
    /// 删除
    fileprivate static func delete(_ sqlite: MTSQLite) {
        delete(sqlite, predicate: rowidColumn == sqlite.rowid)
    }
    
    /// 条件删除
    fileprivate static func delete(_ sqlite: MTSQLite, predicate: MTExpression<Bool>) {
        guard let db = manager.db else {
            return
        }
        MTSQLiteManager.createTable(sqlite)
        let name = String(describing: type(of: sqlite))
        let table = Table(name)
        do {
            let delete = table.filter(predicate).delete()
            try db.run(delete)
            MTDebug("Table:\(name), delete success")
        } catch {
            MTError("Table:\(name), delete error: \(error)")
        }
    }
    
    // MARK: filter
    /// 条件查找
    fileprivate static func filter(_ sqlite: MTSQLite, predicate: MTExpression<Bool>) -> [String: Any]? {
        guard let db = manager.db else {
            return nil
        }
        MTSQLiteManager.createTable(sqlite)
        let name = String(describing: type(of: sqlite))
        let table = Table(name)
        let query = table.filter(predicate)
        let children = sqlite.readAllSQLiteChildren()
        do {
            guard let row = try db.pluck(query) else {
                return nil
            }
            var dict: [String: Any] = [:]
            try children.forEach { property in
                let value = try row.get(property)
                if let value = value {
                    dict[property.key] = value
                }
            }
            MTDebug("Table:\(name), query success")
            return dict
        } catch {
            MTError("Table:\(name), query error: \(error)")
        }
        return nil
    }
    
    /// 条件查找
    fileprivate static func filters(_ sqlite: MTSQLite, predicate: MTExpression<Bool>) -> [[String: Any]]? {
        guard let db = manager.db else {
            return nil
        }
        MTSQLiteManager.createTable(sqlite)
        let name = String(describing: type(of: sqlite))
        let table = Table(name)
        let query = table.filter(predicate)
        let children = sqlite.readAllSQLiteChildren()
        do {
            let rows = try db.prepare(query)
            var dictArray: [[String: Any]] = []
            for row in rows {
                var dict: [String: Any] = [:]
                try children.forEach { property in
                    let value = try row.get(property)
                    if let value = value {
                        dict[property.key] = value
                    }
                }
                dictArray.append(dict)
            }
            MTDebug("Table:\(name), query success")
            return dictArray
        } catch {
            MTError("Table:\(name), query error: \(error)")
        }
        return nil
    }
    
    /// 最后一个
    fileprivate static func last(_ sqlite: MTSQLite) -> [String: Any]? {
        guard let db = manager.db else {
            return nil
        }
        MTSQLiteManager.createTable(sqlite)
        let name = String(describing: type(of: sqlite))
        let table = Table(name)
        let query = table.order(rowidColumn.desc).limit(1)
        let children = sqlite.readAllSQLiteChildren()
        do {
            guard let row = try db.pluck(query) else {
                return nil
            }
            var dict: [String: Any] = [:]
            try children.forEach { property in
                let value = try row.get(property)
                if let value = value {
                    dict[property.key] = value
                }
            }
            MTDebug("Table:\(name), query success")
            return dict
        } catch {
            MTError("Table:\(name), query error: \(error)")
        }
        return nil
    }
    
    // MARK: clear table
    /// 清空表
    fileprivate static func clear(_ sqlite: MTSQLite) {
        guard let db = manager.db else {
            return
        }
        let name = String(describing: type(of: sqlite))
        let table = Table(name)
        do {
            try db.run(table.delete())
            MTDebug("Table:\(name), clear succes")
        } catch {
            MTError("Table:\(name), clear error:\(error)")
        }
    }
    
    // MARK: drop table
    /// 删除表
    fileprivate static func drop(_ sqlite: MTSQLite) {
        guard let db = manager.db else {
            return
        }
        let name = String(describing: type(of: sqlite))
        let table = Table(name)
        do {
            try db.run(table.drop(ifExists: true))
            if let index = MTSQLiteManager.tables.firstIndex(of: name) {
                MTSQLiteManager.tables.remove(at: index)
            }
            MTDebug("Table:\(name), drop succes")
        } catch {
            MTError("Table:\(name), drop error:\(error)")
        }
    }
}

// MARK: - SQLite.TableBuilder
fileprivate extension SQLite.TableBuilder {
    /// 构建列属性
    func column(_ child: MTSQLiteChild) {
        if child.isPrimaryKey {
            column(MTExpression<Int>(child.key), primaryKey: .autoincrement)
        } else {
            switch child.type {
            case .int:
                column(MTExpression<Int>(child.key))
            case .optionalInt:
                column(MTExpression<Int?>(child.key))
            case .string:
                column(MTExpression<String>(child.key))
            case .optionalString:
                column(MTExpression<String?>(child.key))
            case .double:
                column(MTExpression<Double>(child.key))
            case .optionalDouble:
                column(MTExpression<Double?>(child.key))
            case .bool:
                column(MTExpression<Bool>(child.key))
            case .optionalBool:
                column(MTExpression<Bool?>(child.key))
            case .blob:
                column(MTExpression<Blob>(child.key))
            case .optionalBlob:
                column(MTExpression<Blob?>(child.key))
            default:
                MTError("Value \(child.value) not supported")
            }
        }
    }
}

// MARK: - SQLite.Table
fileprivate extension SQLite.Table {
    /// 添加属性
    func addChild(_ child: MTSQLiteChild) -> String {
        switch child.type {
        case .int:
            return addColumn(MTExpression<Int>(child.key), defaultValue: 0)
        case .optionalInt:
            return addColumn(MTExpression<Int?>(child.key), defaultValue: nil)
        case .string:
            return addColumn(MTExpression<String>(child.key), defaultValue: "")
        case .optionalString:
            return addColumn(MTExpression<String?>(child.key), defaultValue: nil)
        case .double:
            return addColumn(MTExpression<Double>(child.key), defaultValue: 0)
        case .optionalDouble:
            return addColumn(MTExpression<Double?>(child.key), defaultValue: nil)
        case .bool:
            return addColumn(MTExpression<Bool>(child.key), defaultValue: false)
        case .optionalBool:
            return addColumn(MTExpression<Bool?>(child.key), defaultValue: nil)
        case .blob:
            let value: Data =  Data()
            return addColumn(MTExpression<Blob>(child.key), defaultValue: Blob(bytes: [UInt8](value)))
        case .optionalBlob:
            return addColumn(MTExpression<Blob?>(child.key), defaultValue: nil)
        default:
            MTError("Value \(child.value) not supported")
            return ""
        }
    }
}

// MARK: - SQLite.Row
fileprivate extension SQLite.Row {
    /// 获取属性值
    func get(_ child: MTSQLiteChild) throws -> Any? {
        switch child.type {
        case .int:
            return try get(MTExpression<Int>(child.key))
        case .optionalInt:
            return try get(MTExpression<Int?>(child.key))
        case .string:
            return try get(MTExpression<String>(child.key))
        case .optionalString:
            return try get(MTExpression<String?>(child.key))
        case .double:
            return try get(MTExpression<Double>(child.key))
        case .optionalDouble:
            return try get(MTExpression<Double?>(child.key))
        case .bool:
            return try get(MTExpression<Bool>(child.key))
        case .optionalBool:
            return try get(MTExpression<Bool?>(child.key))
        case .blob:
            let blob = try get(MTExpression<Blob>(child.key))
            return Data(bytes: blob.bytes, count: blob.bytes.count)
        case .optionalBlob:
            if let blob = try get(MTExpression<Blob?>(child.key)) {
                return Data(bytes: blob.bytes, count: blob.bytes.count)
            }
            return nil
        default:
            MTError("Value \(child.value) not supported")
            return nil
        }
    }
}

// MARK: - MTSQLiteChild
fileprivate struct MTSQLiteChild: MTSQLiteType {
    /// 属性名
    let key: String
    /// 属性值
    let value: Any
    /// 属性类型
    let type: ValueType
    
    /// 是否是主键
    var isPrimaryKey: Bool {
        return key == MTSQLiteManager.rowid
    }
    
    /// 值类型
    enum ValueType {
        case unsupported
        case int
        case optionalInt
        case string
        case optionalString
        case double
        case optionalDouble
        case bool
        case optionalBool
        case blob
        case optionalBlob
    }
    
    /// setter
    var setter: Setter? {
        switch type {
        case .unsupported:
            return nil
        case .int:
            let valueString = "\(value)"
            let value: Int = Int(valueString) ?? 0
            return Expression<Int>(key) <- value
        case .optionalInt:
            let valueString = "\(value)"
            let value: Int? = Int(valueString)
            return Expression<Int?>(key) <- value
        case .string:
            let value = value as? String ?? ""
            return Expression<String>(key) <- value
        case .optionalString:
            let value: String? = value as? String
            return Expression<String?>(key) <- value
        case .double:
            let valueString = "\(value)"
            let value: Double = Double(valueString) ?? 0.0
            return Expression<Double>(key) <- value
        case .optionalDouble:
            let valueString = "\(value)"
            let value: Double? = Double(valueString)
            return Expression<Double?>(key) <- value
        case .bool:
            let value: Bool = value as? Bool ?? false
            return Expression<Bool>(key) <- value
        case .optionalBool:
            let value: Bool? = value as? Bool
            return Expression<Bool?>(key) <- value
        case .blob:
            let value: Data = value as? Data ?? Data()
            return Expression<Blob>(key) <- Blob(bytes: [UInt8](value))
        case .optionalBlob:
            let value: Data = value as? Data ?? Data()
            return Expression<Blob>(key) <- Blob(bytes: [UInt8](value))
        }
    }
}

// MARK: - MTSQLiteType
protocol MTSQLiteType {
    
}

private extension MTSQLiteType {
    /// 属性类型
    func valueType(_ value: Any) -> MTSQLiteChild.ValueType {
        let valueType = type(of: value)
        if isInt(valueType) {
            return MTSQLiteChild.ValueType.int
        } else if isOptionalInt(valueType) {
            return MTSQLiteChild.ValueType.optionalInt
        } else if isString(valueType) {
            return MTSQLiteChild.ValueType.string
        } else if isOptionalString(valueType) {
            return MTSQLiteChild.ValueType.optionalString
        } else if isDouble(valueType) {
            return MTSQLiteChild.ValueType.double
        } else if isOptionalDouble(valueType) {
            return MTSQLiteChild.ValueType.optionalDouble
        } else if isBool(valueType) {
            return MTSQLiteChild.ValueType.bool
        } else if isOptionalBool(valueType) {
            return MTSQLiteChild.ValueType.optionalBool
        } else if isBlob(valueType) {
            return MTSQLiteChild.ValueType.blob
        } else if isOptionalBlob(valueType) {
            return MTSQLiteChild.ValueType.optionalBlob
        }
        return MTSQLiteChild.ValueType.unsupported
    }
    
    /// 支持的属性类型
    func isSupportChild(_ value: Any) -> Bool {
        let valueType = type(of: value)
        if isInt(valueType) || isOptionalInt(valueType) || isString(valueType) || isOptionalString(valueType) || isDouble(valueType) || isOptionalDouble(valueType) || isBool(valueType) || isOptionalBool(valueType) || isBlob(valueType) || isOptionalBlob(valueType) {
            return true
        }
        return false
    }
    
    /// 是int类型
    func isInt(_ valueType: Any.Type) -> Bool {
        switch valueType {
        case is Int.Type, is Int8.Type, is Int16.Type, is Int32.Type, is Int64.Type, is UInt.Type, is UInt8.Type, is UInt16.Type, is UInt32.Type, is UInt64.Type:
            return true
        default:
            return false
        }
    }
    
    /// 是int?类型
    func isOptionalInt(_ valueType: Any.Type) -> Bool {
        switch valueType {
        case is Int?.Type, is Int8?.Type, is Int16?.Type, is Int32?.Type, is Int64?.Type, is UInt?.Type, is UInt8?.Type, is UInt16?.Type, is UInt32?.Type, is UInt64?.Type:
            return true
        default:
            return false
        }
    }
    
    /// 是String类型
    func isString(_ valueType: Any.Type) -> Bool {
        switch valueType {
        case is String.Type:
            return true
        default:
            return false
        }
    }
    
    /// 是String?类型
    func isOptionalString(_ valueType: Any.Type) -> Bool {
        switch valueType {
        case is String?.Type:
            return true
        default:
            return false
        }
    }
    
    /// 是Double类型
    func isDouble(_ valueType: Any.Type) -> Bool {
        switch valueType {
        case is Float.Type, is Double.Type, is CGFloat.Type:
            return true
        default:
            return false
        }
    }
    
    /// 是Double?类型
    func isOptionalDouble(_ valueType: Any.Type) -> Bool {
        switch valueType {
        case is Float?.Type, is Double?.Type, is CGFloat?.Type:
            return true
        default:
            return false
        }
    }
    
    /// 是Bool类型
    func isBool(_ valueType: Any.Type) -> Bool {
        switch valueType {
        case is Bool.Type:
            return true
        default:
            return false
        }
    }
    
    /// 是Bool?类型
    func isOptionalBool(_ valueType: Any.Type) -> Bool {
        switch valueType {
        case is Bool?.Type:
            return true
        default:
            return false
        }
    }
    
    /// 是Data类型
    func isBlob(_ valueType: Any.Type) -> Bool {
        switch valueType {
        case is Data.Type:
            return true
        default:
            return false
        }
    }
    
    /// 是Data?类型
    func isOptionalBlob(_ valueType: Any.Type) -> Bool {
        switch valueType {
        case is Data?.Type:
            return true
        default:
            return false
        }
    }
}
