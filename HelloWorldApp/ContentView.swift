//
//  ContentView.swift
//  HelloWorldApp
//
//  Created by JC Kim on 7/1/24.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var message: String = "Hello, world! Carriage Motor Inn"
    @State private var cancellable: AnyCancellable?

    var body: some View {
        VStack(spacing: 20) { // 간격을 추가하여 버튼 간의 간격을 벌림
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(message)
                .padding()

            Button(action: {
                // 첫 번째 버튼이 눌렸을 때 API 호출
                fetchAvailableRoomsCount()
            }) {
                Text("Get # of Empty Room")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: {
                // 두 번째 버튼이 눌렸을 때 API 호출
                fetchCurrentMonthSales()
            }) {
                Text("Get Current Month Sales")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: {
                // 새로운 세 번째 버튼이 눌렸을 때 API 호출
                fetchRoomRentStatus()
            }) {
                Text("Get Room Rent Status")
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: {
                // 네 번째 버튼이 눌렸을 때 메시지 변경
                message = "Pressed Button 2"
            }) {
                Text("Button 2")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    func fetchAvailableRoomsCount() {
        guard let url = URL(string: "http://192.168.0.192:81/api/motel/available-rooms-count") else {
            message = "Invalid URL"
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
               .tryMap { result -> Data in
                   guard let response = result.response as? HTTPURLResponse else {
                       throw URLError(.badServerResponse)
                   }
                   print("Response status code: \(response.statusCode)")
                   guard response.statusCode == 200 else {
                       throw URLError(.badServerResponse)
                   }
                   return result.data
               }
               .decode(type: Int.self, decoder: JSONDecoder())
               .receive(on: DispatchQueue.main)
               .sink(
                   receiveCompletion: { completion in
                       switch completion {
                       case .finished:
                           break
                       case .failure(let error):
                           message = "Error: \(error.localizedDescription)"
                           print("Error: \(error)")
                       }
                   },
                   receiveValue: { availableRoomsCount in
                       message = "Available rooms count: \(availableRoomsCount)"
                   }
               )
       }

    func fetchCurrentMonthSales() {
        guard let url = URL(string: "http://192.168.0.192:81/api/motel/sales/current-month") else {
            message = "Invalid URL"
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
               .tryMap { result -> Data in
                   guard let response = result.response as? HTTPURLResponse else {
                       throw URLError(.badServerResponse)
                   }
                   print("Response status code: \(response.statusCode)")
                   guard response.statusCode == 200 else {
                       throw URLError(.badServerResponse)
                   }
                   return result.data
               }
               .decode(type: SalesResponse.self, decoder: JSONDecoder())
               .receive(on: DispatchQueue.main)
               .sink(
                   receiveCompletion: { completion in
                       switch completion {
                       case .finished:
                           break
                       case .failure(let error):
                           message = "Error: \(error.localizedDescription)"
                           print("Error: \(error)")
                       }
                   },
                   receiveValue: { salesResponse in
                       let formatter = NumberFormatter()
                       formatter.numberStyle = .decimal
                       formatter.maximumFractionDigits = 0 // 소수점 표시하지 않음

                       let formattedTotalPrice = formatter.string(from: NSNumber(value: salesResponse.totalPrice)) ?? "\(salesResponse.totalPrice)"
                       let formattedTotalCreditPrice = formatter.string(from: NSNumber(value: salesResponse.totalCreditPrice)) ?? "\(salesResponse.totalCreditPrice)"
                       let totalSales = salesResponse.totalPrice + salesResponse.totalCreditPrice
                       let formattedTotalSales = formatter.string(from: NSNumber(value: totalSales)) ?? "\(totalSales)"

                       message = "Current month sales - Cash: $\(formattedTotalPrice), Credit: $\(formattedTotalCreditPrice), Total: $\(formattedTotalSales)"
                   }
               )
       }

    func fetchRoomRentStatus() {
        guard let url = URL(string: "http://192.168.0.192:81/api/motel/rooms/payment-types") else {
            message = "Invalid URL"
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
               .tryMap { result -> Data in
                   guard let response = result.response as? HTTPURLResponse else {
                       throw URLError(.badServerResponse)
                   }
                   print("Response status code: \(response.statusCode)")
                   guard response.statusCode == 200 else {
                       throw URLError(.badServerResponse)
                   }
                   return result.data
               }
               .decode(type: PaymentTypeCounts.self, decoder: JSONDecoder())
               .receive(on: DispatchQueue.main)
               .sink(
                   receiveCompletion: { completion in
                       switch completion {
                       case .finished:
                           break
                       case .failure(let error):
                           message = "Error: \(error.localizedDescription)"
                           print("Error: \(error)")
                       }
                   },
                   receiveValue: { paymentTypeCounts in
                                          message = "Room Rent Status - Daily: \(paymentTypeCounts.da), Weekly: \(paymentTypeCounts.wk), Montly: \(paymentTypeCounts.mo), Week Voucher: \(paymentTypeCounts.wc), Master Lease: \(paymentTypeCounts.ml)"
                                      }
               )
       }
}

struct SalesResponse: Decodable {
    let totalPrice: Double
    let totalCreditPrice: Double
}

struct PaymentTypeCounts: Decodable {
    let da: Int
    let wk: Int
    let mo: Int
    let wc: Int
    let ml: Int
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

