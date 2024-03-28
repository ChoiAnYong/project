//
//  MainTabView.swift
//  project
//
//  Created by 최안용 on 3/20/24.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: MainTabType = .home
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                ForEach(MainTabType.allCases, id: \.self) { tab in
                    Group {
                        switch tab {
                        case .home:
                            HomeView(viewModel: HomeViewModel())
                        case .alarm:
                            MapView()
                        case .setting:
                            Text("settign")
                        }
                    }
                    .tabItem {
                        Label( tab.title,
                               systemImage: "person")
                    }
                    .tag(tab)
                }
            }
            
            SeperatorLineView()
        }
    }
}

fileprivate struct SeperatorLineView: View {
    var body: some View {
        VStack {
            Spacer()
            
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white, Color.grayLight]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 5)
                .padding(.bottom, 49)
        }
    }
}

#Preview {
    MainTabView()
}
