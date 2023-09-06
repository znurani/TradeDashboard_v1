//
//  StockHoldingsView.swift
//  TradeDashboard_v1
//
//  Created by Zeshan Nurani on 2023-08-22.
//

import SwiftUI
import Charts

struct StockHoldingView: View {
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .foregroundColor(Color(.secondarySystemBackground))
            .frame(height: 200)
            .overlay(
                HStack{
                    VStack{
                        
                        VStack(alignment: .leading){
                            
                            Text("AAPL")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.top)
                            
                            
                            
                            Text("Apple Inc.")
                                .foregroundColor(.secondary)
                                .padding(.bottom, 1)
                            
                            
                            
                            Text("1234")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.bottom)
                        }
                        
                    }.padding(.leading, 5)
                    
                    
                    VStack{
                        Chart(){
                            LineMark(
                                x: .value("Month", "test"),
                                y: .value("Hours","test")
                            )
                        }
                    }
                }
            )
    }
}
        

#Preview {
    StockHoldingView()
}
