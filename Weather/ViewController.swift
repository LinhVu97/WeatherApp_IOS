//
//  ViewController.swift
//  Weather
//
//  Created by Vũ Linh on 26/04/2021.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var weather: UILabel!
    @IBOutlet weak var temperature: UILabel!

    let api_key = "d1ecaac36785d4f198a40d1a3f3e13f1"
    var lat = 21.0278
    var long = 105.8342
    var activityIndicator: NVActivityIndicatorView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupIndicatorView()
        locationManager.requestWhenInUseAuthorization()
        
        activityIndicator.startAnimating()
        if(CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func setupIndicatorView() {
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width - indicatorSize)/2, y: (view.frame.height - indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .lineScale, color: .white, padding: 20.0)
        activityIndicator.backgroundColor = .black
        view.addSubview(activityIndicator)
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            lat = location.coordinate.latitude
            long = location.coordinate.longitude
        }

        Alamofire.request("http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&appid=\(api_key)&units=metric").responseJSON { (response) in
            self.activityIndicator.stopAnimating()
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)
                let jsonWeather = jsonResponse["weather"].array![0]
                let jsonTemp = jsonResponse["main"]
                let iconName = jsonWeather["icon"].stringValue
                
                self.location.text = jsonResponse["name"].stringValue
                self.image.image = UIImage(named: iconName)
                self.weather.text = jsonWeather["main"].stringValue
                self.temperature.text = "\(Int(round(jsonTemp["temp"].doubleValue)))"
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"
                self.date.text = dateFormatter.string(from: date)
            }
        }
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
