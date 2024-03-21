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
        TabView(selection: $selectedTab) {
            ForEach(MainTabType.allCases, id: \.self) { tab in
                Group {
                    switch tab {
                    case .home:
                        Text("home")
                    case .alarm:
                        Text("alarm")
                    case .setting:
                        Text("settign")
                    }
                }
                .tabItem {
                    Label( tab.title,
                           image: "person")
                }
                .tag(tab)
            }
        }
    }
}

#Preview {
    MainTabView()
}
