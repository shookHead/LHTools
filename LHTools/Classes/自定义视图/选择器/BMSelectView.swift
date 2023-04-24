//
//  BMSelectView.swift
//  QianRuChao
//
//  Created by 蔡林海 on 2019/12/30.
//  Copyright © 2019 蔡林海. All rights reserved.
//

import UIKit
@objc public protocol BMSelectViewDelegate {
    ///点击了哪个
    func bmSelectViewDidSelected(index:Int)
    ///消失
    @objc optional func bmSelectViewDisMiss()
}
public class BMSelectView: UIView {
    open var delegate:BMSelectViewDelegate?
//    var title = ""
    let tableViewHeadH:CGFloat = 55
    let tableViewW = UIScreen.main.bounds.size.width*0.7
    let tableViewCellH:CGFloat = 50
    var table:UITableView = {
        let tab = UITableView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: KHeightInNav), style: .grouped)
//        tab.delegate = self
//        tab.dataSource = self
//        tab.register(GoodsSpecCell.nib, forCellReuseIdentifier: "cell2")
        tab.estimatedRowHeight = 100
        tab.estimatedSectionHeaderHeight = 0
        tab.estimatedSectionFooterHeight = 0
        tab.separatorStyle = .none
        tab.layer.cornerRadius = 5
        tab.layer.masksToBounds = true
        tab.showsHorizontalScrollIndicator = false
        tab.showsVerticalScrollIndicator = false
//        tab.bounces = false
        if #available(iOS 11.0, *) {
            tab.contentInsetAdjustmentBehavior = .never
        }else{
//            self.automaticallyAdjustsScrollViewInsets = NO
        }
        return tab
    }()
    open var titleLable:UILabel = {
        let lab = UILabel()
        lab.textAlignment = NSTextAlignment.center
        lab.textColor = UIColor.KBlue
        lab.backgroundColor = UIColor.rgb(244, 244, 244)
        return lab
    }()
    var dataArray = Array<Any>()
    var index = 0
    var key  = ""
    override init(frame: CGRect) {
        super.init(frame: frame)
        table.delegate = self
        table.dataSource = self
        let color = UIColor.black
        backgroundColor = color.alpha(0.4)
        titleLable.text = lhPleaseSelect
        titleLable.frame = CGRect(x: 0, y: 0, width: tableViewW, height: tableViewHeadH)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hide))
        self.addGestureRecognizer(tap)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    public func showWithData(arr:Array<Any>,key1:String,title:String,selectedId1:Int) {
        dataArray = arr
        self.key = key1
        self.index = selectedId1
        titleLable.text = title
        alpha = 0
        frame = CGRect(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight)
        UIApplication.shared.windows.filter({$0.isKeyWindow}).first!.addSubview(self)
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
        table.frame = CGRect(x: (KScreenWidth-tableViewW)/2, y: KScreenHeight/2-tableViewHeadH-tableViewCellH, width: tableViewW, height: tableViewHeadH+tableViewCellH)
        table.reloadData()
        table.alpha = 0.6
        UIApplication.shared.windows.filter({$0.isKeyWindow}).first!.addSubview(table)
        UIView.animate(withDuration: 0.25) {
            let maxH:CGFloat = 255
            var high = self.tableViewHeadH + self.tableViewCellH*CGFloat(self.dataArray.count)
            if high > maxH{
                high = maxH
            }
            self.table.alpha = 1
            self.table.frame = CGRect(x: (KScreenWidth-self.tableViewW)/2, y: (KScreenHeight-high)/2-KScreenHeight*0.05, width: self.tableViewW, height: high)
        }
    }
    @objc func hide()  {
     
        delegate?.bmSelectViewDisMiss?() 
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
            self.table.alpha = 0
        }) { (_) in
            self.table.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
    
}
extension BMSelectView:UITableViewDelegate,UITableViewDataSource{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellid = "testCellID1"
        let desLab = UILabel()
        var cell = tableView.dequeueReusableCell(withIdentifier: cellid)
        if cell==nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellid)
            desLab.font = UIFont.systemFont(ofSize: 15)
            cell?.addSubview(desLab)
            desLab.textAlignment = .right
        }
        let tag = 1001
        var lab = cell?.viewWithTag(tag) as? UILabel
        if lab == nil {
            lab = UILabel()
            lab?.frame = CGRect(x: 0, y: 0, width: tableViewW, height: 50)
            lab?.textAlignment = .center
            lab?.textColor = UIColor.rgb(88, 88, 88)
            lab?.tag = tag
            let line = UIView()
            line.frame = CGRect(x: 0, y: 0, width: lab!.w, height: 0.5)
            line.backgroundColor = UIColor.rgb(245, 245, 245)
            lab?.addSubview(line)
            cell?.addSubview(lab!)
        }
        let obj = dataArray[indexPath.row]
        var str = ""
        if obj is String{
            str = obj as! String
        }else if obj is Dictionary<String, Any>{
            let dic = obj as! Dictionary<String, Any>
            str = dic[self.key] as! String
        }else{
//            str = obj.
        }
        
        lab?.text = str
        if index == indexPath.row{
            lab?.textColor = .KOrange
        }else{
            lab?.textColor = .KTextBlack
        }
        cell?.selectionStyle = .none
        return cell!
    }
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return titleLable
    }
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableViewHeadH
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewCellH
    }
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.bmSelectViewDidSelected(index: indexPath.row)
        table.removeFromSuperview()
        self.removeFromSuperview()
    }
    
}
