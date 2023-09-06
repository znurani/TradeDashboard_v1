//
//  PieChartView.swift
//  TradeDashboard_v1
//
//  Created by Zeshan Nurani on 2023-08-22.
//

import SwiftUI
import Charts

struct StockHolding: Identifiable {
        var symbol: String
        var marketValue: Double
        var id = UUID()
    }

var data: [StockHolding] = [
    .init(symbol: "AAPL", marketValue: 1500.50),
    .init(symbol: "MSFT", marketValue: 2500.75),
    .init(symbol: "AMZN", marketValue: 1800.20),
    .init(symbol: "TSLA", marketValue: 3500.0)
]

struct PieChartView: View {
    var body: some View {
        VStack{
            HStack{
                Chart(data, id: \.symbol) { data in
                    SectorMark(
                        angle: .value("Symbol", data.marketValue),
                        angularInset: 1.5
                    )
                    .cornerRadius(7)
                    .foregroundStyle(by: .value("Value", data.marketValue))
                
                    
                }
            }.padding()
        }
    }
}

#Preview {
    PieChartView()
}
