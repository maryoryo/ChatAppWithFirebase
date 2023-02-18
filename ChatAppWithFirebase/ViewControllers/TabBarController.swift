//
//  TabBarController.swift
//  ChatAppWithFirebase
//
//  Created by 清藤凌真 on 2023/02/09.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var vc1: ChatListViewController {
            // チャットリスト
            let chatListStoryboard = UIStoryboard(name: "ChatList", bundle: nil)
            let chatListViewController = chatListStoryboard.instantiateViewController(identifier: "ChatListViewController") as ChatListViewController
            chatListViewController.tabBarItem = UITabBarItem(title: "チャット", image: iconResize(image: UIImage(named: "chatIcon")!), tag: 1)
            return chatListViewController
        }
        
        var vc2: WeatherApiInfoViewController {
            // 天気情報
            let weatherApiInfoStoryboard = UIStoryboard(name: "WeatherApiInfo", bundle: nil)
            let weatherApiInfoViewController = weatherApiInfoStoryboard.instantiateViewController(identifier: "WeatherApiInfoViewController") as WeatherApiInfoViewController
            weatherApiInfoViewController.tabBarItem = UITabBarItem(title: "天気", image: iconResize(image: UIImage(named: "weatherIcon")!), tag: 2)
            return weatherApiInfoViewController
        }
        
        var vc3: NewsApiInfoViewController {
            // 天気情報
            let newsApiInfoStoryboard = UIStoryboard(name: "NewsApiInfo", bundle: nil)
            let newsApiInfoViewController = newsApiInfoStoryboard.instantiateViewController(identifier: "NewsApiInfoViewController") as NewsApiInfoViewController
            newsApiInfoViewController.tabBarItem = UITabBarItem(title: "ニュース", image: iconResize(image: UIImage(named: "newsIcon")!), tag: 3)
            return newsApiInfoViewController
        }
        
        let vcs = [vc1, vc2, vc3]
        let viewControllers = vcs.map{ UINavigationController(rootViewController: $0) }
        setViewControllers(viewControllers, animated: false)

    }
    
    func iconResize(image: UIImage) -> UIImage {
        let scaledImageSize = CGSize(width: 35, height: 35)
        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        let scaleImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        return scaleImage
    }

}
