//
//  BaseTableView.swift
//  huitun
//
//  Created by 海 on 2023/9/21.
//

import UIKit
import NVActivityIndicatorView
import MJRefresh

class BaseTableView: UIView {
    
    /// 记录上次请求的时间戳
    public var lastLoadTime:Date = Date(timeIntervalSince1970: 0)
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
    // 是否需要刷新
    public var needReload:Bool = true

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
        self.addSubview(tableview!)
        if #available(iOS 15.0, *) {
            tableview?.sectionHeaderTopPadding = 0
        }
        indicatorView = BMIndicatorView.showInView(self, frame: rect)
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
                if self.needReload{
                    self.reloadData(resp!.code)
                }
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
extension BaseTableView{
    public func initMJHeadViewFZ() {
        let header = MJRefreshNormalHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(BaseTableView.loadNewData))
//        header.loadingView?.color = .white
        header.lastUpdatedTimeLabel?.isHidden = YES
        header.stateLabel?.isHidden = YES
        header.loadingView?.style = .white
        header.stateLabel?.textColor = .white
        tableview?.mj_header = header
        
        let foot = MJRefreshAutoNormalFooter()
        foot.setRefreshingTarget(self, refreshingAction: #selector(BaseTableView.loadMoreData))
        foot.triggerAutomaticallyRefreshPercent = -9
        foot.stateLabel?.textColor = .white
        foot.setTitle("", for: .idle)
        foot.setTitle(footNoDataText, for: .noMoreData)
        tableview?.mj_footer = foot
    }
}
