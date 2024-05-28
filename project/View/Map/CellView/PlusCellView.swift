//
//  PlusCellView.swift
//  project
//
//  Created by 최안용 on 5/26/24.
//

import SwiftUI

struct PlusCellView: View {
    @EnvironmentObject private var mainViewModel: MainViewModel
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        Button(action: {
            mainViewModel.send(action: .presentView(.plusUser))
        }, label: {
            VStack {
                Image(systemName: "plus")
                    .foregroundColor(.grayText)
                    
                Text("\n친구 추가하기")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.grayText)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .frame(width: screenWidth/5 * 4, height: screenHeight/5)
            .background(Color.grayCool)
            .cornerRadius(22)
        })

    }
}

#Preview {
    PlusCellView()
        .environmentObject(MainViewModel(container: .init(services: StubService())))
}
