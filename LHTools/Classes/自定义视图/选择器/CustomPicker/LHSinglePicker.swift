//
//  LHSinglePicker.swift
//  LHTools
//
//  Created by clh on 2021/11/19.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import HandyJSON

public class LHSinglePicker: BMBasePicker {

    public var dataArray:Array<T>

    public var selectedIndex:Int
    
    public var changed: ((_:T)->())?

    public var selected: ((_:T)->())
    
    init(_ dataArray:Array<String>,_ index:Int = 0, _ selected:@escaping(_:Int)->(), _ changed:((_:Int)->())? = nil) {
//        self.dataArray = dataArray
//        self.selectedIndex = index
//        self.selected = selected
//        self.changed = changed
        super.init()
        self.setContentH(240)
        self.rowH = 35
    }
//    init<T>(_ dataArray:Array<T>,_ index:Int = 0, _ selected:@escaping(_:T)->(), _ changed:((_:T)->())? = nil) {
//        self.dataArray = dataArray
//        self.key = key
//        self.selectedIndex = index
//        self.selected = selected
//        self.changed = changed
//        super.init()
//        self.setContentH(240)
//        self.rowH = 35
//    }

    required init?(coder aDecoder: NSCoder) {   fatalError("init(coder:) has not been implemented") }

}


// MARK: - 重写的方法
extension LHSinglePicker{

    public override func comfirm(){
        super.comfirm()
        selected(selectedIndex)
    }
    public override func show() {
        super.show()
        pickerView.reloadAllComponents()
        //显示初始水印
        if bgLab.isHidden == false{
            bgLab.text = dataArray[selectedIndex]
        }
        pickerView.selectRow(selectedIndex, inComponent: 0, animated: false)
    }


    public override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArray.count
    }
    public override func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        if key == nil {
//            return dataArray[row]
//        }
//        let aaa = dataArray[row]
////        aaa.name
//        return dataArray[row]
        if let arr = arr.toJSON(),arr.count > 0 {
            return arr[row]["pick_name"] as! String
        }else{
            return dataArray[row]
        }
    }
    public override func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.bgLab.text = dataArray[row]
        self.selectedIndex = row
        changed?(row)
    }
}





