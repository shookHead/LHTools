//
//  BMTimeIntervalPicker.swift
//  wenzhuan
//
//  Created by zbkj on 2020/6/1.
//  Copyright © 2020 baymax. All rights reserved.
//

import UIKit

///   必须全局持有 否则点击事件
///   pick = BMTimeIntervalPicker.share()
///   pick.startTime = Date()
///   pick.endTime = Date()
///   pick setCallBack{ ... }
///   pick.show()


open class BMTimeIntervalPicker: UIView {

    // MARK: -  ---------------------- public ------------------------

    open var startTime: Date!
    open var endTime: Date!

    var resultCallBack:((BMTimeIntervalPicker)->(Bool))!
    
    // MARK: -  ---------------------- Setting ------------------------
    static var tintColor = UIColor.red
    static var textColor = #colorLiteral(red: 0.3261618912, green: 0.354550004, blue: 0.4875296354, alpha: 1)
    static var textGrayColor = #colorLiteral(red: 0.6980346441, green: 0.6981537342, blue: 0.6980189681, alpha: 1)

    // MARK: -  ---------------------- private ------------------------
    var currentBtnTag: Int!
    
    var _maskView: UIButton!
    
    var _whiteView: UIView!

    var _startBtn: UIButton!
    var _startDescLab: UILabel!
    var _startTimeLab: UILabel!
    
    var _endBtn: UIButton!
    var _endDescLab: UILabel!
    var _endTimeLab: UILabel!

    var pickerView: UIPickerView!
    var componentsArray: Array<Array<String>>!
    var dateFormateArr: Array<String>!
    var selectedIndexArr:  Array<Int>!

    var cancelBtn: UIButton!
    var commitBtn: UIButton!

    
    public static func share() -> BMTimeIntervalPicker{
        let v = BMTimeIntervalPicker(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
        v.initView()
        return v
    }
    
    open func initView(){
        _maskView = UIButton(frame: UIScreen.main.bounds)
        _maskView.addTarget(self, action: #selector(hidden), for: .touchUpInside)
        _maskView.backgroundColor = .black
        _maskView.alpha = 0.6
        self.addSubview(_maskView)
        
        _whiteView = UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 300))
        _whiteView.backgroundColor = .white
        self.addSubview(_whiteView)
        
        // ---- start Time ----
        _startBtn = UIButton(frame: CGRect(x: 0, y: 0, width: KScreenWidth/2, height: 70))
        _startBtn.tag = 1
        _startBtn.addTarget(self, action: #selector(chooseDateAction(_:)), for: .touchUpInside)
        
        _startDescLab = UILabel(frame: CGRect(x: 0, y: 20, width: KScreenWidth/2, height: 20))
        _startDescLab.text = lhStartDate
        _startDescLab.font = UIFont.systemFont(ofSize: 15)
        _startDescLab.textAlignment = .center
        _whiteView.addSubview(_startDescLab)
        
        _startTimeLab = UILabel(frame: CGRect(x: _startDescLab.x, y: _startDescLab.frame.maxY+4, width: _startDescLab.w, height: 21))
        _startTimeLab.text = ""
        _startTimeLab.font = UIFont.init(name: "ArialMT", size: 17)
        _startTimeLab.textAlignment = .center
        _whiteView.addSubview(_startTimeLab)
        
        _whiteView.addSubview(_startBtn)

        // ---- end Time ----
        _endBtn = UIButton(frame: CGRect(x: KScreenWidth/2, y: 0, width: KScreenWidth/2, height: 70))
        _endBtn.tag = 2
        _endBtn.addTarget(self, action: #selector(chooseDateAction(_:)), for: .touchUpInside)
        
        _endDescLab = UILabel(frame: CGRect(x: KScreenWidth/2, y: _startDescLab.y, width: _startDescLab.w, height: _startDescLab.h))
        _endDescLab.text = lhEndDate
        _endDescLab.font = _startDescLab.font
        _endDescLab.textAlignment = .center
        _whiteView.addSubview(_endDescLab)
        
        _endTimeLab = UILabel(frame: CGRect(x: KScreenWidth/2, y: _startTimeLab.y, width: _startDescLab.w, height: _startTimeLab.h))
        _endTimeLab.text = ""
        _endTimeLab.font = _startTimeLab.font
        _endTimeLab.textAlignment = .center
        _whiteView.addSubview(_endTimeLab)
        
        _whiteView.addSubview(_endBtn)
        
        let line = UIView(frame: CGRect(x: KScreenWidth/2 - 1, y: _startDescLab.y, width: 1, height: _startTimeLab.maxY -  _startDescLab.y))
        line.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        _whiteView.addSubview(line)
        
        // ---- 时间选择 ----
        pickerView = UIPickerView(frame: CGRect(x: KScreenWidth/10, y: _endTimeLab.maxY + 4, width: KScreenWidth / 5 * 4, height: 150))
        pickerView.backgroundColor = .clear
        pickerView.delegate = self
        pickerView.dataSource = self
        _whiteView.addSubview(pickerView)
        
//        var temp1 =
//        var temp2 =
//        var temp3 =
        componentsArray = [self.getArr(2016, 2099), self.getArr(1, 12), self.getArr(1, 31)]
        dateFormateArr = ["yyyy", "MM", "dd"]
        selectedIndexArr = [0,0,0,0]

        currentBtnTag = 1
        
        // ------  确认取消按钮  ------
        cancelBtn = UIButton(frame: CGRect(x: 0, y: pickerView.maxY + 4, width: KScreenWidth / 2, height: 50))
        cancelBtn.setTitle(lhCancle, for: .normal)
        cancelBtn.titleLabel?.font = .boldSystemFont(ofSize: 17)
        cancelBtn.setTitleColor(BMTimeIntervalPicker.textGrayColor, for: .normal)
        cancelBtn.addTarget(self, action: #selector(hidden), for: .touchUpInside)
        _whiteView.addSubview(cancelBtn)
        
        commitBtn = UIButton(frame: CGRect(x: KScreenWidth/2, y: cancelBtn.y, width: KScreenWidth/2, height: cancelBtn.h))
        commitBtn.setTitle(lhDetermine, for: .normal)
        commitBtn.titleLabel?.font = .boldSystemFont(ofSize: 17)
        commitBtn.setTitleColor(.white, for: .normal)
        commitBtn.addTarget(self, action: #selector(choose), for: .touchUpInside)
        
        let blueBG = UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth/2 - 60, height: 40))
        blueBG.backgroundColor = BMTimeIntervalPicker.tintColor
        blueBG.center = commitBtn.center
        blueBG.layer.cornerRadius = 10
        blueBG.layer.masksToBounds = true
        
        _whiteView.addSubview(blueBG)
        _whiteView.addSubview(commitBtn)

        if KIsIphoneX {
            _whiteView.h = commitBtn.maxY + KTabBarH
        }else{
            _whiteView.h = commitBtn.maxY + 20
        }
    }
    
    @objc open func hidden() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    open func show() {
        self.chooseDateAction(_startBtn)
        self.alpha = 0
        UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.addSubview(self)
        _whiteView.y = KScreenHeight
        
        self.setStartTime(startTime)
        self.setEndTime(endTime)
        
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
            self._whiteView.y = KScreenHeight - self._whiteView.h
        }
    }
    
    @objc open func choose() {
        if self.endTime.timeIntervalSince(self.startTime) < 0{
            Hud.showText(lhDateError)
            return
        }
        
        if self.resultCallBack != nil{
            let hide = self.resultCallBack(self)
            if hide {
                self.hidden()
                self.resultCallBack = nil
            }
        }
    }
    
    open func setCallBack(_ callBack:@escaping (BMTimeIntervalPicker)->(Bool)){
        self.resultCallBack = callBack
    }

    @objc open func chooseDateAction(_ btn:UIButton) {
        currentBtnTag = btn.tag
        if (btn.tag == 1){
            _startDescLab.textColor = BMTimeIntervalPicker.tintColor
            _startTimeLab.textColor = BMTimeIntervalPicker.textColor
            _endDescLab.textColor = BMTimeIntervalPicker.textGrayColor
            _endTimeLab.textColor = BMTimeIntervalPicker.textGrayColor
            self.setDate(startTime)
        }else{
            _startDescLab.textColor = BMTimeIntervalPicker.textGrayColor
            _startTimeLab.textColor = BMTimeIntervalPicker.textGrayColor
            _endDescLab.textColor = BMTimeIntervalPicker.tintColor
            _endTimeLab.textColor = BMTimeIntervalPicker.textColor
            self.setDate(endTime)
        }
    }
}


/// -------- UIPickerView --------
extension BMTimeIntervalPicker :UIPickerViewDelegate , UIPickerViewDataSource{
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return componentsArray.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let rows = componentsArray[component].count
        let type:String = dateFormateArr[component]
        if type == "dd"{
            let year = componentsArray[0][selectedIndexArr[0]]
            let month = componentsArray[1][selectedIndexArr[1]]
            return self.numberOfDays(month.toInt(), year.toInt())
        }
        return rows
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 32
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let arr = componentsArray[component]
        let temp = [lhYear,lhMonth,lhDay,lhDrop,lhDivide]
        let res = String(format: "%@%@", arr[row], temp[component])
        return res
    }
    
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let w1: CGFloat = 4.5
        let w2: CGFloat = 4
        let unit = pickerView.w / (w1 + 2 * w2)
        if (component == 0){
            return w1 * unit
        }else{
            return w2 * unit
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var lab = view as? UILabel
        if lab == nil{
            lab = UILabel()
            lab?.textAlignment = .center
            lab?.adjustsFontSizeToFitWidth = true
            lab?.backgroundColor = .clear
            lab?.textColor = BMTimeIntervalPicker.textColor
            lab?.font = .boldSystemFont(ofSize: 18)
        }
        lab?.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
        return lab!
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndexArr[component] = row
        let type = dateFormateArr[component]
        if (type == "MM") || type == "yyyy"{
            //有年月的话， 日肯定是第三列
            let selectedDay = selectedIndexArr[2] + 1
            let year = componentsArray[0][selectedIndexArr[0]]
            let month = componentsArray[1][selectedIndexArr[1]]
            let maxDay = self.numberOfDays(month.toInt(), year.toInt())
            if (selectedDay > maxDay) {
                selectedIndexArr[2] = maxDay-1
            }
            pickerView.reloadComponent(2)
        }
        
        var result = ""
        var formate = ""
        for i in 0 ..< componentsArray.count{
            let index = selectedIndexArr[i]
            result = result + componentsArray[i][index]
            formate = formate + dateFormateArr[i]
        }
        let choose = self.getDate(result, formate)
        if (currentBtnTag == 1){
            self.startTime = choose
            _startTimeLab.text = choose?.toString("yyyy-MM-dd")
        }else{
            self.endTime = choose
            _endTimeLab.text = choose?.toString("yyyy-MM-dd")
        }
    }

}


// MARK: -  ---------------------- Utils ------------------------
extension BMTimeIntervalPicker{
    public func setStartTime(_ startTime:Date){
        self.startTime = startTime
        let formate = DateFormatter()
        formate.dateFormat = "yyyy.MM.dd"
        _startTimeLab.text = formate.string(from: startTime)
    }
    
    public func setEndTime(_ endTime:Date){
        self.endTime = endTime
        let formate = DateFormatter()
        formate.dateFormat = "yyyy.MM.dd"
        _endTimeLab.text = formate.string(from: endTime)
    }
    
    public func setDate(_ date:Date) {
        for i in 0 ..< componentsArray.count{
            let formate = dateFormateArr[i]
            let str = self.getDateString(date, formate)
            let dateArr = componentsArray[i]
            for j in 0 ..< dateArr.count {
                if str.toInt() == dateArr[j].toInt(){
                    selectedIndexArr[i] = j
                    pickerView.selectRow(j, inComponent: i, animated: true)
                    break
                }
            }
        }
    }
    
    public func getArr(_ min:Int, _ max:Int) -> Array<String>{
        var temp: Array<String> = []
        for i in min ... max {
            var str = i.toString()
            if max < 100{
                str = String(format: "%02d", i)
            }
            temp.append(str!)
        }
        return temp
    }
    
    public func getDateString(_ date:Date, _ formateStr:String) -> String{
        return date.toString(formateStr)
    }
    
    public func getDate(_ string:String, _ formateStr:String) -> Date?{
        return string.toDate(formateStr)
    }
    
    public func numberOfDays(_ month:Int , _ year:Int) -> Int{
        let temp = [31,29,31,30,31,30,31,31,30,31,30,31]
        if month == 2{
            if ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0){
                return 29
            }else{
                return 28
            }
        }else{
            return temp[month - 1]
        }
    }
    
}



