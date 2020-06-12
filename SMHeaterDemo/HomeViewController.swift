//
//  HomeViewController.swift
//  SMHeaterDemo
//
//  Created by GrayLand on 2020/6/11.
//  Copyright © 2020 GrayLand119. All rights reserved.
//

import UIKit
@_exported import GLDemoUIKit
@_exported import SnapKit

class HomeViewController: GLBaseViewController, UITableViewDataSource, UITableViewDelegate  {
    
    // MARK: - Lift Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayout()
        
        title = "HomeViewController"
        tableView.reloadData()
    }
    
    override func setupViews() {
        view.addSubview(tableView)
    }
    
    override func setupLayout() {
        tableView.snp.makeConstraints { (make) -> Void in
            if #available(iOS 11.0, *) {
                make.edges.equalToSuperview().priority(ConstraintPriority.low)
                make.top.equalTo(view.safeAreaLayoutGuide).priority(ConstraintPriority.high)
            } else {
                make.edges.equalToSuperview()
            }
        }
    }
    
    // MARK: - Override
    
    // MARK: - Public
    
    // MARK: - Private
    func onScanCell() {
        
        #if DEBUG
        if TARGET_OS_SIMULATOR > 0 {
            gotoScan()
            return
        }
        #endif
        
        if !SMHeaterManager.defaultManager.isBLEOn {
            self.showGotoSettingAlert()
            return
        }

        gotoScan()
    }
    
    func showGotoSettingAlert() {
        let alertVC = UIAlertController.init(title: NSLocalizedString("prompt_title", comment: "提示"),
                                             message: NSLocalizedString("open_ble_desc", comment: "需要使用蓝牙来连接 A-Wearable 设备"),
                                             preferredStyle: UIAlertController.Style.alert)
        alertVC.addAction(UIAlertAction.init(title: NSLocalizedString("common_cancel", comment: "common_cancel"),
                                             style: UIAlertAction.Style.cancel, handler: { (_) in
                                                
        }))
        alertVC.addAction(UIAlertAction.init(title: NSLocalizedString("goto_setting_desc", comment: "goto_setting_desc"),
                                             style: UIAlertAction.Style.default, handler: { (_) in
                                                self.gotoSetting()
        }))
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func gotoSetting () {
        UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, completionHandler: nil)
    }
    
    func gotoScan() {
        let vc = ScanViewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - OnEvent
    
    // MARK: - Custom Delegate
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell") ?? UITableViewCell.init()
        cell.backgroundColor = BG_COLOR
        cell.textLabel?.textColor = TITLE_COLOR
        cell.textLabel?.text = "Scan Heater"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onScanCell()
    }
    
    // MARK: - Setter
    
    // MARK: - Getter
    lazy var tableView: GLBaseTableView = {
        let tb = GLBaseTableView.init()
        tb.backgroundColor = UIColor.init(white: 0.9, alpha: 1)
        tb.delegate = self
        tb.dataSource = self
        tb.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        return tb
    }()
    
}
