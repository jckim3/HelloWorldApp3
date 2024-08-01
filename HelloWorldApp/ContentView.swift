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
    @State private var showAbout: Bool = false
    // Git 
    // Base URL 변수
    //private let baseURL = "http://192.168.0.192:81/api/motel"
    private let baseURL = "https://www.carriagemotorinn.com:444/api/motel"
    
    var body: some View {
        ZStack {
            // 배경 그라데이션
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // 최상단 메뉴 바
                HStack {
                    Text(currentDateString())
                        .padding()
                        .background(Color.clear)
                        .cornerRadius(10)
                        //.shadow(radius: 5)
                        .foregroundColor(.white) // 텍스트 색상 설정
                    Spacer()
                    Button(action: {
                        showAbout.toggle()
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .imageScale(.large)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10)
                }
                .padding(.top, topSafeAreaInset())
                .padding(.horizontal)
                
                Divider() // 메뉴 바와 콘텐츠를 구분하는 선
                
                // 나머지 콘텐츠
                VStack(spacing: 20) { // 간격을 추가하여 버튼 간의 간격을 벌림
                    Spacer()
                    
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    
                    Text(message)
                        .font(.headline) // 글꼴 크기 설정
                        .fontWeight(.bold) // 글꼴 굵기 설정
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        .foregroundColor(.black) // 텍스트 색상 설정
                        .multilineTextAlignment(.center) // 여러줄로 나누어 중앙 정렬
                        .lineLimit(nil) // 줄 수 제한 없음
                        .frame(maxWidth: .infinity) // 최대 너비 제한
                    /*Text("Info.plist Test Value: \(testValue)")
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        .foregroundColor(.black)*/
                    
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
                    
                    Spacer()
                }
                .padding()
            }
            
            if showAbout {
                aboutView
            }
        }
        .onAppear {
            fetchInitialMessage()
            readInfoPlist()
        }
    }
    
    var aboutView: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                .opacity(0.6) // 배경과 어우러지도록 투명도 설정
            VStack {
                Spacer()
                VStack(spacing: 20) {
                    Text("About This App")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("This is a demo app built with SwiftUI.")
                        .multilineTextAlignment(.center)
                        .padding()
                    Button(action: {
                        showAbout = false
                    }) {
                        Text("Close")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 20)
                .padding()
                Spacer()
            }
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
    
    func topSafeAreaInset() -> CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return 0 }
        guard let window = windowScene.windows.first else { return 0 }
        return window.safeAreaInsets.top
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
