//
//  BaseStackVC.swift
//  LHTools
//
//  Created by 海 on 2025/11/4.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit

open class BaseStackVC: BaseVC {
    
    public let scrollView = UIScrollView()
    public let stackView = UIStackView()
    
    open var stackContentInsets: UIEdgeInsets {
        .init(top: 0, left: 24, bottom: 0, right: 24)
    }
    
    open var scrollContentInsets: UIEdgeInsets { .zero }
    
    /// Whether to pin the scroll view to the safe area (true) or the full view (false).
    open var usesSafeAreaLayout: Bool { true }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        
        self.view.addSubview(self.scrollView)
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.keyboardDismissMode = .onDrag
        self.scrollView.layer.masksToBounds = false
        
        self.scrollView.addSubview(self.stackView)
        self.stackView.axis = .vertical
        
        self.stackView.alignment = .fill
        self.stackView.distribution = .fill
        self.stackView.spacing = 0
        self.stackView.isLayoutMarginsRelativeArrangement = true
        self.stackView.layoutMargins = self.stackContentInsets

        // Avoid automatic content inset adjustments when embedded in navigation controllers (iOS 15+)
        self.scrollView.contentInsetAdjustmentBehavior = .never
        
        self.relayout()
    }
    
    open func relayout() {
        // Pin the scroll view to either the safe area or the full view based on configuration
        if self.usesSafeAreaLayout {
            self.scrollView.snp.remakeConstraints { make in
                make.edges.equalTo(self.view.safeAreaLayoutGuide).inset(self.scrollContentInsets)
            }
        } else {
            self.scrollView.snp.remakeConstraints { make in
                make.edges.equalToSuperview().inset(self.scrollContentInsets)
            }
        }

        self.stackView.snp.remakeConstraints { make in
            make.edges.equalTo(self.scrollView.contentLayoutGuide)
            make.width.equalTo(self.scrollView.frameLayoutGuide)
        }

        // Keep layoutMargins synced in case subclasses override stackContentInsets
        self.stackView.layoutMargins = self.stackContentInsets
    }

}
