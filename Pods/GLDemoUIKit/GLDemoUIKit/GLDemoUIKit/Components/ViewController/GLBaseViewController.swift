//
//  GLBaseViewController.swift
//  SmartHeater
//
//  Created by GrayLand on 2020/3/30.
//  Copyright © 2020 GrayLand119. All rights reserved.
//

import UIKit

open class GLBaseViewController: UIViewController {
    private var _gradientColorLayer: CAGradientLayer?
    public init() {
        super.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Lift Cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = UIRectEdge.all
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = MColor.init(UIColor.white, dark: UIColor.black).color
//        self.setupViews()
//        self.setupLayout()
    }
    // MARK: - Setup
    open func setupViews() {
        
    }
    
    open func setupLayout() {
        
    }
    
    // MARK: - Override
    
    // MARK: - Public
    open func setupGradientBGColor() {
        if _gradientColorLayer != nil {
            _gradientColorLayer?.removeFromSuperlayer()
        }
        _gradientColorLayer = CAGradientLayer.init()
        _gradientColorLayer!.frame = self.view.bounds
        _gradientColorLayer!.colors = [BG_COLOR_TOP.cgColor, BG_COLOR_BOTTOM.cgColor]
        _gradientColorLayer!.locations = [NSNumber(0.0), NSNumber(1.0)]
        _gradientColorLayer!.startPoint = CGPoint.init(x: 0.5, y: 0.0)
        _gradientColorLayer!.endPoint = CGPoint.init(x: 0.5, y: 1.0)
        self.view.layer.insertSublayer(_gradientColorLayer!, at: 0)
        //        self.view.layer.addSublayer(gradientColorLayer)
    }
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupGradientBGColor()
    }
    
    // MARK: - Private
    
    // MARK: - OnEvent
    
    // MARK: - Custom Delegate
    
    // MARK: - Setter
    
    // MARK: - Getter
}

public extension GLBaseViewController {
    func showSystemAlert(_ inController: UIViewController, _ title: String?, _ message: String?,_ cancelTitle: String?, cancelHandler: GLVoidCompletion?, okTitle: String?, okHandler : GLVoidCompletion?) {
        let alertVC = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertVC.addAction(UIAlertAction.init(title: cancelTitle ?? "取消", style: UIAlertAction.Style.cancel, handler: { (_) in
            if let cancel = cancelHandler {
                cancel()
            }
        }))
        if let ok = okHandler {
            alertVC.addAction(UIAlertAction.init(title: okTitle ?? "确定", style: UIAlertAction.Style.default, handler: { (_) in
                ok()
            }))
        }
        
        inController.present(alertVC, animated: true, completion: nil)
    }
}

