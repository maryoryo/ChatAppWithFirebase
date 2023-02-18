//
//  WeatherApiInfoViewController.swift
//  ChatAppWithFirebase
//
//  Created by 清藤凌真 on 2023/02/12.
//

import UIKit

class WeatherApiInfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    private func setupViews() {
        // ナビゲーションバーの背景色と文字色変更
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .rgb(red: 39, green: 49, blue: 69)
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationItem.title = "トーク"
        self.navigationController?.navigationBar.standardAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        self.navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
    }
    
    private func weatherApi() {
//        WeatherApi().getWeatherApi()
    }

}
