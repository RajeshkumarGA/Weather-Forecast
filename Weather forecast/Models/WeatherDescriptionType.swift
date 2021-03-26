//
//  WeatherDescriptionType.swift
//  Weather forecast
//
//  Created by RajeshKumar on 24/03/21.
//

import Foundation

enum WeatherDescriptionType: String {
    case scatteredclouds
    case clearsky
    case fewclouds
    case brokenclouds
    case showerrain
    case rain
    case thunderstorm
    case snow
    case mist

    var type: String {
        switch self {
            case .scatteredclouds:
                return "scattered clouds"
            case .clearsky:
                return "clear sky"
            case .fewclouds:
                return "few clouds"
            case .brokenclouds:
                return "brokenclouds"
            case .showerrain:
                return "showerrain"
            case .rain:
                return "rain"
            case .thunderstorm:
                return "thunderstorm"
            case .snow:
                return "snow"
            case .mist:
                return "mist"
            }
    }
}
