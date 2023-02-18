//
//  NewsApiInfoCollectionViewCell.swift
//  ChatAppWithFirebase
//
//  Created by 清藤凌真 on 2023/02/12.
//

import UIKit

class NewsApiInfoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var kariLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .green
    }

}
