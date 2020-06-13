//
//  SheetItemCell.swift

import UIKit

struct SheetItemCellViewModel {
    let title: String
    let subtitle: String
}

class SheetItemCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func present(_ model: SheetItemCellViewModel){
        nameLabel.text = model.title
        descriptionLabel.text = model.subtitle
    }
    
    
}
