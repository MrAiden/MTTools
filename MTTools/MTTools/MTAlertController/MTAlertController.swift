//
//  MTAlertController.swift
//  MTTools
//
//  Created by Koi on 2025/9/12.
//

import UIKit
import SnapKit

class MTAlertController: UIViewController {
    // MARK: - UI components
    /// 详情
    private let message: String?
    /// 转场动画
    private let transitioning: MTAlertTransitioning
    
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
        view.setNeedsUpdateConstraints()
        view.backgroundColor = UIColor.white
    }
    
    override func updateViewConstraints() {
        view.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 270.0, height: 270.0))
        }
        super.updateViewConstraints()
    }
}

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
