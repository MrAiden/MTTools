//
//  MTAlertAction.swift
//  MTTools
//
//  Created by Koi on 2025/9/12.
//

import UIKit

class MTAlertAction: NSObject {

}

/**
 //
 //  MTAlertView.swift
 //  CarRepairList
 //
 //  Created by Koi on 2025/7/29.
 //

 import UIKit
 import SnapKit

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

 // MARK: - MTAlertView.Style
 extension MTAlertView {
     // 样式
     enum Style {
         /// 表单
         case actionSheet
         /// 弹窗
         case alert
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

 // MARK: - MTAlertAction
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

 // MARK: - MTAlertView.Style
 private extension MTAlertView.Style {
     
     /// 内容间距
     var insets: UIEdgeInsets {
         switch self {
         case .actionSheet:
             return UIEdgeInsets(top: 20.0, left: 20.0, bottom: CRHelpers.safeAreaBottom, right: 20.0)
         case .alert:
             return UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
         }
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
                 _actionButton.setTitleColor(CRTheme.shared.white, for: .normal)
                 _actionButton.setBackgroundImage(UIImage.image(withColor: CRTheme.shared.tintColor), for: .normal)
             case .cancel:
                 _actionButton.setTitleColor(CRTheme.shared.black, for: .normal)
                 _actionButton.setBackgroundImage(UIImage.image(withColor: CRTheme.shared.colorF1F1F1), for: .normal)
             }
             _actionButton.setTitleColor(CRTheme.shared.white, for: .disabled)
             _actionButton.setBackgroundImage(UIImage.image(withColor: CRTheme.shared.color898989), for: .disabled)
             _actionButton.layer.cornerRadius = 5.0
             _actionButton.layer.masksToBounds = true
         }
         return _actionButton
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

 // MARK: - MTAlertView
 class MTAlertView: UIView {

     // MARK: - UI components
     /// 内容
     private var _contentView: UIView!
     /// 内容布局
     private var _contentStackView: UIStackView!
     /// 信息
     private var _infoView: UIView!
     /// 信息布局
     private var _infoStackView: UIStackView!
     /// 标题
     private var _titleLabel: UILabel!
     /// 消息
     private var _messageLabel: UILabel!
     /// 按钮
     private var _actionsView: UIView!
     /// 按钮布局
     private var _actionsStackView: UIStackView!
     
     // MARK: - Property
     /// 标题
     var title: String? = nil {
         didSet {
             titleLabel.text = title
             updateInfoViewDisplay()
         }
     }
     /// 消息
     var message: String? = nil {
         didSet {
             messageLabel.text = message
             updateInfoViewDisplay()
         }
     }
     /// 样式
     private(set) var style: MTAlertView.Style
     /// 操作
     private(set) var actions: [MTAlertAction] = []
     
     // MARK: - Constant
     /// 弹窗最大宽度
     private let alertContentMaxWidth: CGFloat = 300.0
     /// 弹窗最小宽度
     private let alertContentMinWidth: CGFloat = 280.0
     /// 弹窗最小高度
     private let alertContentMinHeight: CGFloat = 150.0
     
     // MARK: - Life Cycle
     
     required init(title: String?, message: String?, style: MTAlertView.Style = .alert) {
         self.style = style
         super.init(frame: UIScreen.main.bounds)
         self.title = title
         self.message = message
         setupViews()
         updateInfoViewDisplay()
     }

     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         super.touchesBegan(touches, with: event)
         guard let touch = touches.first, style == .actionSheet else {
             return
         }
         let point = touch.location(in: self)
         if contentView.frame.contains(point) {
             return
         }
         dismiss()
     }
     
     // MARK: - views custom & addition & layout
     
     private func setupViews() {
         backgroundColor = CRTheme.shared.black.withAlphaComponent(0.3)
         
         /// 信息
         titleLabel.text = title
         messageLabel.text = message
         infoStackView.addArrangedSubview(titleLabel)
         infoStackView.addArrangedSubview(messageLabel)
         infoView.addSubview(infoStackView)
         
         /// 按钮
         actionsView.addSubview(actionsStackView)
         actionsView.isHidden = true
         /// 内容布局
         contentStackView.addArrangedSubview(infoView)
         contentStackView.addArrangedSubview(actionsView)
         
         /// 内容
         contentView.addSubview(contentStackView)
         addSubview(contentView)
         
         setNeedsUpdateConstraints()
     }
     
     override func updateConstraints() {
         if style == .actionSheet {
             contentView.snp.makeConstraints { make in
                 make.bottom.equalToSuperview()
                 make.left.right.equalToSuperview()
             }
         } else {
             let minWidth = min(max(CRHelpers.scale(width: alertContentMinWidth), alertContentMinWidth), alertContentMaxWidth)
             contentView.snp.makeConstraints { make in
                 make.center.equalToSuperview()
                 make.left.greaterThanOrEqualToSuperview().offset(20.0)
                 make.width.lessThanOrEqualTo(alertContentMaxWidth)
                 make.width.greaterThanOrEqualTo(minWidth)
                 make.height.greaterThanOrEqualTo(alertContentMinHeight)
             }
         }
         contentStackView.snp.makeConstraints { make in
             make.edges.equalTo(style.insets)
         }
         infoStackView.snp.makeConstraints { make in
             make.edges.equalToSuperview()
         }
         actionsStackView.snp.makeConstraints { make in
             make.edges.equalToSuperview()
         }
         super.updateConstraints()
     }
     
     /// 更新Info是否显示
     private func updateInfoViewDisplay() {
         guard style == .actionSheet else {
             return
         }
         let isTitleEmpty = titleLabel.text?.isEmpty ?? true
         let isMessageEmpty = messageLabel.text?.isEmpty ?? true
         let shouldHideInfoView = infoStackView.arrangedSubviews.count == 2 && isTitleEmpty && isMessageEmpty
         infoView.isHidden = shouldHideInfoView
     }
     
     /// 更新按钮约束
     private func updateActionsConstraints() {
         actionsView.isHidden = actions.isEmpty
         guard actions.count > 0 else {
             return
         }
         let actionHeight: CGFloat = style == .alert ? 40.0 : 50.0
         if actions.count > 2 || style == .actionSheet {
             // 垂直分布
             let spacing = 10.0
             actions = actions.filter({ $0.style != .cancel }) + actions.filter({ $0.style == .cancel })
             actionsStackView.frame.size.height = CGFloat(actions.count) * actionHeight + CGFloat(actions.count - 1) * spacing
             actionsStackView.spacing = spacing
             actionsStackView.axis = .vertical
             actionsStackView.distribution = .fill
         } else {
             // 水平分布
             actions = actions.filter({ $0.style == .cancel }) + actions.filter({ $0.style != .cancel })
             actionsStackView.spacing = 20.0
             actionsStackView.axis = .horizontal
             actionsStackView.distribution = .fillEqually
         }
         for action in actions {
             actionsStackView.addArrangedSubview(action.actionButton)
             action.actionButton.snp.remakeConstraints { make in
                 make.height.equalTo(actionHeight)
             }
         }
     }
 }

 // MARK: - Public func
 extension MTAlertView {
     
     /// 添加操作
     /// - Parameter action: 操作
     func addAction(_ action: MTAlertAction) {
         if action.style == .cancel {
             let isExisting = actions.contains(where: { $0.style == .cancel })
             if isExisting {
                 assertionFailure("Action cancel style is only one")
                 return
             }
         }
         action.actionButton.addTarget(self, action: #selector(clickAction(_:)), for: .touchUpInside)
         actions.append(action)
     }
     
     /// 添加自定义控件
     /// - Parameters:
     ///   - view: 自定义控件
     ///   - dependency: 依赖
     ///   - position: 位置
     func addCustomView(_ view: UIView, dependency: MTAlertView.Dependency = .message, position: MTAlertView.Position = .bottom) {
         switch dependency {
         case .title:
             if position == .top {
                 infoStackView.insertArrangedSubview(view, aboveSubview: titleLabel)
             } else {
                 infoStackView.insertArrangedSubview(view, aboveSubview: messageLabel)
             }
             updateInfoViewDisplay()
         case .message:
             if position == .top {
                 infoStackView.insertArrangedSubview(view, aboveSubview: messageLabel)
             } else {
                 infoStackView.addArrangedSubview(view)
             }
             updateInfoViewDisplay()
         case .action:
             if position == .top {
                 contentStackView.insertArrangedSubview(view, aboveSubview: actionsView)
             } else {
                 contentStackView.addArrangedSubview(view)
             }
         }
     }
     
     /// 显示弹窗
     func show() {
         let window = CRHelpers.keyWindow
         window?.addSubview(self)
         updateActionsConstraints()
         addNotification()
         showAnimation()
     }
 }

 // MARK: - Private func
 private extension MTAlertView {
     
     /// 显示动画
     func showAnimation() {
         if style == .actionSheet {
             contentView.transform = CGAffineTransform(translationX: 0, y: 200.0)
         } else {
             contentView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
         }
         UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) { [weak self] in
             self?.contentView.transform = .identity
         }
     }
     
     /// 点击按钮
     @objc func clickAction(_ sender: UIButton) {
         guard let action = actions.first(where: { $0.actionButton == sender }) else {
             return
         }
         action.handler?(action)
         if action.isDismissOnTap {
             dismiss()
         }
     }
     
     /// 隐藏弹窗
     func dismiss() {
         NotificationCenter.default.removeObserver(self)
         endEditing(true)
         dismissAnimation()
     }
     
     /// 隐藏动画
     func dismissAnimation() {
         if style == .actionSheet {
             UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                 self?.contentView.transform = CGAffineTransform(translationX: 0, y: self?.contentView.frame.height ?? 0)
             }) { [weak self] (finished) in
                 self?.contentView.subviews.forEach { $0.removeFromSuperview() }
                 self?.contentView.removeFromSuperview()
                 self?.removeFromSuperview()
             }
         } else {
             UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                 self?.contentView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                 self?.alpha = 0
             }) { [weak self] (finished) in
                 self?.contentView.subviews.forEach { $0.removeFromSuperview() }
                 self?.contentView.removeFromSuperview()
                 self?.removeFromSuperview()
             }
         }
     }
 }

 // MARK: - NotificationCenter

 private extension MTAlertView {
     
     func addNotification() {
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
     }
     
     @objc func keyboardWillShow(_ notify: Notification) {
         guard let userInfo = notify.userInfo, let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
             return
         }
         let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
         let keyboardFrame = keyboardSize.cgRectValue
         if contentView.frame.maxY > keyboardFrame.minY {
             let offset = contentView.frame.maxY - keyboardFrame.minY + 16.0
             UIView.animate(withDuration: duration) { [weak self] in
                 self?.contentView.transform = CGAffineTransform(translationX: 0, y: -offset)
             }
         }
     }
     
     @objc func keyboardWillHide(_ notify: Notification) {
         let duration = notify.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
         UIView.animate(withDuration: duration) { [weak self] in
             self?.contentView.transform = .identity
         }
     }
 }

 // MARK: - setter/getter
 private extension MTAlertView {
     
     var contentView: UIView {
         if _contentView == nil {
             _contentView = UIView()
             _contentView.backgroundColor = CRTheme.shared.white
             if style == .alert {
                 _contentView.layer.cornerRadius = 10.0
                 _contentView.layer.masksToBounds = true
             }
         }
         return _contentView
     }
     
     var contentStackView: UIStackView {
         if _contentStackView == nil {
             _contentStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 250.0, height: 200.0))
             _contentStackView.axis = .vertical
             _contentStackView.spacing = 20.0
         }
         return _contentStackView
     }
     
     var infoView: UIView {
         if _infoView == nil {
             _infoView = UIView()
         }
         return _infoView
     }
     
     var infoStackView: UIStackView {
         if _infoStackView == nil {
             _infoStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 250.0, height: 100.0))
             _infoStackView.axis = .vertical
             _infoStackView.spacing = 10.0
         }
         return _infoStackView
     }
     
     var titleLabel: UILabel {
         if _titleLabel == nil {
             _titleLabel = UILabel(text: nil, textColor: CRTheme.shared.color333333, font: UIFont.systemFont(ofSize: 20.0, weight: .medium))
             _titleLabel.textAlignment = .center
             _titleLabel.numberOfLines = 0
             _titleLabel.setContentHuggingPriority(.required, for: .vertical)
         }
         return _titleLabel
     }
     
     var messageLabel: UILabel {
         if _messageLabel == nil {
             _messageLabel = UILabel(text: nil, textColor: CRTheme.shared.color666666, font: UIFont.systemFont(ofSize: 16.0, weight: .regular))
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
             //_actionsStackView.spacing = 20.0
             _actionsStackView.axis = .vertical
             _actionsStackView.distribution = .fillEqually
         }
         return _actionsStackView
     }
 }

 */
