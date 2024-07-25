//
//  ContentView.swift
//  HelloWorldApp
//
//  Created by JC Kim on 7/1/24.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var message: String = "Loading..."
    @State private var cancellable: AnyCancellable?
    @State private var testValue: String = "Loading..."

    // Base URL 변수
    private let baseURL = "http://192.168.0.192:81/api/motel"
    //private let baseURL = "http://www.carriagemotorinn.com:81/api/motel"
    var body: some View {
        ZStack {
            // 배경 그라데이션
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) { // 간격을 추가하여 버튼 간의 간격을 벌림
                
                // 날짜를 오른쪽 상단에 표시
                HStack {
                    Spacer()
                    Text(currentDateString())
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .foregroundColor(.black) // 텍스트 색상 설정
                }
                .padding(.top, 20)
                .padding(.trailing, 20)
                
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                
                Text(message)
                    .font(.title) // 글꼴 크기 설정
                    .fontWeight(.bold) // 글꼴 굵기 설정
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .foregroundColor(.black) // 텍스트 색상 설정
                
                Text("Info.plist Test Value: \(testValue)")
                                    .padding()
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(10)
                                    .shadow(radius: 10)
                                    .foregroundColor(.black)
                Button(action: {
                    // 첫 번째 버튼이 눌렸을 때 API 호출
                    fetchAvailableRoomsCount()
                }) {
                    Text("Get # of Empty Room")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
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
                        .shadow(radius: 5)
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
                        .shadow(radius: 5)
                }
                
                
            }
            .padding()
        }
        .onAppear {
            fetchInitialMessage()
            readInfoPlist()
        }
    }
    
    func fetchInitialMessage() {
            guard let url = URL(string: "\(baseURL)/status") else {
                message = "Invalid URL"
                return
            }

        cancellable = URLSession.shared.dataTaskPublisher(for: url)
                    .tryMap { result -> String in
                        guard let response = result.response as? HTTPURLResponse else {
                            throw URLError(.badServerResponse)
                        }
                        print("Response status code: \(response.statusCode)")
                        guard response.statusCode == 200 else {
                            throw URLError(.badServerResponse)
                        }
                        return String(data: result.data, encoding: .utf8) ?? "Invalid data"
                    }
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
                        receiveValue: { fetchedMessage in
                            message = fetchedMessage
                        }
                    )
        }
    // 현재 날짜를 문자열로 반환하는 함수
    func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: Date())
    }
    
    func fetchAvailableRoomsCount() {
        //guard let url = URL(string: "https://carriagemotorinn.ddns.net:444/api/motel/available-rooms-count") else {
        guard let url = URL(string: "\(baseURL)/available-rooms-count") else {
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
        guard let url = URL(string: "\(baseURL)/sales/current-month") else {
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
        guard let url = URL(string: "\(baseURL)/rooms/payment-types") else {
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
                       message = "Rents- Daily: \(paymentTypeCounts.da), Weekly: \(paymentTypeCounts.wk), Monthly: \(paymentTypeCounts.mo), Week Voucher: \(paymentTypeCounts.wc), Master Lease: \(paymentTypeCounts.ml)"
                   }
               )
       }
    func readInfoPlist() {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            print("Info.plist path: \(path)")
            if let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
                print("Info.plist dictionary: \(dict)")
                testValue = dict["TestKey"] as? String ?? "No value found"
            } else {
                print("Failed to read Info.plist dictionary")
                testValue = "Unable to read Info.plist dictionary"
            }
        } else {
            print("Failed to find Info.plist path")
            testValue = "Unable to find Info.plist path"
        }
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

