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
    
    // 依赖区域
    enum Dependency {
        /// 标题
        case title
        /// 消息
        case message
        /// 按钮
        case action
    }
    
    // 依赖区域位置
    enum Position {
        /// 上方
        case top
        /// 下方
        case bottom
    }
}

class MTAlertController: UIViewController {
    
    // MARK: - Property
    /// 详情
    private let message: String?
    /// 转场动画
    private let transitioning: MTAlertTransitioning
    /// 样式
    private let style: MTAlertController.Style
    
    // MARK: - UI components
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
        self.style = style
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
        
        /// 内容
        titleLabel.text = title
        messageLabel.text = message
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(messageLabel)
        contentView.addSubview(contentStackView)
        
        /// 按钮
        actionsView.addSubview(actionsStackView)
        actionsView.isHidden = true
        
        /// 布局
        stackView.addArrangedSubview(contentView)
        stackView.addArrangedSubview(actionsView)
        view.addSubview(stackView)
        
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        /// 内间距
        let inset: UIEdgeInsets = style == .alert ? UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0) : UIEdgeInsets(top: 20.0, left: 20.0, bottom: view.safeAreaInsets.bottom, right: 20.0)
        let minWidth = min(max(MTHelpers.scale(width: 280.0), 300.0), 300.0)
        
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        actionsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(inset)
        }
        view.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(20.0)
            make.width.lessThanOrEqualTo(300.0)
            make.width.greaterThanOrEqualTo(minWidth)
            make.height.greaterThanOrEqualTo(150.0)
        }
        view.layer.cornerRadius = 10.0
        super.updateViewConstraints()
    }
}

// MARK: - Public func
extension MTAlertController {
    
    /// 添加操作
    /// - Parameter action: 操作
    func addAction(_ action: MTAlertAction) {
        
    }
    
    /// 添加自定义控件
    /// - Parameters:
    ///   - view: 自定义控件
    ///   - dependency: 依赖
    ///   - position: 位置
    func addCustomView(_ view: UIView, dependency: MTAlertController.Dependency = .message, position: MTAlertController.Position = .bottom) {
        switch dependency {
        case .title:
            if position == .top {
                contentStackView.insertArrangedSubview(view, aboveSubview: titleLabel)
            } else {
                contentStackView.insertArrangedSubview(view, aboveSubview: messageLabel)
            }
            
            // 更新 contentStackView 显示
        case .message:
            if position == .top {
                contentStackView.insertArrangedSubview(view, aboveSubview: messageLabel)
            } else {
                contentStackView.addArrangedSubview(view)
            }
            
            // 更新 contentStackView 显示
        case .action:
            if position == .top {
                stackView.insertArrangedSubview(view, aboveSubview: actionsView)
            } else {
                stackView.addArrangedSubview(view)
            }
        }
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

// MARK: - UIStackView
private extension UIStackView {
    
    /// 插入排列视图到指定视图下
    /// - Parameters:
    ///   - view: 插入的视图
    ///   - siblingSubview: 指定视图
    func insertArrangedSubview(_ view: UIView, belowSubview siblingSubview: UIView) {
        guard let index = arrangedSubviews.firstIndex(of: siblingSubview) else {
            assertionFailure("目标视图不在当前的排列视图中")
            return
        }
        insertArrangedSubview(view, at: index + 1)
    }
    
    /// 插入排量视图到指定视图上
    /// - Parameters:
    ///   - view: 插入的视图
    ///   - siblingSubview: 指定视图
    func insertArrangedSubview(_ view: UIView, aboveSubview siblingSubview: UIView) {
        guard let index = arrangedSubviews.firstIndex(of: siblingSubview) else {
            assertionFailure("目标视图不在当前的排列视图中")
            return
        }
        insertArrangedSubview(view, at: index)
    }
}
