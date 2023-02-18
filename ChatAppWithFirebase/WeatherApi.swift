//
//  WeatherApi.swift
//  ChatAppWithFirebase
//
//  Created by 清藤凌真 on 2023/02/12.
//

import Foundation
import CoreLocation
import Alamofire

enum WebApiError: Error {
    case decodeError
    case serverException
}

class WeatherApi {
    func getWeatherApi(prefectureName: String?, completion: @escaping (Result<WeatherApiResponse, WebApiError>) -> Void) {
        
        var prefectureID: String?
        
        // TODO: 都道府県によってprefectureIDが返るAPIが作れたらいいな
        switch prefectureName {
        case "東京都":
            prefectureID = "130010"
        case "神奈川県":
            prefectureID = "140010"
        default:
            prefectureID = "130010"
        }
        
        // if let でprefectureIDをアンラップする
        if let prefectureID = prefectureID {
            let baseUrl = "https://weather.tsukumijima.net/api/forecast/city/\(prefectureID)"
            AF.request(baseUrl).response(completionHandler: { response in
                switch response.result {
                case .success:
                    do {
                        let jsonDecoder = JSONDecoder()
                        let weatherApiResponse = try jsonDecoder.decode(WeatherApiResponse.self, from: response.data!)
                        completion(.success(weatherApiResponse))
                    } catch let error {
                        print("デコードに失敗しました", error)
                        completion(.failure(.decodeError))
                    }
                case .failure(let error):
                    print("通信エラーが発生しました", error)
                    completion(.failure(.serverException))
                }
            })
        }
    }
}
