//
//  DistributionView.swift
//  MaDianCanBusiness
//
//  Created by 蔡林海 on 2021/3/10.
//

import UIKit
import Foundation

@objc protocol DistributionViewDelegate {
    func distributionViewSave(addressProvinceName:String,isModify:Bool,index:Int)
}
class DistributionView: UIView {
    var delegate:DistributionViewDelegate?
    lazy var cancelBtn: UIButton = {
        let cancelBtn = UIButton()
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(#colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1), for: .normal)
        cancelBtn.adjustsImageWhenHighlighted = false
        cancelBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        return cancelBtn
    }()
    lazy var saveBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = #colorLiteral(red: 0.9098230004, green: 0.2470742762, blue: 0.2353024781, alpha: 1)
        btn.setTitle("保存", for: .normal)
        btn.adjustsImageWhenHighlighted = false
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 20
        btn.layer.masksToBounds = true
        return btn
    }()
    var collectionView:CollectionView!
    var dataSource: ArrayDataSource<String>!
    var viewSource: ClosureViewSource<String,UIButton>!
    var provider: BasicProvider<String, UIButton>!
    var btnArr:[UIButton] = []
    var _isModify:Bool!
    var _index:Int!
    init(frame: CGRect,isModify:Bool,index:Int) {
        super.init(frame: frame)
        _isModify = isModify
        _index = index
        setUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUI() {
        backgroundColor = #colorLiteral(red: 0.9607003331, green: 0.9608381391, blue: 0.9606701732, alpha: 1)
        cancelBtn.frame = CGRect(x: 16, y: 0, width: 30, height: 68)
        addSubview(cancelBtn)
        let titleLab = UILabel()
        titleLab.text = "配送区域"
        titleLab.textAlignment = .center
        titleLab.font = UIFont.boldSystemFont(ofSize: 16)
        titleLab.textColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        titleLab.frame = CGRect(x: 100, y: 0, width: KScreenWidth - 100 * 2, height: 68)
        addSubview(titleLab)
        let contentV = UIView()
        contentV.frame = CGRect(x: 0, y: 68, width: self.w, height: self.h - 68)
        contentV.backgroundColor = .white
        addSubview(contentV)
        collectionView = CollectionView(frame: .init(x: 16, y: 16, width: self.w - 16 * 2, height: contentV.h - 40 - 20 - 16 * 2))
        contentV.addSubview(collectionView)
        
        btnArr.removeAll()
        var newStrArr:[String] = []

        dataSource = ArrayDataSource(data: newStrArr)
        viewSource = ClosureViewSource(viewUpdater: { [self] (view: UIButton, data: String, index: Int) in
            view.layer.cornerRadius = 9
            view.layer.masksToBounds = true
            view.setTitle(data, for: .normal)
            view.layer.cornerRadius = 4
            view.layer.masksToBounds = true
            
            let btn = btnArr[index]
            if btn.isSelected{
                view.backgroundColor = #colorLiteral(red: 0.9999395013, green: 0.8902460933, blue: 0.8900922537, alpha: 1)
            }else{
                view.backgroundColor = #colorLiteral(red: 0.9607003331, green: 0.9608381391, blue: 0.9606701732, alpha: 1)
            }
            view.isSelected = btn.isSelected
            view.setTitleColor(#colorLiteral(red: 0.9098230004, green: 0.2470742762, blue: 0.2353024781, alpha: 1), for: .selected)
            view.setTitleColor(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), for: .normal)
            view.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            view.tag = index
            view.addTarget(self, action: #selector(selected(btn:)), for: .touchUpInside)
        })
        // cell尺寸
        let sizeSource = { (index: Int, data: String, collectionSize: CGSize) -> CGSize in
            let w = data.stringWidth(14)
            return CGSize(width: w + 15 * 2, height: 32)
        }
        provider = BasicProvider(dataSource: dataSource, viewSource: viewSource, sizeSource: sizeSource)
        // 布局
        provider.layout = FlowLayout(spacing: 16, justifyContent: .start)
        provider.animator = SimpleAnimator()
        collectionView.provider = provider

        
        saveBtn.frame = CGRect(x: 8, y: contentV.h - 40 - 20, width: KScreenWidth - 8 * 2, height: 40)
        saveBtn.addTarget(self, action: #selector(saveBtnAction), for: .touchUpInside)
        contentV.addSubview(saveBtn)
    }
    
    @objc func saveBtnAction() {
        var s = ""
        for i in 0..<btnArr.count {
            let btn = btnArr[i]
            if btn.isSelected {
                if s.notEmpty {
                    s = s + "," + btn.titleLabel!.text!
                }else{
                    s = btn.titleLabel!.text!
                }
            }
        }
        delegate?.distributionViewSave(addressProvinceName: s,isModify: _isModify,index: _index)
    }
    @objc func selected(btn:UIButton) {
        btn.isSelected = !btn.isSelected
        btnArr[btn.tag] = btn
        if btn.isSelected {
            btn.backgroundColor = #colorLiteral(red: 0.9999395013, green: 0.8902460933, blue: 0.8900922537, alpha: 1)
        }else{
            btn.backgroundColor = #colorLiteral(red: 0.9607003331, green: 0.9608381391, blue: 0.9606701732, alpha: 1)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}
