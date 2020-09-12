//
//  ViewController1.swift
//  WeatherAppEx
//
//  Created by Pratik on 12/09/20.
//  Copyright © 2020 prk. All rights reserved.
//

import UIKit
import Alamofire
import SwiftGifOrigin
import Lottie

class ViewController1: UIViewController {
    @IBOutlet var lblCityName: UILabel!
    @IBOutlet var lblWeatherSummary: UILabel!
    @IBOutlet var lblWeatherDegrees: UILabel!
    @IBOutlet var lblMaxWeatherDegrees: UILabel!
    @IBOutlet var imgVRef: UIImageView!
    @IBOutlet var animationViewRef: AnimationView!
    
    var Lat = ""
    var Long = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCurrentWeather(Lat: Lat, Long: Long)
        //imgVRef.image = UIImage.gif(name: "weather")
        animation()
        
    }
    
    func animation(){
        animationViewRef.animation = Animation.named("weather")
        animationViewRef.loopMode = .loop
        animationViewRef.play()
    }


}
extension ViewController1 {
    func loadCurrentWeather(Lat:String,Long:String) {
        
        AF.request("https://api.openweathermap.org/data/2.5/weather?lat=\(Lat)&lon=\(Long)&appid=5a364d387a984a75481eaedde610fb1f",method: .get).responseJSON { (response) in
            
            switch response.result {
            case .success:
                guard let json = response.data else {return}
                do {
                    let decoder = JSONDecoder()
                    let data = try decoder.decode(WEATHERS.self, from: json)
                    print(data)
                    //self.weatherArr = data
                    guard let cityName = data.name else {return
                    }
                    self.lblCityName.text = cityName
                    guard let descrip = data.weather?[0].description else {
                        return}
                    self.lblWeatherSummary.text = descrip
                    guard let minTemp = data.main?.temp_min else {
                        return
                    }
                    let celsiusTemp = minTemp - 273.15
                    
                    self.lblWeatherDegrees.text = "\(String(format: "%.0f", celsiusTemp))°C"
                    guard let maxTemp = data.main?.temp_max else {
                        return
                    }
                    let celsiusMaxTemp = maxTemp - 273.15
                    
                    self.lblMaxWeatherDegrees.text = "\(String(format: "%.0f", celsiusMaxTemp))°C"
                    
                }
                catch let error {
                    print(error)
                }
            case .failure(_):
                print("Error : ")
                
            }
            
            DispatchQueue.main.async {
                
            }
            
        }
        
        
    }
}

