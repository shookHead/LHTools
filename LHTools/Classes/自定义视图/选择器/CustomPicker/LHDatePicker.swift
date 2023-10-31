//
//  LHDatePicker.swift
//  LHTools
//
//  Created by clh on 2022/4/20.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit



open class LHDatePicker: BMBasePicker {
    public var endTime:Date?
    public var startTime:Date?
    public var showInfinit : Bool = false
    public var infinitText = lhPermanent
    
    public var infinitBtn : UIButton?
    //当前时间
    public var date:Date{
        get{
            var result = ""
            var formate = ""
            for i in 0..<componentsArray.count{
                let index = selectedIndexArr[i]
                result.append(componentsArray[i][index])
                formate.append(dateFormateArr[i])
            }
            return result.toDate(formate)!
        }
        set{
            for i in 0..<componentsArray.count {
                let formate = dateFormateArr[i]
                let str = newValue.toString(formate)
                let dateArr = componentsArray[i]
                for j in 0..<dateArr.count{
                    if str == dateArr[j]{
                        selectedIndexArr[i] = j
                        self.pickerView.selectRow(j, inComponent: i, animated: YES)
                    }
                }
            }
        }
    }
    
    //默认 .ymd
    public var datePickMode:BMDatePickerMode = .ymd{
        didSet {
            componentsArray = Array()
            dateFormateArr = Array()
            selectedIndexArr = Array()

            if datePickMode.contain(.year) {
                let temp = Array(1900...2099).map { String(format: "%04d", $0)}
                componentsArray.append(temp)
                dateFormateArr.append("yyyy")
                selectedIndexArr.append(0)
            }
            if datePickMode.contain(.month) {
                let temp = Array(1...12).map { String(format: "%02d", $0)}
                componentsArray.append(temp)
                dateFormateArr.append("MM")
                selectedIndexArr.append(0)
            }
            if datePickMode.contain(.day) {
                let temp = Array(1...31).map { String(format: "%02d", $0)}
                componentsArray.append(temp)
                dateFormateArr.append("dd")
                selectedIndexArr.append(0)
            }
            if datePickMode.contain(.hour) {
                let temp = Array(0...23).map { String(format: "%02d", $0)}
                componentsArray.append(temp)
                dateFormateArr.append("HH")
                selectedIndexArr.append(0)
            }
            if datePickMode.contain(.minute) {
                let temp = Array(0...59).map { String(format: "%02d", $0)}
                componentsArray.append(temp)
                dateFormateArr.append("mm")
                selectedIndexArr.append(0)
            }
            if datePickMode.contain(.second) {
                let temp = Array(0...59).map { String(format: "%02d", $0)}
                componentsArray.append(temp)
                dateFormateArr.append("ss")
                selectedIndexArr.append(0)
            }
        }
    }

    public var selected: ((_:Date?)->())
    
    private var componentsArray:Array<Array<String>> = Array()
    
    private var dateFormateArr:Array<String> = Array()
    
    private var selectedIndexArr:Array<Int> = Array()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "    " + lhSelectDateTime
        lab.backgroundColor = UIColor.hex("#F8FAFB")
        lab.font = UIFont.boldSystemFont(ofSize: 18)
        return lab
    }()
    lazy var cancleBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle(lhCancle, for: .normal)
        btn.setTitleColor(UIColor.hex("#C0C0C1"), for: .normal)
        btn.titleLabel?.font    = UIFont.systemFont(ofSize: 16)
        return btn
    }()
    public init(_ selected:@escaping (_ time:Date?) -> () ) {
        self.datePickMode = .ymd
        self.selected = selected
        super.init()
        self.bgLab.font = UIFont.boldSystemFont(ofSize: 60)
        self.setContentH(325,contentY: 100)
        contentView.addSubview(titleLab)
        contentView.addSubview(cancleBtn)
        cancleBtn.addTarget(self, action: #selector(cancleBtnAction), for: .touchUpInside)
    }
    required public init?(coder aDecoder: NSCoder) {   fatalError("init(coder:) has not been implemented") }
    open override func layoutSubviews() {
        super.layoutSubviews()
        contentView.w = 472
        contentView.x = (KScreenWidth - contentView.w) / 2
        let btnW:CGFloat = 80
        titleLab.frame = CGRect(x: 0, y: 0, width: contentView.w, height: 66)
        confirmBtn.x = contentView.w - btnW - 12
        confirmBtn.w = btnW
        confirmBtn.backgroundColor = .white
        confirmBtn.setTitleColor(UIColor.hex("#4FA075"), for: .normal)
        cancleBtn.frame = CGRect(x: confirmBtn.x - 8 - btnW, y: confirmBtn.y, width: btnW, height: confirmBtn.h)
        pickerView.frame    = CGRect(x: 0, y: titleLab.maxY, width: contentView.frame.size.width, height: contentView.frame.size.height-confirmBtn.h-titleLab.maxY)
        
    }
    @objc func cancleBtnAction() {
        super.close()
    }
}

// MARK: - 子类 需要 继承的方法
extension LHDatePicker{

    public override func comfirm() {
        if let d = endTime {
            if d.compare(date) == .orderedAscending {
                Hud.showText(lhTimeSelectionError)
                return
            }
        }
        if let d = startTime {
            if date < d  {
                Hud.showText(lhTimeSelectionError)
                return
            }
        }
        super.comfirm()
        selected(date)
    }
    
    @objc public func comfirmWithInfinit() {
        super.comfirm()
        selected(nil)
    }
    
    public override func close() {
        super.close()
        UIView.animate(withDuration: 0.2, animations: {
            self.infinitBtn?.alpha = 0
            self.infinitBtn?.frame.origin.y = self.contentViewY! + 130 - 44 - 12
        }) { (_) in
        }
    }
    
    /// 显示
    public override func show(){
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
        if showInfinit == true {
            self.infinitBtn = UIButton()
//            let btnW:CGFloat = 80
            self.infinitBtn?.frame = CGRect(x: contentView.frame.width - 24 - 100, y: contentView.frame.origin.y - 44 - 12, width: contentView.frame.width, height: 44)
            self.infinitBtn?.setTitle(infinitText, for: .normal)
            self.infinitBtn?.layer.cornerRadius = 10
            self.infinitBtn?.layer.masksToBounds = true
            self.infinitBtn?.backgroundColor = .white
            self.infinitBtn?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            self.infinitBtn?.addTarget(self, action: #selector(comfirmWithInfinit), for: .touchUpInside)
            self.infinitBtn?.setTitleColor(.KBlue, for: .normal)
            self.addSubview(self.infinitBtn!)
        }

        
        UIView.animate(withDuration: 0.2, animations: {
            self.bgMaskView.alpha = 1
            self.contentView.alpha = 1
            self.contentView.frame.origin.y = self.contentViewY!
            self.infinitBtn?.frame.origin.y = self.contentViewY! - 44 - 12
        })
    }
    

    public override func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return componentsArray.count
    }

    public override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let rows = componentsArray[component].count
        let type = dateFormateArr[component]
        if type == "dd" {//月份特殊处理
            let year = componentsArray[0][selectedIndexArr[0]]
            let month = componentsArray[1][selectedIndexArr[1]]
            return Date.numberOfDays(month: Int(month), year: Int(year))
        }
        return rows
    }
    
    public override func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return rowH
    }
    
    public override func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let arr = componentsArray[component]
        let lab = pickerView.view(forRow: row, forComponent: component) as? UILabel
        lab?.textColor = UIColor.hex("#4FA075")
        if arr.count == 24{
            return "\(arr[row])"
        }
        if arr.count == 60 && (component == 4 || component == 1){
            return "\(arr[row])"
        }
        if arr.count == 60 && (component == 5 || component == 2){
            return "\(arr[row])"
        }
        if component == 0{
            return "\(arr[row])"
        }
        if component == 1{
            return "\(arr[row])"
        }
        return "\(arr[row])"
    }
    
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        var unitCount = componentsArray.count * 3
        if datePickMode.contain(.year) {
            unitCount = unitCount + 2
        }

        let unit = (contentView.w)/CGFloat(unitCount)
        if component == 0 && datePickMode.contain(.year) {
            return 5*unit
        }else{
            return 3*unit
        }
    }

    public override func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndexArr[component] = row
        if datePickMode.contain(.year) {
            bgLab.text = componentsArray[0][selectedIndexArr[0]]
        }
        let type = dateFormateArr[component]
        if type == "yyyy" || type == "MM" {//月份特殊处理
            //有年月的话， 日肯定是第三列
            let selectedDay = selectedIndexArr[2]+1
            let year = componentsArray[0][selectedIndexArr[0]]
            let month = componentsArray[1][selectedIndexArr[1]]
            let maxDay  = Date.numberOfDays(month: Int(month), year: Int(year))
            if selectedDay > maxDay {
                selectedIndexArr[2] = maxDay-1
            }
            pickerView.selectRow(selectedIndexArr[2], inComponent: 2, animated: YES)
        }
    }

    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel
        if pickerLabel == nil{
            pickerLabel = UILabel()
            pickerLabel!.textAlignment = .center
            pickerLabel!.adjustsFontSizeToFitWidth = YES
            pickerLabel!.backgroundColor = .clear
//            pickerLabel!.backgroundColor = UIColor.hex("#4FA075")
            pickerLabel!.font = UIFont.systemFont(ofSize: 24)
        }
        pickerLabel!.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
        return pickerLabel!
    }
}



