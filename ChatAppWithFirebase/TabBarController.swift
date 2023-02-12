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
        
//        let storyboard = UIStoryboard(name: "ChatList", bundle: nil)
//        let chatListViewController = storyboard.instantiateViewController(identifier: "ChatListViewController") as ChatListViewController
////        let vc = UINavigationController(rootViewController: chatListViewController)
//
//        let vcs = [chatListViewController]
//
//        let vcNav = vcs.map{UINavigationController(rootViewController: $0)}
//
//        setViewControllers(vcNav, animated: true)
        
        
        var viewControllers = [UIViewController]()
        
        let storyboard = UIStoryboard(name: "ChatList", bundle: nil)
        let chatListViewController = storyboard.instantiateViewController(identifier: "ChatListViewController")
        chatListViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 1)
        viewControllers.append(chatListViewController)

        self.viewControllers = viewControllers.map{ UINavigationController(rootViewController: $0) }
        self.setViewControllers(viewControllers, animated: false)
//        setupViews()
    }
    
    private func setupViews() {
        
        
        
        
//        let vcs = [vc1, vc2, vc3, vc4]
//        let viewControllers = vcs.map{ UINavigationController(rootViewController: $0)}
//        setViewControllers(viewControllers, animated: false)
    }

}
