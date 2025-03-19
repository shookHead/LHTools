//
//  LHSinglePicker.swift
//  LHTools
//
//  Created by clh on 2021/11/19.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
//import HandyJSON

open class LHSinglePicker<T:HandyJSON>: UIView,UIPickerViewDelegate,UIPickerViewDataSource {
    /// 灰色 透明 背景视图
    public var bgMaskView:UIButton = {
        let btn         = UIButton(type: .custom)
        btn.frame       = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        btn.backgroundColor = .maskView
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
        return btn
    }()
    
    /// 确认按钮
    public var confirmBtn:UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(lhDetermineSpace, for: .normal)
        btn.backgroundColor     = BMBasePicker.tintColor
        btn.titleLabel?.font    = UIFont.systemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(comfirm), for: .touchUpInside)
        return btn
    }()
    
    /// 带确认按钮的 内容 视图
    public var contentView:UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.backgroundColor        = .white
        view.layer.cornerRadius     = 10
        view.layer.masksToBounds    = true
        return view
    }()
    /// 最终显示 位置  在 setContentH 中计算
    public private(set) var contentViewY:CGFloat?

    /// 水印 Lab
    public private(set) var bgLab:UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor.init(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1)
        lab.font = UIFont.systemFont(ofSize: 50)
        lab.text = ""
        lab.adjustsFontSizeToFitWidth = true
        lab.textAlignment = .center
        return lab
    }()
    /// 选择器
    public var pickerView:UIPickerView = {
        let pick = UIPickerView()
        pick.backgroundColor = .clear
        return pick
    }()
    public var rowH:CGFloat = 35
    
    public var dataArray:Array<T>

    public var selectedIndex:Int
    
    public var key = ""

    public var changed: ((_:T)->())?

    public var selected: ((_:T)->())
    
    init(_ dataArray:Array<T>,_ index:Int = 0,_ key:String = "", _ selected:@escaping(_:T)->(), _ changed:((_:T)->())? = nil) {
        self.dataArray = dataArray
        self.selectedIndex = index
        self.selected = selected
        self.changed = changed
        self.key = key
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        backgroundColor = .clear

        pickerView.delegate = self
        pickerView.dataSource = self
        //内容高度
        setContentH(240)
        addSubview(bgMaskView)
        addSubview(contentView)

        contentView.addSubview(confirmBtn)
        contentView.addSubview(bgLab)
        contentView.addSubview(pickerView)
    }
    /// 确认
    @objc public func comfirm(){
        self.close()
        selected(dataArray[selectedIndex])
    }
    /// 关闭
    @objc public func close(){
        UIView.animate(withDuration: 0.2, animations: {
            self.bgMaskView.alpha = 0
            self.contentView.alpha = 0
            self.contentView.frame.origin.y = self.contentViewY! + 130
        }) { (_) in
            self.removeFromSuperview()
        }
    }

    required public init?(coder aDecoder: NSCoder) {   fatalError("init(coder:) has not been implemented") }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArray.count
    }
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return rowH
    }
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let arr = dataArray.toJSON()
        var pick_name = ""
        if let dic = arr[row] {
            if let name = dic[key] as? String {
                pick_name = name
            }
        }
        return pick_name
    }
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let arr = dataArray.toJSON()
        var pick_name = ""
        if let dic = arr[row] {
            if let name = dic[key] as? String {
                pick_name = name
                changed?(dataArray[row])
            }
        }
        self.bgLab.text = pick_name
        self.selectedIndex = row
    }
}


// MARK: - 重写的方法
extension LHSinglePicker{
    /// 内容高度（其他控件跟着调节）
    ///
    /// - Parameter high: 下方内容高度
    public func setContentH(_ high:CGFloat){
        contentViewY = UIScreen.main.bounds.height - high - 15
        contentViewY = KIsIphoneX ? contentViewY! - 34 : contentViewY!
        let leftBlock:CGFloat   = 10.0 // 选择器 距左 宽度
        let comfirmBtnH:CGFloat = 44 //确认按钮 高度
        contentView.frame   = CGRect(x: leftBlock, y: contentViewY!, width: UIScreen.main.bounds.width-leftBlock*2, height: high)
        confirmBtn.frame    = CGRect(x: 0, y: high - comfirmBtnH, width: contentView.frame.size.width, height: comfirmBtnH)
        bgLab.frame         = CGRect(x: 15, y: 0, width: contentView.frame.size.width-30, height: contentView.frame.size.height-comfirmBtnH)
        pickerView.frame    = CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: contentView.frame.size.height-comfirmBtnH)
    }
    /// 显示
    public func show(){
        let w = UIApplication.shared.windows.filter({$0.isKeyWindow}).first
        w?.addSubview(self)
        
        bgMaskView.alpha = 0
        self.contentView.alpha = 0
        contentView.frame.origin.y = contentViewY! + 130
        if #available(iOS 14.0, *){
            if let v = pickerView.subviews.bm_object(1){
                v.backgroundColor = .clear
            }
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.bgMaskView.alpha = 1
            self.contentView.alpha = 1
            self.contentView.frame.origin.y = self.contentViewY!
            self.pickerView.selectRow(self.selectedIndex, inComponent: 0, animated: false)
            self.pickerView(self.pickerView, didSelectRow: self.selectedIndex, inComponent: 0)
        })
    }

    //设置确认回调
    public func setSelectedBock(_ block:@escaping (T)->()) -> Self{
        selected = block
        return self
    }

}
