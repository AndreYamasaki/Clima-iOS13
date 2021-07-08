//
//  WeatherManager.swift
//  Clima
//
//  Created by André Yamasaki on 06/07/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherDelegateManager {
    func didUpdateWather(_ weatherManager: WeatherManager,weather: WeatherModel)
    func didFailwithError(error: Error)
}

struct WeatherManager {
    //    let apikey = "e81d3fd189316a811485a4b9a6bdcda7"
    //    let weatherURL = "api.openweathermap.org/data/2.5/weather?appid=e81d3fd189316a811485a4b9a6bdcda7"
    var delegate: WeatherDelegateManager?
    
    func fetchWeather (cityName: String) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?appid=e81d3fd189316a811485a4b9a6bdcda7&units=metric&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailwithError(error: error!)
                    return
                }
                if let safeData = data {
                    //                    let dataString = String(data: safeData, encoding: .utf8)
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let temp = decodedData.main.temp
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        } catch {
            self.delegate?.didFailwithError(error: error)
            return nil
        }
    }
}
