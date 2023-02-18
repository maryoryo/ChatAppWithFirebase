//
//  NewsApiInfoViewController.swift
//  ChatAppWithFirebase
//
//  Created by 清藤凌真 on 2023/02/12.
//

import UIKit

class NewsApiInfoViewController: UIViewController {

    @IBOutlet weak var newsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newsCollectionView.delegate = self
        newsCollectionView.dataSource = self
        
        newsCollectionView.register(UINib(nibName: "NewsApiInfoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CustomCell")
    }
}

extension NewsApiInfoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! NewsApiInfoCollectionViewCell
        cell.kariLabel.text = "\(indexPath.row + 1)番目のセル"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(indexPath.row + 1)番目が押下されたよ")
    }
    
    
}
