//
//  MTAlertAction.swift
//  MTTools
//
//  Created by Koi on 2025/9/12.
//

import UIKit

// MARK: - MTAlertAction.Style
extension MTAlertAction {
    // 样式
    enum Style {
        /// 默认
        case `default`
        /// 取消
        case cancel
    }
}

class MTAlertAction: NSObject {
    
    // MARK: - UI components
    /// 按钮
    private var _actionButton: UIButton!
    
    // MARK: - Property
    /// 标题
    private(set) var title: String?
    /// 样式
    private(set) var style: MTAlertAction.Style
    /// 回调
    fileprivate var handler: ((MTAlertAction) -> Void)?
    /// 是否可用
    var isEnabled: Bool = true {
        didSet {
            actionButton.isEnabled = isEnabled
        }
    }
    /// 点击时是否关闭弹窗
    var isDismissOnTap: Bool = true
    
    // MARK: - Life Cycle
    required init(title: String?, style: MTAlertAction.Style, handler: ((MTAlertAction) -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
        super.init()
    }
}

// MARK: - MTAlertAction
private extension MTAlertAction {
    
    var actionButton: UIButton {
        if _actionButton == nil {
            _actionButton = UIButton(type: .system)
            _actionButton.setTitle(title, for: .normal)
            switch style {
            case .default:
                _actionButton.setTitleColor(UIColor.white, for: .normal)
                //_actionButton.setBackgroundImage(UIImage.image(withColor: CRTheme.shared.tintColor), for: .normal)
            case .cancel:
                _actionButton.setTitleColor(UIColor.black, for: .normal)
                //_actionButton.setBackgroundImage(UIImage.image(withColor: CRTheme.shared.colorF1F1F1), for: .normal)
            }
            _actionButton.setTitleColor(UIColor.white, for: .disabled)
            //_actionButton.setBackgroundImage(UIImage.image(withColor: CRTheme.shared.color898989), for: .disabled)
            _actionButton.layer.cornerRadius = 5.0
            _actionButton.layer.masksToBounds = true
        }
        return _actionButton
    }
}
