//
//  BaseTableVC.swift
//  wangfuAgent
//
//  Created by  on 2018/7/11.
//  Copyright © 2018 zhuanbangTec. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import MJRefresh

class ListModel: HandyJSON {
    required init() {}
}
//@objc public protocol MyTableViewGestureDelegate {
//    func myTableViewGestureRecognizer() -> Bool
//}
//class MyTableView: UITableView ,UIGestureRecognizerDelegate{
//    ///不想让手势透传可以用代理
//    weak var gestureDelegate: MyTableViewGestureDelegate?
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if let delegate = gestureDelegate{
//            return delegate.myTableViewGestureRecognizer()
//        }
//        return YES
//    }
//}

open class BaseTableVC: BaseVC {
    
    public var listRequestCode = 1
    
    public var tableview: UITableView?
    public var pageNo = 1
    public var PageSize = KPageSize
    public var dataArr:Array<Any>! = []
    public var param = Dictionary<String,Any>()
    
    public var indicatorView :BMIndicatorView!
    
    public var footNoDataText:String = ""
    
    // cell显示的时候是否显示加载动画
    public var needOpenCellShowAnimation:Bool = false
    
    // 请求失败是否提示错误
    public var showRequestError:Bool = false
    // 是否缓存 有值就缓存 没有就不缓存
    public var listCacheKey:String?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        cache[.reload] = false
    }
    
    public func initTableView(rect:CGRect ,_ style:UITableView.Style = .plain) -> Void {
        tableview = UITableView.init(frame: rect, style: style)
        let cons:[EasyConstraint] = [.top(rect.origin.y), .left(0), .right(0), .h(rect.height)]
        tableview?.bm.addConstraints(cons)
        tableview?.separatorStyle = .none
        tableview?.backgroundColor = .white
        
        tableview?.keyboardDismissMode = .onDrag//滚动退出键盘
        
        tableview?.estimatedRowHeight = 0
        tableview?.estimatedSectionHeaderHeight = 0
        tableview?.estimatedSectionFooterHeight = 0
        view.addSubview(tableview!)
        ignoreAutoAdjustScrollViewInsets(tableview)
        if #available(iOS 15.0, *) {
            tableview?.sectionHeaderTopPadding = 0
        }
        indicatorView = BMIndicatorView.showInView(view, frame: rect)
        indicatorView?.bm.addConstraints(cons)
    }
    
    public func initMJHeadView() -> Void {
        let header = MJRefreshNormalHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(BaseTableVC.loadNewData))
        header.lastUpdatedTimeLabel?.isHidden = YES
        header.stateLabel?.isHidden = YES
        tableview?.mj_header = header
        
        let foot = MJRefreshAutoNormalFooter()
        foot.setRefreshingTarget(self, refreshingAction: #selector(BaseTableVC.loadMoreData))
        foot.triggerAutomaticallyRefreshPercent = -9
        foot.stateLabel?.textColor = .KTextLightGray
        foot.setTitle("", for: .idle)
        foot.setTitle(footNoDataText, for: .noMoreData)
        tableview?.mj_footer = foot
    }
    
    public func loadNewDataWithIndicator() -> Void {
        showLoadingView()
        loadNewData()
    }
    
    @objc public func loadNewData() -> Void {
        //记录刷新时间
        lastLoadTime = Date()
        tableview?.mj_footer?.resetNoMoreData()
        loadData(1)
    }
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if appearTimes > 1 {
            if let reload = cache[.reload],reload == true {
                loadNewData()
                cache[.reload] = false
            }
        }
    }
    @objc public func loadMoreData() -> Void {
        if tableview?.mj_footer != nil && tableview?.mj_footer?.state != .noMoreData{
            loadData(pageNo+1)
        }
    }
    
    //请求数据  重写 请求数据
    open func loadData(_ page:Int) -> Void {
        return
    }
    
    @discardableResult
    public func getList<T:HandyJSON>(key: BMApiTemplete<Array<T>?>, page:Int, finished:@escaping ()->()) -> DataRequest{
        param["pageNumber"] = page
        param["pageNo"] = page
        param["pageSize"] = PageSize
        param["row"] = PageSize
        let count = self.dataArr.count
        return network[key].request(params: param) { (resp) in
            self.listRequestCode = resp!.code
            if resp?.code == 1{
                self.pageNo = page

                let temp = resp!.data
                if page == 1{
                    self.dataArr = temp ?? []
                }else{
                    self.dataArr.append(contentsOf: temp ?? [])
                }
            }else if resp!.code < 0 && page == 1{
                self.dataArr = []
            }else{
                if self.showRequestError == true{
                    Hud.showText(resp?.msg ?? "")
                }
            }
            
            if resp?.code != -999{
                self.finishLoadDate(resp!.code)
                //已经有数据时的 下拉刷新 关闭渐变显示
                if count == 0 && self.dataArr.count != 0 && page == 1{
                    self.needOpenCellShowAnimation = true
                }else{
                    self.needOpenCellShowAnimation = false
                }
                
                finished()
                self.reloadData(resp!.code)
            }
        }
    }
    
    public func finishLoadDate(_ code:Int) -> Void {
        if tableview?.mj_header != nil {
            tableview?.mj_header?.endRefreshing()
            if code == -1 || dataArr.count % PageSize != 0{
                tableview?.mj_footer?.endRefreshingWithNoMoreData()
            }else{
                tableview?.mj_footer?.endRefreshing()
            }
            
            if dataArr.count == 0{
                tableview?.mj_footer?.endRefreshingWithNoMoreData()
            }
        }
    }
    
    public func showLoadingView() -> Void {
        tableview?.isHidden = true
        indicatorView.showWait()
    }
    
    //刷新数据
    public func reloadData(_ code:Int = 1) -> Void {
        if dataArr.count == 0 && code == -1{
            tableview?.isHidden = true
            indicatorView.showNoData()
        }else{
            indicatorView.hide()
            tableview?.isHidden = false
        }
        tableview?.reloadData()
        
    }
}



