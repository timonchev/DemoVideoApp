//
//  HomeViewModel.swift

import UIKit
import Photos
import RxCocoa
import RxSwift

class HomeViewModel: NSObject {
    
    var videoPermissionsState = BehaviorRelay<Bool>(value: false)
    var videoURLArray = BehaviorRelay<[URL]>(value: [])
    private let bag = DisposeBag()
    
    let sortVideosParam = "modificationDate"
    
    override init() {
        super.init()
        self.requestPermissions()
        
        self.videoPermissionsState.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (value) in
                self?.getVideosFromMemory()
            })
            .disposed(by: bag)
    }
    
    func getVideosFromMemory() {
        let options = PHFetchOptions()
        
        options.sortDescriptors = [NSSortDescriptor(key: sortVideosParam,
                                                    ascending: true)]
        let allVideo = PHAsset.fetchAssets(with: .video, options: options)
        var videoURLs: [URL] = []
        allVideo.enumerateObjects { (asset, index, bool) in
            // videoAssets.append(asset)
            let imageManager = PHCachingImageManager()
            //request asset data
            imageManager.requestAVAsset(forVideo: asset, options: nil, resultHandler: { (asset, audioMix, info) in
                if asset != nil {
                    let avasset = asset as! AVURLAsset
                    let urlVideo = avasset.url
                    print(urlVideo)
                    videoURLs.append(urlVideo)
                    
                    if index == allVideo.count - 1 {
                        //set all videosURLS
                        self.videoURLArray.accept(videoURLs)
                    }
                }
            })
        }
    }
    
    func requestPermissions() {
        
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                self.videoPermissionsState.accept(true)
            //was not requested permissions before
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.videoPermissionsState.accept(true)
                    }
                }
            case .denied, .restricted:
                return
            default:
                return
            }
        }
    }
    
}
