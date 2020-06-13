//
//  ListViewController.swift

import UIKit
import UBottomSheet
import RxSwift

class SheetViewController: UIViewController {
    @IBOutlet weak private var tableView: UITableView!
    private let cellId = "SheetItemCell"
    
    var sheetCoordinator: UBottomSheetCoordinator?
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        
        let items = Observable.just(
            (0..<30).map{ SheetItemCellViewModel(title: "Test Title \($0)", subtitle: "Test subtitle \($0)") }
        )
        
        items.asObservable().bind(to: self.tableView.rx.items(cellIdentifier: cellId)) { row, data, cell in
            (cell as! SheetItemCell).present(data)
        }.disposed(by: bag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sheetCoordinator?.startTracking(item: self)
    }
}

extension SheetViewController: Draggable{
    func draggableView() -> UIScrollView? {
        return tableView
    }
}

