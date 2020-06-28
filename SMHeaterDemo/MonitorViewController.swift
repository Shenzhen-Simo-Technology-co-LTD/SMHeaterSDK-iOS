//
//  MonitorViewController.swift
//  SMHeaterDemo
//
//  Created by GrayLand on 2020/6/11.
//  Copyright © 2020 GrayLand119. All rights reserved.
//

import UIKit

enum CellType: Int {
    case CurrentTemperature
    case TargetTemperature
    case SlideControl
    case HeatOnOff
    case NtcState
    case QcState
    case PwmState
    case Voltage
}

class MonitorViewController: GLBaseViewController,
UITableViewDelegate, UITableViewDataSource, SMHeaterManagerDelegate {
    
    var cellTypes: [CellType]?
    var cells: [UITableViewCell]?
    
    lazy var onOffControl: UISwitch = {
        let s = UISwitch.init()
        return s
    }()
    lazy var slider: UISlider = {
        let s = UISlider()
        return s
    }()
    // MARK: - Lift Cycle
    override init() {
        super.init()
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .fullScreen
    }
    
    var leftItem: UIBarButtonItem?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = self.className().components(separatedBy: ".").last
        
        if navigationController != nil {
            leftItem = UIBarButtonItem.init(title: "Disconnect",
                                                style: UIBarButtonItem.Style.plain,
                                                target: self,
                                                action: #selector(self.onDisconnectItem(_:)))
            leftItem?.tintColor = UIColor.orange
            navigationItem.leftBarButtonItem = leftItem
        }
        
        
        cellTypes = [CellType.CurrentTemperature,
                     CellType.TargetTemperature,
                     CellType.SlideControl,
                     CellType.HeatOnOff,
                     CellType.NtcState,
                     CellType.QcState,
                     CellType.PwmState,
                     CellType.Voltage]
        
        setupViews()
        setupLayout()
        
        SMHeaterManager.defaultManager.delegate.add(self)
        tableView.reloadData()
    
        if SMHeaterManager.defaultManager.curDevice?.isConnected ?? false {
            SMHeaterManager.defaultManager.curDevice?.setHeatingState(true, completion: nil)
        }
    }
    
    deinit {
        BLELog(self.className() +  " deinit")
        SMHeaterManager.defaultManager.delegate.remove(self)
    }
    
    override func setupViews() {
        view.addSubview(tableView)
        
        print("Setup Cells...")
        let tCells:NSMutableArray = NSMutableArray.init(capacity: cellTypes!.count)
        for type in cellTypes ?? [] {
            switch type {
            case .CurrentTemperature:
                let cell = genCommonCell()
                cell.textLabel?.text = "Current Temperature:"
                cell.detailTextLabel?.text = "- -"
                tCells.add(cell)
                
            case .TargetTemperature:
                let cell = genCommonCell()
                cell.textLabel?.text = "Target Temperature:"
                cell.detailTextLabel?.text = "- -"
                tCells.add(cell)
                
            case .SlideControl:
                let cell = genCommonCell()
                cell.textLabel?.text = "Slide to set target temperature:\n"
                slider.minimumValue = Float(TEMPERATURE_MIN)
                slider.maximumValue = Float(TEMPERATURE_MAX)
                slider.isContinuous = true
                slider.addTarget(self, action: #selector(self.sliderValueDidChanged(_:)),
                                 for: UIControl.Event.valueChanged)
                slider.addTarget(self, action: #selector(self.sliderTouchUp(_:)),
                                 for: [UIControl.Event.touchUpInside, UIControl.Event.touchUpInside])
                cell.contentView.addSubview(slider)
                slider.snp.makeConstraints { (make) -> Void in
                    make.leading.equalToSuperview().offset(32)
                    make.trailing.equalToSuperview().offset(-32)
                    make.height.equalTo(50)
                    make.bottom.equalToSuperview().offset(-16)
                }
                tCells.add(cell)
                
            case .HeatOnOff:
                let cell = genCommonCell()
                cell.textLabel?.text = "Tap to trigger On/Off"
                onOffControl.addTarget(self, action: #selector(self.switchValueDidChanged(_:)), for: UIControl.Event.valueChanged)
                cell.contentView.addSubview(onOffControl)
                onOffControl.snp.makeConstraints { (make) -> Void in
                    make.right.equalToSuperview().offset(-32)
                    make.centerY.equalToSuperview()
                    //                    make.width.equalTo(120)
                    //                    make.height.equalTo(50)
                }
                
                tCells.add(cell)
            case .NtcState:
                let cell = genCommonCell()
                cell.textLabel?.text = "NTC State"
                cell.detailTextLabel?.text = "- -"
                tCells.add(cell)
            case .QcState:
                let cell = genCommonCell()
                cell.textLabel?.text = "QC State"
                cell.detailTextLabel?.text = "- -"
                tCells.add(cell)
            case .PwmState:
                let cell = genCommonCell()
                cell.textLabel?.text = "PWM State"
                cell.detailTextLabel?.text = "- -"
                tCells.add(cell)
            case .Voltage:
                let cell = genCommonCell()
                cell.textLabel?.text = "Voltage Value(mV)"
                cell.detailTextLabel?.text = "- -"
                tCells.add(cell)
            }
        }
        cells = tCells as? [UITableViewCell]
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
    
    @objc func sliderValueDidChanged(_ slider: UISlider) {
        let value = Int(slider.value)
        print("sliderValueDidChanged >>> \(value)")
        let targetCell = cells![CellType.TargetTemperature.rawValue]
        targetCell.detailTextLabel?.text = String.init(format: "%d", value)
    }
    
    @objc func sliderTouchUp(_ slider: UISlider) {
        let value = Int(slider.value)
        print("sliderTouchUp >>> \(value)")
        let targetCell = cells![CellType.TargetTemperature.rawValue]
        targetCell.detailTextLabel?.text = String.init(format: "%d", value)
        
        SMHeaterManager.defaultManager.curDevice?.setTargetTemperature(UInt8(value), completion: nil)
    }
    
    @objc func switchValueDidChanged(_ switchControl: UISwitch) {
        print("trigger state >>> \(switchControl.isOn)")
        
        if SMHeaterManager.defaultManager.curDevice?.isHeating != switchControl.isOn {
            SMHeaterManager.defaultManager.curDevice?.setHeatingState(switchControl.isOn, completion: nil)
        }
    }
    
    func genCommonCell() -> UITableViewCell {
        let cell = UITableViewCell.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "CommonCell")
        cell.backgroundColor = BG_COLOR
        cell.textLabel?.textColor = TITLE_COLOR
        cell.detailTextLabel?.textColor = TITLE_COLOR
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 30)
        cell.detailTextLabel?.textAlignment = .center
        return cell
    }
    // MARK: - OnEvent
    @objc func onDisconnectItem(_ sender: NSObject) {
        
        self.showSystemAlert(self, "Alert", "Do you want to disconnect current device?", "Cancel", cancelHandler: nil, okTitle: "Disconnect") {
            SMHeaterManager.defaultManager.disconnectCurrentDevice()
            self.dismiss(animated: true) {
                
            }
        }
    }
    // MARK: - Custom Delegate
    // MARK: - SMHeaterManagerDelegate
    func didConnectedDevice(bleDevice: SMHeater?, error: Error?) {
        hideHUD()
    }
    
    func didDisconnectedDevice(error: Error?) {
        if error != nil {
            print("Device did disconnect with error \(String(describing: error))")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func deviceValueDidChange(bleDevice: SMHeater) {
        tableView.reloadData()
    }
    
    func deviceBeginReconnect(bleDevice: SMHeater) {
        showWaitting("Reconnecting...")
    }
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTypes?.count ?? 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == CellType.SlideControl.rawValue ? 100: 50
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cells?[indexPath.row] ?? UITableViewCell()
        switch CellType(rawValue: indexPath.row) {
        case .CurrentTemperature:
            cell.detailTextLabel?.text = {
                if let v = SMHeaterManager.defaultManager.curDevice?.currentTemperature {
                    return String(v)
                }else {
                    return "- -"
                }
            }()
        case .TargetTemperature:
            cell.detailTextLabel?.text = {
                if let v = SMHeaterManager.defaultManager.curDevice?.tartgetTemperature {
                    return String(v)
                }else {
                    return "- -"
                }
            }()
        case .SlideControl:
            slider.value = Float(SMHeaterManager.defaultManager.curDevice?.tartgetTemperature ?? 0)
            
        case .HeatOnOff:
            onOffControl.isOn = SMHeaterManager.defaultManager.curDevice?.isHeating ?? false
            
        case .NtcState:
            cell.detailTextLabel?.text = SMHeaterManager.defaultManager.curDevice?.ntcState.toString()
            
        case .QcState:
            cell.detailTextLabel?.text = SMHeaterManager.defaultManager.curDevice?.qcState.toString()
1
        case .PwmState:
            cell.detailTextLabel?.text = SMHeaterManager.defaultManager.curDevice?.pwm.toString()
            
        case .Voltage:
            cell.detailTextLabel?.text = SMHeaterManager.defaultManager.curDevice?.milVoltage.toString() ?? "0" + "mV"
            
        default: break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // MARK: - Setter
    
    // MARK: - Getter
    lazy var tableView: GLBaseTableView = {
        let tb = GLBaseTableView()
        tb.delegate = self
        tb.dataSource = self
        return tb
    }()
}

extension Int {
    func toString() -> String {
        return String(self)
    }
}
