//
//  ViewController.swift
//  Hackday
//
//  Created by Internet Dev on 04/11/2015.
//  Copyright © 2015 Internet Dev. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Charts
import SwiftSpinner

class ViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    var dataPointsX = [String]()
    var dataPointsY = [Double]()
    var rawCities = [String]()
    var cities = [String:UIColor]()
    var colors = [UIColor]()
    var dataSets = [LineChartDataSet]()
    var highTemp:Double = 0.0
    var lowTemp:Double = 10.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        lineChartView.delegate = self
        SwiftSpinner.show("Loading...")
        
        colors.append(UIColor.redColor())
        colors.append(UIColor.blueColor())
        colors.append(UIColor.yellowColor())
        colors.append(UIColor.greenColor())
        colors.append(UIColor.blackColor())
        colors.append(UIColor.grayColor())

        var c = 0;
        for city in rawCities {
            cities[city] = colors[c]
            c++
        }

        let marker = Marker.init(color: UIColor.whiteColor(), font: UIFont.systemFontOfSize(12), insets: UIEdgeInsets.init(top: 8, left: 8, bottom: 20, right: 8))
        
        lineChartView.marker = marker
        
        lineChartView.drawMarkers = true
        


        let xAxis = lineChartView.xAxis
        xAxis.labelTextColor = UIColor.redColor()
        xAxis.spaceBetweenLabels = 10

        let yAxis = lineChartView.xAxis
        yAxis.labelTextColor = UIColor.blueColor()
        yAxis.spaceBetweenLabels = 10
        

        for (city,color):(String, UIColor) in cities {
            
            self.getDataForCity(city, completion: { () -> Void in
                self.setChartData(city,color: color)
                
                print(self.lowTemp)
                print(self.highTemp)
                SwiftSpinner.hide()
                
                self.lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 0.0)

            })
        }
    }

    func setChartData(city:String, color:UIColor) {
        
        print("Outputting \(self.dataPointsX.count) items in \(city)")
        var yVals = [ChartDataEntry]()
        var xVals = [String]()

        var c = 0;
        for key in self.dataPointsX {
//            print("dt: \(key) temp: \(self.dataPointsY[c])")
            xVals.append(key)
            yVals.append(ChartDataEntry.init(value: self.dataPointsY[c], xIndex:c))
            c++
        }
        
        let set = LineChartDataSet.init(yVals: yVals, label: city)
        set.fillColor = color;
        set.setColor(color)
        set.setCircleColor(color)
        self.dataSets.append(set)

        let data = LineChartData.init(xVals: xVals, dataSets: self.dataSets)

        lineChartView.data = data
    }
    
    func getDataForCity(city: String, completion:()-> Void) {

        let cityQuery = String(format: "http://api.openweathermap.org/data/2.5/forecast/city?q=%@&APPID=4e86f8ef8bed6b9c9e1e980bda57c12b&units=metric", city)
        Alamofire.request(.GET, cityQuery)
        .responseJSON { response in
            
            let json = JSON(data: response.data!)

            self.dataPointsX = []
            self.dataPointsY = []
            
            for (_,dataPoint):(String, JSON) in json["list"] {
            
//                print("dt: \(dataPoint["dt_txt"].string!) temp: \(dataPoint["main"]["temp"].number!)")
                self.dataPointsX.append(dataPoint["dt_txt"].string!)
                let temp = Double(dataPoint["main"]["temp"].number!)
                self.dataPointsY.append(temp)
            
                if temp > self.highTemp {
                    self.highTemp = temp
                }
                
                if temp < self.lowTemp {
                    self.lowTemp = temp
                }
            }
            
            completion()
        }
    }
    
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
//        print("\(highlight)")
        if dataSetIndex == 1 {
            print("\(entry.value)")
            print("\(entry)")
            print("\(highlight)")
            print("\(dataSetIndex)")
            print("\(chartView)")


        }

    }
}

