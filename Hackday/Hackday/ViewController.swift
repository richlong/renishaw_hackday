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

class ViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var lineChartView: LineChartView!

    var months: [String]!
    var dataPoints = [String:Double]()
    
    var dataPointsX = [String]()
    var dataPointsY = [Double]()
    
    var cities = [String:UIColor]()
    var dataSets = [LineChartDataSet]()
    var highTemp:Double = 0.0
    var lowTemp:Double = 10.0


    override func viewDidLoad() {
        super.viewDidLoad()
        
        lineChartView.delegate = self
        
        cities["Cardiff"] = UIColor.redColor()
        cities["Madrid"] = UIColor.blueColor()
        cities["Paris"] = UIColor.yellowColor()

        let xAxis = lineChartView.xAxis
        xAxis.labelTextColor = UIColor.redColor()
        xAxis.spaceBetweenLabels = 10

        let yAxis = lineChartView.xAxis
        yAxis.labelTextColor = UIColor.blueColor()
        yAxis.spaceBetweenLabels = 10
        
//        ChartXAxis *xAxis = _chartView.xAxis;
//        xAxis.labelFont = [UIFont systemFontOfSize:12.f];
//        xAxis.labelTextColor = UIColor.whiteColor;
//        xAxis.drawGridLinesEnabled = NO;
//        xAxis.drawAxisLineEnabled = NO;
//        xAxis.spaceBetweenLabels = 1.0;
//        
//        ChartYAxis *leftAxis = _chartView.leftAxis;
//        leftAxis.labelTextColor = [UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f];
//        leftAxis.customAxisMax = 200.0;
//        leftAxis.drawGridLinesEnabled = YES;
//        
//        ChartYAxis *rightAxis = _chartView.rightAxis;
//        rightAxis.labelTextColor = UIColor.redColor;
//        rightAxis.customAxisMax = 900.0;
//        rightAxis.startAtZeroEnabled = NO;
//        rightAxis.customAxisMin = -200.0;
//        rightAxis.drawGridLinesEnabled = NO;
        for (city,color):(String, UIColor) in cities {
            
            self.getDataForCity(city, completion: { () -> Void in
                self.setChartData(city,color: color)
                
                print(self.lowTemp)
                print(self.highTemp)
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
        
        let set1 = LineChartDataSet.init(yVals: yVals, label: city)
        set1.fillColor = color;
        set1.setColor(color)
        set1.setCircleColor(color)

//        var dataSets = [LineChartDataSet]()
        
        self.dataSets.append(set1)

        let data = LineChartData.init(xVals: xVals, dataSets: self.dataSets)

        lineChartView.data = data
    }
    
    func getDataForCity(city: String, completion:()-> Void) {

        let cityQuery = String(format: "http://api.openweathermap.org/data/2.5/forecast/city?q=%@&APPID=4e86f8ef8bed6b9c9e1e980bda57c12b&units=metric", city)
        Alamofire.request(.GET, cityQuery)
        .responseJSON { response in
        //                print(response.request)  // original URL request
        //                print(response.response) // URL response
        //                print(response.data)     // server data
        //                print(response.result)   // result of response serialization
        
        
            let json = JSON(data: response.data!)

            self.dataPointsX = []
            self.dataPointsY = []
            
            for (_,dataPoint):(String, JSON) in json["list"] {
            
                print("dt: \(dataPoint["dt_txt"].string!) temp: \(dataPoint["main"]["temp"].number!)")
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
}

