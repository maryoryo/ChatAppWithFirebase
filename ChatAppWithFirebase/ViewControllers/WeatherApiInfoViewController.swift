//
//  WeatherApiInfoViewController.swift
//  ChatAppWithFirebase
//
//  Created by 清藤凌真 on 2023/02/12.
//

import UIKit
import CoreLocation
import Nuke

class WeatherApiInfoViewController: UIViewController {
    
    @IBOutlet weak var prefectureLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var weatherTelop: UILabel!
    @IBOutlet weak var celsiusLabel: UILabel!
    
    // 位置情報関連
    let locationManager = CLLocationManager()
    var prefectureName: String? {
        didSet {
            self.weatherApiViewSet(prefectureName: self.prefectureName)
        }
    }
    
    // レスポンスデータを格納
    var weatherApiRes: WeatherApiResponse?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ロケーションマネージャ
        locationManager.delegate = self
        // 位置情報許可ダイアログ
        locationManager.requestWhenInUseAuthorization()

        setupViews()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        if locationManager.authorizationStatus == .denied {
//            let alertController = UIAlertController(title: "許可頂くことで天気情報が取得可能です", message: "", preferredStyle: .alert)
//            let cancel = UIAlertAction(title: "キャンセル", style: .cancel)
//            let ok = UIAlertAction(title: "設定", style: .default, handler: {
//                _ in
//                if let settingUrl = URL(string: UIApplication.openSettingsURLString) {
//                    UIApplication.shared.open(settingUrl, options: [:], completionHandler: nil)
//                }
//            })
//            alertController.addAction(cancel)
//            alertController.addAction(ok)
//            self.present(alertController, animated: true, completion: nil)
//        }
//    }
    
    private func setupViews() {
        // ナビゲーションバーの背景色と文字色変更
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .rgb(red: 39, green: 49, blue: 69)
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationItem.title = "天気情報"
        self.navigationController?.navigationBar.standardAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        self.navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
    }
    
    // 天気情報のAPI呼び出し
    private func weatherApiViewSet(prefectureName: String?) {
        WeatherApi().getWeatherApi(prefectureName: prefectureName, completion: { result in
            switch result {
            case .success(let response):
                self.weatherApiRes = response
                // 天気情報をViewに反映
                self.prefectureLabel.text = response.location?.prefecture
                // TODO: 天気の画像返すAPIが作れたらいいな
//                if let url = URL(string: response.forecasts?.first?.image?.url ?? "") {
//
//                    Nuke.loadImage(with: url, into: self.weatherImage, completion: nil)
//                }
                
//                self.weatherImage = UIImage
                self.weatherTelop.text = response.forecasts?.first?.telop
                self.celsiusLabel.text = response.forecasts?.first?.temperature?.max?.celsius
            case.failure:
                break
            }
        })
    }
}

// 位置情報取得の処理
extension WeatherApiInfoViewController: CLLocationManagerDelegate {
    
    // 位置情報取得成功時に呼ばれます
    func locationManager(_ manager: CLLocationManager,didUpdateLocations locations: [CLLocation]){
        print("緯度経度: \(locations)")
        if let location = locations.first {
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemark, error) in
                if let placemark = placemark?.first {
                    self.prefectureName = placemark.administrativeArea
//                    self.weatherApiViewSet(prefectureName: self.prefectureName)
                } else {
                    print("位置情報の取得に失敗しました：\(String(describing: error))")
                }
            })
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            manager.distanceFilter = 10
            manager.startUpdatingLocation()
        case .denied:
            let alertController = UIAlertController(title: "許可頂くことで天気情報が取得可能です", message: "", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel)
            let ok = UIAlertAction(title: "設定", style: .default, handler: {
                _ in
                if let settingUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingUrl, options: [:], completionHandler: nil)
                }
            })
            alertController.addAction(cancel)
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
        case .notDetermined, .restricted:
            break
        @unknown default:
            fatalError()
        }
    }
        
    // 位置情報取得失敗時に呼ばれます
//    private func locationManager(manager: CLLocationManager!,didFailWithError error: NSError!){
//        print("error")
//    }
}
