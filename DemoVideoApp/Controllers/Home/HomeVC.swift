//
//  HomeVC.swift

import UIKit
import RxSwift
import Photos
import AVFoundation
import MMPlayerView
import UBottomSheet

class HomeVC: UIViewController {
    
    // MARK: - Constants
    
    private let cellWidth = UIScreen.main.bounds.width
    private let cellHeight = UIScreen.main.bounds.height
    private let cellId = "HomeCell"
    var offsetObservation: NSKeyValueObservation?
    
    // MARK: - UI Components
    
    var sheetCoordinator: UBottomSheetCoordinator!
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    lazy var mmPlayerLayer: MMPlayerLayer = {
        let player = MMPlayerLayer()
        player.cacheType = .memory(count: 5)
        player.coverFitType = .fitToPlayerView
        player.videoGravity = AVLayerVideoGravity.resizeAspect
        player.repeatWhenEnd = true
        player.autoPlay = true
        return player
    }()
    
    // MARK: - Tools
    
    private let bag = DisposeBag()
    private let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        viewModel.videoURLArray.asObservable().take(1).subscribe(onNext: { (values) in
            DispatchQueue.main.async { [weak self] in
                self?.updateByContentOffset()
                self?.startLoading()
            }
        }).disposed(by: bag)
        
        self.navigationController?.mmPlayerTransition.push.pass(setting: { (_) in })
        
        offsetObservation = collectionView.observe(\.contentOffset, options: [.new]) { [weak self] (_, value) in
            guard let self = self, self.presentedViewController == nil else {return}
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            self.perform(#selector(self.startLoading), with: nil, afterDelay: 0.0)
        }
        
        viewModel.videoURLArray.asObservable().bind(to: self.collectionView.rx.items(cellIdentifier: cellId, cellType: HomeCell.self)) { row, data, cell in
            cell.data = DataObj(play_Url: data)
        }.disposed(by: bag)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        //itialize bottom sheet
        guard sheetCoordinator == nil else { return }
        sheetCoordinator = UBottomSheetCoordinator(parent: self)
        
        //set sheet view controller
        let sheetVC = SheetViewController()
        sheetVC.sheetCoordinator = sheetCoordinator
        sheetCoordinator.addSheet(sheetVC, to: self, didContainerCreate: { container in
            let f = self.view.frame
            let rect = CGRect(x: f.minX, y: f.minY, width: f.width, height: f.height)
            container.roundCorners(corners: [.topLeft, .topRight], radius: 15, rect: rect)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        registerCells()
        applyConstraints()
    }
    
    private func registerCells() {
        collectionView.register(UINib(nibName: "HomeCell", bundle: .main), forCellWithReuseIdentifier: "HomeCell")
    }
    
    private func applyConstraints() {
        //setup contstraint for collectionview
        view.addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: cellHeight).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

extension HomeVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async { [unowned self] in
            self.updateDetail(at: indexPath)
        }
    }
    
    fileprivate func updateDetail(at indexPath: IndexPath) {
        self.mmPlayerLayer.set(url: viewModel.videoURLArray.value[indexPath.row])
        self.mmPlayerLayer.resume()
    }
    
    
    fileprivate func updateCell(at indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? HomeCell, let playURL = cell.data?.play_Url {
            // set video view where to play
            mmPlayerLayer.playView = cell.imgView
            //set source url
            mmPlayerLayer.set(url: playURL)
            //start play video
            mmPlayerLayer.resume()
        }
    }
    
    @objc fileprivate func startLoading() {
        self.updateByContentOffset()
        if self.presentedViewController != nil {
            return
        }
        // start loading video
        mmPlayerLayer.resume()
    }
    
    fileprivate func updateByContentOffset() {
        
        if let path = findCurrentPath(),
            self.presentedViewController == nil {
            self.updateCell(at: path)
        }
    }
    
    private func findCurrentPath() -> IndexPath? {
        //get indexPath
        let point = CGPoint(x: collectionView.frame.width/2, y: collectionView.contentOffset.y + collectionView.frame.width/2)
        return collectionView.indexPathForItem(at: point)
    }
    
    private func findCurrentCell(path: IndexPath) -> UICollectionViewCell {
        return collectionView.cellForItem(at: path)!
    }
}
