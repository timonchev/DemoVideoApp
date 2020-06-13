//
//  HomeCell.swift

import UIKit

struct DataObj {
    var play_Url: URL?
}

class HomeCell: UICollectionViewCell {
    
    var data:DataObj?
    @IBOutlet weak var imgView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
