//
//  MTNetwork+API.swift
//  MTTools
//
//  Created by Koi on 2025/9/12.
//

import UIKit
import Foundation
import Alamofire

extension MTNetwork {
    protocol API {
        /// 请求地址
        var urlStr: String { get }
        /// 请求方式
        var method: HTTPMethod { get }
        /// 签名方式
        //var sign: CRNetwork.Signature { get }
        /// 请求头
        var header: HTTPHeaders? { get }
        /// 私有参数
        var params: Parameters { get }
    }
}

enum MTRequestAPI: MTNetwork.API {
    
    /// 刷新token
    case refreshToken
    
    case getCountry
    
    case getProvince(ncode: String)
    
    var urlStr: String {
        switch self {
        case .refreshToken:
            return "https://newuc.x431.com/api/Area/getCountry?action=1"
        case .getCountry:
            return "https://newuc.x431.com/api/Area/getCountry?action=1"
        case .getProvince(_):
            return "https://newuc.x431.com/api/Area/getProvinceList?action"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .refreshToken:
            return .post
        case .getCountry:
            return .post
        case .getProvince(_):
            return .post
        }
    }
    
    var header: Alamofire.HTTPHeaders? {
        return [:]
    }
    
    var params: Alamofire.Parameters {
        switch self {
        case .refreshToken:
            return [:]
        case .getCountry:
            return ["lan": "zh"]
        case .getProvince(let ncode):
            return ["lan": "zh", "ncode": ncode]
        }
    }
}

enum MTUploadAPI: MTNetwork.API {
    case face(image: UIImage)
    
    var urlStr: String {
        return ""
    }
    
    var method: Alamofire.HTTPMethod {
        return .get
    }
    
    var header: Alamofire.HTTPHeaders? {
        return [:]
    }
    
    var params: Alamofire.Parameters {
        return ["type": "1"]
    }
    
    /// 文件数据
    var data: Data? {
        return nil
    }
    
    /// 名称
    var name: String {
        return "pic"
    }
    
    /// 文件名
    var fileName: String {
        return "avatar.jpg"
    }
    
    /// 文件类型
    var mimeType: String {
        return "image/jpeg"
    }
}
