//
//  NavigationRoutingView.swift
//  project
//
//  Created by 최안용 on 7/2/24.
//

import SwiftUI

struct NavigationRoutingView: View {
    @EnvironmentObject var container: DIContainer
    @State var destination: NavigationDestination
    
    var body: some View {
        switch destination {
        case .setting:
            SettingView(viewModel: .init(container: container))
        case .friendList:
            Text("친구뷰")
        }
    }
}
