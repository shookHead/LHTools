//
//  SnapKitExtend
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by charles on 2017/8/2.
//  Copyright © 2017年 charles. All rights reserved.
//
import SnapKit

public enum ConstraintAxis : Int {
    case horizontal
    case vertical
}

#if os(iOS) || os(tvOS)
import UIKit
public typealias ConstraintEdgeInsets = UIEdgeInsets
#else
import AppKit
extension NSEdgeInsets {
    public static let zero = NSEdgeInsetsZero
}
public typealias ConstraintEdgeInsets = NSEdgeInsets


#endif

public struct ConstraintArrayDSL {
    @discardableResult
    public func prepareConstraints(_ closure: (_ make: ConstraintMaker) -> Void) -> [Constraint] {
        var constraints = Array<Constraint>()
        for view in self.array {
            constraints.append(contentsOf: view.snp.prepareConstraints(closure))
        }
        return constraints
    }
    
    public func makeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        for view in self.array {
            view.snp.makeConstraints(closure)
        }
    }
    
    public func remakeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        for view in self.array {
            view.snp.remakeConstraints(closure)
        }
    }
    
    public func updateConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        for view in self.array {
            view.snp.updateConstraints(closure)
        }
    }
    
    public func removeConstraints() {
        for view in self.array {
            view.snp.removeConstraints()
        }
    }
    /// 等间距布局
    /// horizontal 水平的需要设置y跟高度
    /// vertical 垂直的需要设置x跟宽度
    /// - Parameters:
    ///   - axisType: 方向
    ///   - fixedSpacing: 中间间距
    ///   - leadSpacing: 左边距(上边距)
    ///   - tailSpacing: 右边距(下边距)
    public func distributeViewsAlong(axisType:ConstraintAxis, fixedSpacing:CGFloat = 0, leadSpacing:CGFloat = 0, tailSpacing:CGFloat = 0) {
        
        guard self.array.count > 1, let tempSuperView = commonSuperviewOfViews() else {
            return
        }
        
        if axisType == .horizontal {
            var prev : ConstraintView?
            for (i, v) in self.array.enumerated() {
                v.snp.makeConstraints({ (make) in
                    guard let prev = prev else {//first one
                        make.left.equalTo(tempSuperView).offset(leadSpacing)
                        return
                    }
                    make.width.equalTo(prev)
                    make.left.equalTo(prev.snp.right).offset(fixedSpacing)
                    if (i == self.array.count - 1) {//last one
                        make.right.equalTo(tempSuperView).offset(-tailSpacing)
                    }
                })
                prev = v;
            }
        }else {
            var prev : ConstraintView?
            for (i, v) in self.array.enumerated() {
                v.snp.makeConstraints({ (make) in
                    guard let prev = prev else {//first one
                        make.top.equalTo(tempSuperView).offset(leadSpacing);
                        return
                    }
                    make.height.equalTo(prev)
                    make.top.equalTo(prev.snp.bottom).offset(fixedSpacing)
                    if (i == self.array.count - 1) {//last one
                        make.bottom.equalTo(tempSuperView).offset(-tailSpacing);
                    }
                })
                prev = v;
            }
        }
    }
    
    /// 等大小布局
    /// vertical 垂直的还需要设置x跟宽度
    /// horizontal 水平的还需要设置y跟高度
    /// - Parameters:
    ///   - axisType: 方向
    ///   - fixedItemLength: item对应方向的宽或者高
    ///   - leadSpacing: 左边距(上边距)
    ///   - tailSpacing: 右边距(下边距)
    public func distributeViewsAlong(axisType:ConstraintAxis, fixedItemLength:CGFloat = 0, leadSpacing:CGFloat = 0, tailSpacing:CGFloat = 0) {
        
        guard self.array.count > 1, let tempSuperView = commonSuperviewOfViews() else {
            return
        }
        
        if axisType == .horizontal {
            var prev : ConstraintView?
            for (i, v) in self.array.enumerated() {
                v.snp.makeConstraints({ (make) in
                    make.width.equalTo(fixedItemLength)
                    if prev != nil {
                        if (i == self.array.count - 1) {//last one
                            make.right.equalTo(tempSuperView).offset(-tailSpacing);
                        } else {
                            let offset = (CGFloat(1) - (CGFloat(i) / CGFloat(self.array.count - 1))) *
                                (fixedItemLength + leadSpacing) -
                                CGFloat(i) * tailSpacing / CGFloat(self.array.count - 1)
                            make.right.equalTo(tempSuperView).multipliedBy(CGFloat(i) / CGFloat(self.array.count - 1)).offset(offset)
                        }
                    }else {//first one
                        make.left.equalTo(tempSuperView).offset(leadSpacing);
                    }
                })
                prev = v;
            }
        }else {
            var prev : ConstraintView?
            for (i, v) in self.array.enumerated() {
                v.snp.makeConstraints({ (make) in
                    make.height.equalTo(fixedItemLength)
                    if prev != nil {
                        if (i == self.array.count - 1) {//last one
                            make.bottom.equalTo(tempSuperView).offset(-tailSpacing);
                        }else {
                            let offset = (CGFloat(1) - (CGFloat(i) / CGFloat(self.array.count - 1))) *
                                (fixedItemLength + leadSpacing) -
                                CGFloat(i) * tailSpacing / CGFloat(self.array.count - 1)
                            make.bottom.equalTo(tempSuperView).multipliedBy(CGFloat(i) / CGFloat(self.array.count-1)).offset(offset)
                        }
                    }else {//first one
                        make.top.equalTo(tempSuperView).offset(leadSpacing);
                    }
                })
                prev = v;
            }
        }
    }
    
    /// 九宫格 固定大小宽度
    ///  这个方法需要提前计算好父控件的大小
    /// - Parameters:
    ///   - fixedItemWidth: 宽度
    ///   - fixedItemHeight: 高度
    ///   - fixedLineSpacing: 行间距
    ///   - fixedInteritemSpacing: 列间距
    ///   - warpCount: 一行几个
    ///   - topMargin: 上边距
    ///   - leftMargin: 下边距
    public func distributeSudokuViews(fixedItemWidth: CGFloat, fixedItemHeight: CGFloat, warpCount: Int, fixedLineSpacing: CGFloat = 0, fixedInteritemSpacing: CGFloat = 0,topMargin:CGFloat = 0 ,leftMargin:CGFloat = 0) {
        
        guard self.array.count > 1, warpCount >= 1, let tempSuperView = commonSuperviewOfViews() else {
            return
        }
        for (i,v) in self.array.enumerated() {
            
            let currentRow = i / warpCount//行
            let currentColumn = i % warpCount//列
            
            v.snp.makeConstraints({ (make) in
                make.width.equalTo(fixedItemWidth)
                make.height.equalTo(fixedItemHeight)
                if currentRow == 0 {//第一行
                    make.top.equalTo(tempSuperView).offset(topMargin)
                }
                
                if currentRow != 0 {//其他行
                    let top = (fixedLineSpacing + fixedItemHeight) * CGFloat(currentRow)
                    make.top.equalTo(top + topMargin)
                }
                
                if currentColumn == 0 {//第一列
                    make.left.equalTo(tempSuperView).offset(leftMargin)
                }
                
                if currentColumn != 0 {//其他列
                    let left = (fixedInteritemSpacing + fixedItemWidth) * CGFloat(currentColumn)
                    make.left.equalTo(left + leftMargin)
                }
            })
        }
    }
    
    /// 九宫格 固定间距
    ///
    /// - Parameters:
    ///   - fixedLineSpacing: 行间距
    ///   - fixedInteritemSpacing: 列间距
    ///   - warpCount: 一行几个
    ///   - edgeInset: 上下左右间距默认为0
    public func distributeSudokuViews(fixedLineSpacing: CGFloat, fixedInteritemSpacing: CGFloat, warpCount: Int, edgeInset: ConstraintEdgeInsets = .zero) {
        
        guard self.array.count > 1, warpCount >= 1, let tempSuperView = commonSuperviewOfViews() else {
            return
        }
        
        let remainder = self.array.count % warpCount
        let quotient = self.array.count / warpCount
        
        let rowCount = (remainder == 0) ? quotient : (quotient + 1)
        let columnCount = warpCount
        
        
        var prev : ConstraintView?
        
        for (i,v) in self.array.enumerated() {
            
            let currentRow = i / warpCount
            let currentColumn = i % warpCount
            
            v.snp.makeConstraints({ (make) in
                guard let prev = prev else {//first row & first col
                    make.top.equalTo(tempSuperView).offset(edgeInset.top)
                    make.left.equalTo(tempSuperView).offset(edgeInset.left)
                    return
                }
                make.width.height.equalTo(prev)
                if currentRow == rowCount - 1 {//last row
                    if currentRow != 0 && i - columnCount >= 0 {//just one row
                        make.top.equalTo(self.array[i-columnCount].snp.bottom).offset(fixedLineSpacing)
                    }
                    if currentColumn == 0 {//first col
                        make.left.equalTo(tempSuperView.snp.left)
                    }
                    make.bottom.equalTo(tempSuperView).offset(-edgeInset.bottom)
                }
                
                if currentRow != 0 && currentRow != rowCount - 1 {//other row
                    make.top.equalTo(self.array[i-columnCount].snp.bottom).offset(fixedLineSpacing);
                }
                if currentColumn == warpCount - 1 {//last col
                    if currentColumn != 0 {//just one line
                        make.left.equalTo(prev.snp.right).offset(fixedInteritemSpacing)
                    }
                    make.top.equalTo(prev.snp.top)
                    make.right.equalTo(tempSuperView).offset(-edgeInset.right)
                }
                
                if currentColumn != 0 && currentColumn != warpCount - 1 {//other col
                    make.left.equalTo(prev.snp.right).offset(fixedInteritemSpacing)
                    make.top.equalTo(prev.snp.top)
                }
            })
            prev = v
        }
    }
    /// 自适应宽度分布View
    ///
    /// - Parameters:
    ///   - verticalSpacing: 每个view之间的垂直距离
    ///   - horizontalSpacing: 每个view之间的水平距离
    ///   - maxWidth: 是整个布局的最大宽度，需要事前传入，比如 self.view.bounds.size.width - 40
    ///   - determineWidths: 是每个view的宽度，也需事前计算好
    ///   - itemHeight: 每个view的高度
    ///   - edgeInset: 整个布局的 上下左右边距，默认为 .zero
    ///   - topConstrainView: 整个布局之上的view, 从topConstrainView.snp.bottom开始计算
    ///   - 比如,传入上面的label,则从 label.snp.bottom + edgeInset.top 开始排列， 默认为nil, 此时布局从 superview.snp.top + edgeInset.top 开始计算
    public func distributeDetermineWidthViews(verticalSpacing: CGFloat,
                                              horizontalSpacing: CGFloat,
                                              maxWidth: CGFloat,
                                              determineWidths: [CGFloat],
                                              itemHeight: CGFloat,
                                              edgeInset: UIEdgeInsets = UIEdgeInsets.zero,
                                              topConstrainView: ConstraintView? = nil) {
        
        guard self.array.count > 1, determineWidths.count == self.array.count, let tempSuperview = commonSuperviewOfViews() else {
            return
        }
        
        var prev : ConstraintView?
        var vMinX: CGFloat = 0
        
        let maxW = maxWidth - (edgeInset.right + edgeInset.left)
        
        for (i,v) in self.array.enumerated() {
            
            let curWidth = min(determineWidths[i], maxW)
            v.snp.makeConstraints({ (make) in
                make.width.equalTo(curWidth)
//                make.bottom.lessThanOrEqualTo(tempSuperview).offset(-edgeInset.bottom)
                make.height.equalTo(itemHeight)
                
                if prev == nil { // the first one
                    let tmpTarget = topConstrainView != nil ? topConstrainView!.snp.bottom : tempSuperview.snp.top
                    make.top.equalTo(tmpTarget).offset(edgeInset.top)
                    make.left.equalTo(tempSuperview).offset(edgeInset.left)
                    vMinX = curWidth + horizontalSpacing
                }else {
//                    make.right.lessThanOrEqualToSuperview().offset(-edgeInset.right)
                    
                    if vMinX + curWidth > maxW {
                        make.top.equalTo(prev!.snp.bottom).offset(verticalSpacing)
                        make.left.equalTo(tempSuperview).offset(edgeInset.left)
                        vMinX = curWidth + horizontalSpacing
                    }else {
                        make.top.equalTo(prev!)
                        make.left.equalTo(prev!.snp.right).offset(horizontalSpacing)
                        vMinX += curWidth + horizontalSpacing
                    }
                }
                
            })
            
            prev = v
        }
    }
    
    internal let array: Array<ConstraintView>
    
    internal init(array: Array<ConstraintView>) {
        self.array = array
    }
    
}

public extension Array {
    var snp: ConstraintArrayDSL {
        return ConstraintArrayDSL(array: self as! Array<ConstraintView>)
    }
}

private extension ConstraintArrayDSL {
    func commonSuperviewOfViews() -> ConstraintView? {
        var commonSuperview : ConstraintView?
        var previousView : ConstraintView?
        
        for view in self.array {
            if previousView != nil {
                commonSuperview = view.closestCommonSuperview(commonSuperview)
            }else {
                commonSuperview = view
            }
            previousView = view
        }
        
        return commonSuperview
    }
}

private extension ConstraintView {
    func closestCommonSuperview(_ view : ConstraintView?) -> ConstraintView? {
        var closestCommonSuperview: ConstraintView?
        var secondViewSuperview: ConstraintView? = view
        while closestCommonSuperview == nil && secondViewSuperview != nil {
            var firstViewSuperview: ConstraintView? = self
            while closestCommonSuperview == nil && firstViewSuperview != nil {
                if secondViewSuperview == firstViewSuperview {
                    closestCommonSuperview = secondViewSuperview
                }
                firstViewSuperview = firstViewSuperview?.superview
            }
            secondViewSuperview = secondViewSuperview?.superview
        }
        return closestCommonSuperview
    }
}
//MARK: 数组布局,自己布局
/**
 var arr: Array<UIView> = []
 for i in 0..<4 {
     let subview = UIView()
     subview.backgroundColor = UIColor.random
     v.addSubview(subview)
     v.tag = i
     arr.append(subview)
 }

 arr.snp.makeConstraints { (make) in
     make.width.height.equalTo(100)
     make.center.equalTo(CGPoint(x: CGFloat(arc4random_uniform(300)) + 50, y: CGFloat(arc4random_uniform(300)) + 50))
 }
 */
//MARK: 数组布局,自己布局
/**
 //        axisType:方向
 //        fixedSpacing:中间间距
 //        leadSpacing:左边距(上边距)
 //        tailSpacing:右边距(下边距)
 arr.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 4, leadSpacing: 20, tailSpacing: 30)
 //        上面的可以约束x+w,还需要另外约束y+h
 //        约束y和height()如果方向是纵向,那么则另外需要设置x+w
 arr.snp.makeConstraints{
     $0.top.equalTo(100)
     $0.height.equalTo(CGFloat(arc4random_uniform(100) + 50))
 }
 */

