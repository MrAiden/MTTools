//
//  MTAlertController.swift
//  MTTools
//
//  Created by Koi on 2025/9/12.
//

import UIKit
import SnapKit

// MARK: - MTAlertController.Style
extension MTAlertController {
    /// 样式
    enum Style {
        /// 弹窗
        case alert
        /// 表单
        case actionSheet
    }
}

class MTAlertController: UIViewController {
    // MARK: - UI components
    /// 详情
    private let message: String?
    /// 转场动画
    private let transitioning: MTAlertTransitioning
    /// 内容布局
    private var _stackView: UIStackView!
    /// 内容
    private var _contentView: UIView!
    /// 内容布局
    private var _contentStackView: UIStackView!
    /// 标题
    private var _titleLabel: UILabel!
    /// 消息
    private var _messageLabel: UILabel!
    /// 按钮部分
    private var _actionsView: UIView!
    /// 按钮布局
    private var _actionsStackView: UIStackView!
    
    
    // MARK: - Life Cycle
    init(title: String?, message: String?, style: MTAlertController.Style = .alert) {
        self.message = message
        self.transitioning = MTAlertTransitioning(style: style)
        super.init(nibName: nil, bundle: nil)
        self.title = title
        modalPresentationStyle = .custom
        transitioningDelegate = transitioning
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupViews()
    }
    
    // MARK: - views custom & addition & layout
    
    private func setupViews() {
        view.backgroundColor = UIColor.white
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        view.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 270.0, height: 270.0))
        }
        super.updateViewConstraints()
    }
}

// MARK: - setter/getter
private extension MTAlertController {
    var stackView: UIStackView {
        if _stackView == nil {
            _stackView = UIStackView()
            _stackView.axis = .vertical
        }
        return _stackView
    }
    
    var contentView: UIView {
        if _contentView == nil {
            _contentView = UIView()
        }
        return _contentView
    }
    
    var contentStackView: UIStackView {
        if _contentStackView == nil {
            _contentStackView = UIStackView()
            _contentStackView.axis = .vertical
        }
        return _contentStackView
    }
    
    var titleLabel: UILabel {
        if _titleLabel == nil {
            _titleLabel = UILabel()
            _titleLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .medium)
            _titleLabel.textColor = UIColor.black
            _titleLabel.textAlignment = .center
            _titleLabel.numberOfLines = 0
            _titleLabel.setContentHuggingPriority(.required, for: .vertical)
        }
        return _titleLabel
    }
    
    var messageLabel: UILabel {
        if _messageLabel == nil {
            _messageLabel = UILabel()
            _messageLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
            _messageLabel.textColor = UIColor.black
            _messageLabel.textAlignment = .center
            _messageLabel.numberOfLines = 0
        }
        return _messageLabel
    }
    
    var actionsView: UIView {
        if _actionsView == nil {
            _actionsView = UIView()
            _actionsView.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        return _actionsView
    }
    
    var actionsStackView: UIStackView {
        if _actionsStackView == nil {
            _actionsStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 250.0, height: 40.0))
            _actionsStackView.axis = .vertical
            _actionsStackView.distribution = .fillEqually
        }
        return _actionsStackView
    }
}
