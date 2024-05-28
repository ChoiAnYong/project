//
//  MainView.swift
//  project
//
//  Created by 최안용 on 3/31/24.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var container: DIContainer
    @StateObject var pathModel: PathModel
    @StateObject var viewModel: MainViewModel

    var body: some View {
        NavigationStack(path: $pathModel.paths) {
            contentView
                .fullScreenCover(item: $viewModel.modalDestination) {
                    switch $0 {
                    case .myProfile:
                        MyProfileView()
                    case let .userAlarm(userEmail):
                        UserAlarmView(viewModel: .init(userEmail: userEmail, container: container))
                    case .plusUser:
                        PlusUserView(viewModel: PlusUserViewModel())
                    }
                }
                .navigationDestination(for: PathType.self) { pathType in
                    switch pathType {
                    case .setting:
                        SettingView()
                    }
                }
        }
        .environmentObject(viewModel)
    }
    
    @ViewBuilder
    var contentView: some View {
        switch viewModel.phase {
        case .notRequested:
            PlaceholderView()
                .onAppear {
                    viewModel.send(action: .load)
                }
        case .loading:
            LoadingView()
        case .success:
            loadedView
        case .fail:
            ErrorView()
        }
    }
    
    var loadedView: some View {
        ZStack {
            MapView(mapViewModel: MapViewModel(container: container, user: $viewModel.myUser), coordinator: Coordinator(container: container))

            toolbarView

        }
    }
    
    var toolbarView: some View {
        VStack {
            HStack {
                Button(action: {
                    pathModel.paths.append(.setting)

                }, label: {
                    CustomIcon(iconName: "ic_setting")
                })

                Spacer()

                Button(action: {
                    viewModel.send(action: .call)
                }, label: {
                    CustomIcon(iconName: "ic_phone")
                })
            }
            Spacer()
        }
        .padding(.horizontal, 15)
    }
}

#Preview {
    MainView(pathModel: PathModel(), viewModel: MainViewModel(container: .init(services: StubService())))
        .environmentObject(DIContainer(services: StubService()))
}
