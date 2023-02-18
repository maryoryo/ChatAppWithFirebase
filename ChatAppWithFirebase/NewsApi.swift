//
//  NewsApi.swift
//  ChatAppWithFirebase
//
//  Created by 清藤凌真 on 2023/02/18.
//

import Foundation
import Alamofire

class NewsApi {
    
    let baseUrl = "https://newsapi.org/v2/top-headlines?country=us&apiKey=\(AccessToken.shared.newsApiKey)"
    
    func getNewsApi() {
        AF.request(baseUrl).response(completionHandler: { response in
            switch response.result {
            case .success(let result):
                do {
                    
                } catch {
                    print("デコードに失敗しました")
                }
            case .failure(let error):
                print("error", error)
            }
        })
    }
}
