//
//  ConstantsLayout.swift
//  AnimTest
//
//  Created by zbkj on 2020/12/3.
//

import UIKit
/// 只是简化一些常用的有带默认属性（如multiplier = 1，value=0）的约束添加
///
/// 包含：高度约束，宽度约束，与父视图的边距、水平中心对齐、垂直中心对齐
///
/// 复杂的约束、请使用第三方库或者xib


public enum EasyConstraint {

    /// 高约束
    case h(CGFloat)
    /// 宽约束
    case w(CGFloat)
    
    /// 距父视图上边距
    case top(CGFloat)
    /// 距父视图左边距
    case left(CGFloat)
    /// 距父视图下边距
    case bottom(CGFloat)
    /// 距父视图右边距
    case right(CGFloat)
    /// 距父视图边距（上、左、下、右、）
    case margin(CGFloat,CGFloat,CGFloat,CGFloat)
    /// 填充父视图 = margin（0，0，0，0）
    case fill
    
    /// 距父视图剧中
    case center
    /// 距父视图水平剧中
    case center_X(CGFloat)
    /// 距父视图垂直剧中
    case center_Y(CGFloat)
    
    /// 在其他view竖直下边
    case above(UIView,CGFloat)
    /// 在其他view竖直下边
    case under(UIView,CGFloat)
    /// 在其他view水平右边
    case before(UIView,CGFloat)
    /// 在其他view水平右边
    case after(UIView,CGFloat)
    
    /// 等宽
    case equal_W(UIView)
    /// 等高
    case equal_H(UIView)
}

// 定义命名空间 方便找addConstraints 方法
public final class Baymax<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol ConstraintsCompatible {
    associatedtype CompatibleType
    var bm: Baymax<CompatibleType> { get }
}

public extension ConstraintsCompatible {
    var bm: Baymax<Self> {
        return Baymax(self)
    }
}

extension UIView: ConstraintsCompatible{}

public extension Baymax where Base: UIView{
    
    /// 添加约束，在add到父视图后调用
    @discardableResult
    func addConstraints(_ constraints:[EasyConstraint]) -> [NSLayoutConstraint]{
        base.translatesAutoresizingMaskIntoConstraints = false
        
        var result = [NSLayoutConstraint]()
        guard let sup = base.superview else { return [] }
        for c in constraints {
            switch c {
            case let .w(value):
                result.append( align(to: nil, attribute: .width, constant: value))
            case let .h(value):
                result.append( align(to: nil, attribute: .height, constant: value))
            case let .top(value):
                result.append( align(to: sup, attribute: .top, constant: value))
            case let .left(value):
                result.append( align(to: sup, attribute: .left, constant: value))
            case let .bottom(value):
                result.append( align(to: sup, attribute: .bottom, constant: -value))
            case let .right(value):
                result.append( align(to: sup, attribute: .right, constant: -value))
                
            case let .margin(t,l,b,r):
                result.append( align(to: sup, attribute: .top, constant: t))
                result.append( align(to: sup, attribute: .left, constant: l))
                result.append( align(to: sup, attribute: .bottom, constant: -b))
                result.append( align(to: sup, attribute: .right, constant: -r))
            case .fill:
                result.append( align(to: sup, attribute: .top, constant: 0))
                result.append( align(to: sup, attribute: .left, constant: 0))
                result.append( align(to: sup, attribute: .bottom, constant: 0))
                result.append( align(to: sup, attribute: .right, constant: 0))
                
            case .center:
                result.append( align(to: sup, attribute: .centerX, constant: 0))
                result.append( align(to: sup, attribute: .centerY, constant: 0))
            case let .center_X(value):
                result.append( align(to: sup, attribute: .centerX, constant: value))
            case let .center_Y(value):
                result.append( align(to: sup, attribute: .centerY, constant: value))

            case let .above(view, value):
                let c = self.addCons(to: view, att: .bottom, by: .equal, att: .top, multiplier: 1, constant: value)
                sup.addConstraint(c)
                result.append(c)
                
            case let .under(view, value):
                let c = self.addCons(to: view, att: .top, by: .equal, att: .bottom, multiplier: 1, constant: value)
                sup.addConstraint(c)
                result.append(c)
                
            case let .before(view, value):
                let c = self.addCons(to: view, att: .right, by: .equal, att: .left, multiplier: 1, constant: value)
                sup.addConstraint(c)
                result.append(c)
                
            case let .after(view, value):
                let c = self.addCons(to: view, att: .left, by: .equal, att: .right, multiplier: 1, constant: value)
                sup.addConstraint(c)
                result.append(c)
                
            case let .equal_W(view):
                let c = self.addCons(to: view, att: .width, by: .equal, att: .width, multiplier: 1, constant: 0)
                sup.addConstraint(c)
                result.append(c)
            case let .equal_H(view):
                let c = self.addCons(to: view, att: .height, by: .equal, att: .height, multiplier: 1, constant: 0)
                sup.addConstraint(c)
                result.append(c)
            }
        }
        return result
    }
    
    
    // 添加约束
    @discardableResult
    fileprivate func addCons(to:UIView?,
         att selfAtt:NSLayoutConstraint.Attribute,
                  by:NSLayoutConstraint.Relation,
           att toAtt:NSLayoutConstraint.Attribute,
          multiplier:CGFloat = 1,
            constant:CGFloat) -> NSLayoutConstraint {
        
        // true会把当前frame自动转约束，新加约束就会冲突，所以把默认转换关了，手动添加约束
        return NSLayoutConstraint(item: base,
                                  attribute: selfAtt,
                                  relatedBy: by,
                                  toItem: to,
                                  attribute: toAtt,
                                  multiplier: multiplier,
                                  constant: constant)
    }
        
    // 相同的约束位置， 且mult=1的简化版添加
    @discardableResult
    fileprivate func align(to: UIView?, attribute: NSLayoutConstraint.Attribute, constant: CGFloat) -> NSLayoutConstraint {
        let c = self.addCons(to: to, att: attribute, by: .equal, att: attribute, multiplier: 1, constant: constant)
        (to ?? base).addConstraint(c)
        return c
    }
    
}



