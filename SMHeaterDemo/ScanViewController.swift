//
//  ScanViewController.swift
//  SMHeaterDemo
//
//  Created by GrayLand on 2020/6/11.
//  Copyright © 2020 GrayLand119. All rights reserved.
//

import UIKit
@_exported import SMHeaterSDK

private enum CurrentState {
    case none
    case searching
    case discovered
}

class ScanViewController: GLBaseViewController, SMHeaterManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var bleDevices: [SMHeater]?
    
    // MARK: - Lift Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupLayout()
        
        connectStatus = .searching
        tableView.reloadData()
        
        #if DEBUG
        if TARGET_OS_SIMULATOR > 0 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
                self.hideHUD()
                self.gotoMonitor()
            }
            return
        }
        #endif
    }
    
    deinit {
        hideHUD()
        stopScan()
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startScan()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopScan()
    }
    
    // MARK: - Override
    
    // MARK: - Public
    func startScan() {
        SMHeaterManager.defaultManager.delegate.add(self)
        SMHeaterManager.defaultManager.scanSMDevice()
    }
    
    func stopScan() {
        SMHeaterManager.defaultManager.stopScan()
        SMHeaterManager.defaultManager.delegate.remove(self)
    }
    
    // MARK: - Private
    func gotoMonitor() {
        SMHeaterManager.defaultManager.stopScan()
        
        let vc = MonitorViewController()
        let nvc = DemoNavigationController.init(vc)
        nvc.modalPresentationStyle = .fullScreen
        self.present(nvc, animated: true, completion: nil)
    }
    
    // MARK: - OnEvent
    
    // MARK: - Custom Delegate
    // MARK: - SMHeaterManagerDelegate
    func didDiscoverDevice(bleDevices: [SMHeater]) {
        if bleDevices.count > 0 {
            if self.connectStatus != .discovered {
                self.connectStatus = .discovered
            }
        }else {
            if self.connectStatus != .searching {
                self.connectStatus = .searching
            }
        }
        self.bleDevices = bleDevices
        self.tableView.reloadData()
    }
    
    func didConnectedDevice(bleDevice: SMHeater?, error: Error?) {
        self.hideHUD()
        if bleDevice != nil {
            gotoMonitor()
        }else {
            self.showSystemAlert(self, "Notice",
                                 "Connect failed",
                                 "Back",
                                 cancelHandler: {
            }, okTitle: nil, okHandler: nil)
        }
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bleDevices?.count ?? 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell") ?? UITableViewCell()
        let heater = self.bleDevices![indexPath.row]
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "Heater: \(heater.name)\nSN:\(heater.sn)\nRSSI:\(heater.RSSI ?? 0)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.showWaitting("Connecting...")
        SMHeaterManager.defaultManager.connecteDevice(self.bleDevices![indexPath.row])
    }
    
    // MARK: - Setter
    fileprivate var connectStatus: CurrentState = .searching {
        didSet {
            if connectStatus == .searching {
                showWaitting("Sacnning")
            }else {
                hideHUD()
            }
        }
    }
    
    // MARK: - Getter
    lazy var tableView: GLBaseTableView = {
        let tb = GLBaseTableView.init()
        tb.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tb.delegate = self
        tb.dataSource = self
        return tb
    }()
}
