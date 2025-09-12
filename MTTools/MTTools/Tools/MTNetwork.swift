//
//  MTNetwork.swift
//  MTTools
//
//  Created by Koi on 2025/9/12.
//

import UIKit
import Alamofire

class MTNetwork {
    /// 单例
    static let shared: MTNetwork = MTNetwork()
    /// 会话
    private let session: Session
    
    private var isRefreshingToken: Bool = false
    
    private var pendingRequests: [(Result<String, Error>) -> Void] = []
    
    private init() {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 15.0
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = Session(configuration: configuration)
    }
}

// MARK: - MTNetwork.request
extension MTNetwork {
    
    static func request<T: Decodable>(api: MTNetwork.API) async throws -> MTResponse<T> {
        return try await MTNetwork.shared.performRequest(api)
    }
}

// MARK: - private func
private extension MTNetwork {
    
    /// 预处理请求
    func preprocessRequest<T: Decodable>(_ api: MTNetwork.API) async throws -> MTResponse<T> {
        // 如果正在刷新token
        if isRefreshingToken {
            return try await waitTokenRefresh(api: api)
        }
        do {
            return try await performRequest(api)
        } catch let error as NSError {
            if error.code == 10003 || error.code == 301013 {
                return try await handleTokenRefresh(api: api)
            }
            throw error
        } catch {
            throw error
        }
    }
    
    /// 等待token刷新
    /// - Parameter api: 等待刷新的请求
    /// - Returns: 解析后的MTResponse<T>结果
    func waitTokenRefresh<T: Decodable>(api: MTNetwork.API) async throws -> MTResponse<T> {
        return try await withCheckedThrowingContinuation { continuation in
            addPendingRequest { result in
                switch result {
                case .success(_):
                    Task {
                        do {
                            let response: MTResponse<T> = try await self.performRequest(api)
                            continuation.resume(returning: response)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func handleTokenRefresh<T: Decodable>(api: MTNetwork.API) async throws -> MTResponse<T> {
        guard !isRefreshingToken else {
            return try await waitTokenRefresh(api: api)
        }
        isRefreshingToken = true
        // 执行token刷新
        let tokenResult: Result<MTResponse<CRToken>, Error> = try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let response: MTResponse<CRToken> = try await performRequest(MTRequestAPI.refreshToken)
                    continuation.resume(returning: .success(response))
                } catch {
                    continuation.resume(returning: .failure(error))
                }
            }
        }
        isRefreshingToken = false
        switch tokenResult {
        case .success(let response):
            print(response)
            processQueue(with: .success(""))
            return try await performRequest(api)
        case .failure(let error):
            processQueue(with: .failure(error))
            throw error
        }
    }
    
    /// 添加暂停请求回调
    private func addPendingRequest(completion: @escaping (Result<String, Error>) -> Void) {
        pendingRequests.append(completion)
    }
    
    /// 执行所有暂停的回调
    private func processQueue(with result: Result<String, Error>) {
        pendingRequests.forEach { $0(result) }
        pendingRequests.removeAll()
    }
    
    /// 执行请求并解析
    /// - Parameter api: 接口
    /// - Returns: 解析后的MTResponse<T>结果
    func performRequest<T: Decodable>(_ api: MTNetwork.API) async throws -> MTResponse<T> {
        if let requestAPI = api as? MTRequestAPI {
            return try await performRequestAPI(requestAPI)
        }
        return try await session.request(api.urlStr, method: api.method, parameters: api.params, headers: api.header).response()
    }
    
    /// 请求接口并解析
    /// - Parameter api: 接口
    /// - Returns: 解析后的MTResponse<T>结果
    func performRequestAPI<T: Decodable>(_ api: MTRequestAPI) async throws -> MTResponse<T> {
        return try await session.request(api.urlStr, method: api.method, parameters: api.params, headers: api.header).response()
    }
    
    func performUploadAPI<T: Decodable>(_ api: MTUploadAPI) async throws -> MTResponse<T> {
        return try await session.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(api.data!, withName: api.name, fileName: api.fileName, mimeType: api.mimeType)
            for (key, value) in api.params {
                if let data = "\(value)".data(using: .utf8) {
                    multipartFormData.append(data, withName: key)
                }
            }
        }, to: api.urlStr, method: api.method, headers: api.header).response()
    }
}

// MARK: - Alamofire.DataRequest
extension Alamofire.DataRequest {
    /// 泛型数据解析（支持指定T类型）
    /// - Returns: 解析后的MTResponse<T>结果
    fileprivate func response<T: Decodable>() async throws -> MTResponse<T> {
        // 等待数据返回
        let result = await serializingData().result
        
        switch result {
        case .success(let data):
            do {
                let decoder = JSONDecoder()
                // 配置解码器（根据需要添加）
                decoder.keyDecodingStrategy = .convertFromSnakeCase // 蛇形转驼峰
                decoder.dateDecodingStrategy = .iso8601 // 日期解析策略
                
                // 解析为指定的MTResponse<T>类型
                let response = try decoder.decode(MTResponse<T>.self, from: data)
                /*
                if response.code == 10003 || response.code == 301013 {
                    // token失败
                    throw NSError(domain: request?.url?.absoluteString ?? "", code: response.code, userInfo: [NSLocalizedDescriptionKey: response.debug_msg ?? (response.msg ?? "请求失败")])
                } else if response.code != 0 {
                    throw NSError(domain: request?.url?.absoluteString ?? "", code: response.code, userInfo: [NSLocalizedDescriptionKey: response.debug_msg ?? (response.msg ?? "请求失败")])
                } else {
                    return response
                }*/
                
                // 业务逻辑校验（code == 0 视为成功）
                guard response.code == 0 else {
                    throw NSError(domain: request?.url?.absoluteString ?? "", code: response.code, userInfo: [NSLocalizedDescriptionKey: response.debug_msg ?? (response.msg ?? "请求失败")])
                }
                return response
                 
            } catch {
                throw error
            }
        case .failure(let error):
            throw error
        }
    }
}

// MARK: - MTResponse
struct MTResponse<T: Decodable>: Decodable {
    /// 状态码
    let code: Int
    /// 消息
    var msg: String? = ""
    /// 调试消息
    var debug_msg: String? = ""
    /// 数据
    var data: T? = nil
}
