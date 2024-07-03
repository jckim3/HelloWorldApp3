
//
//  ContentView.swift
//  HelloWorldApp
//
//  Created by JC Kim on 7/1/24.
//

import SwiftUI

struct ContentView: View {
    @State private var message: String = "Hello, world! Carriage Motor Inn"

    var body: some View {
        VStack(spacing: 20) { // 간격을 추가하여 버튼 간의 간격을 벌림
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(message)
                .padding()

            Button(action: {
                // 첫 번째 버튼이 눌렸을 때 메시지 변경
                message = "Pressed Button 1"
            }) {
                Text("Button 1")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: {
                // 두 번째 버튼이 눌렸을 때 메시지 변경
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
}

#Preview {
    ContentView()
}
