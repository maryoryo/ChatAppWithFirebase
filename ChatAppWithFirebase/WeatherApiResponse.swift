//
//  WeatherApiResponse.swift
//  ChatAppWithFirebase
//
//  Created by 清藤凌真 on 2023/02/18.
//

import Foundation

struct WeatherApiResponse: Codable {
    let publicTime: String?
    let publicTimeFormatted: String?
    let publishingOffice: String?
    let title: String?
    let link: String?
    let description: Description?
    let forecasts: [Forecast]?
    let location: Location?
    let copyright: Copyright?
}

struct Provider: Codable {
    let link: String?
    let name: String?
    let note: String?
}

struct Description: Codable {
    let publicTime: String?
    let publicTimeFormatted: String?
    let headlineText: String?
    let bodyText: String?
    let text: String?
}

struct Forecast: Codable {
    let date: String?
    let dateLabel: String?
    let telop: String?
    let detail: Detail?
    let temperature: Temperature?
    let chanceOfRain: ChanceOfRain?
    let image: Image?
}

struct ChanceOfRain: Codable {
    let T00_06: String?
    let T06_122: String?
    let T12_18: String?
    let T18_24: String?
}

struct Detail: Codable {
    let weather: String?
    let wind: String?
    let wave: String?
}

struct Image: Codable {
    let title: String?
    let url: String?
    let width: Int?
    let height: Int?
}

struct Temperature: Codable {
    let min: Min?
    let max: Max?
}

struct Max: Codable {
    let celsius: String?
    let fahrenheit: String?
}

struct Min: Codable {
    let celsius: String?
    let fahrenheit: String?
}

struct Location: Codable {
    let area: String?
    let prefecture: String?
    let district: String?
    let city: String?
}

struct Copyright: Codable {
    let title: String?
    let link: String?
    let image: CopyrightImage?
    let provider: [Provider]?
}

struct CopyrightImage: Codable {
    let title: String
    let link: String
    let url: String
    let width: Int
    let height: Int
}

