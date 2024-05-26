//
//  PlusCellView.swift
//  project
//
//  Created by 최안용 on 5/26/24.
//

import SwiftUI

struct PlusCellView: View {
    @ObservedObject private var mapViewModel: MapViewModel
    @State var showSheet: Bool = false
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    init(mapViewModel: MapViewModel) {
        self.mapViewModel = mapViewModel
    }
    
    var body: some View {
        Button(action: {
            showSheet.toggle()
        }, label: {
            VStack {
                Image(systemName: "plus")
                    .foregroundColor(.grayText)
                    
                Text("\n계정 연동하기")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.grayText)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .frame(width: screenWidth/5 * 4, height: screenHeight/5)
            .background(Color.grayCool)
            .cornerRadius(22)
        })
        .sheet(isPresented: $showSheet, content: {
            Text("d")
        })
    }
}

#Preview {
    PlusCellView(mapViewModel: .init(container: .init(services: StubService())))
}
