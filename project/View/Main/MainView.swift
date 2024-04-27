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
            ContentView(container: container, pathModel: pathModel, viewModel: viewModel)
                .navigationDestination(for: PathType.self) { pathType in
                    switch pathType {
                    case .myProfile:
                        Text("my")
                    case .otherProfile:
                        Text("other")
                    case .setting:
                        SettingView()
                    }
                }
        }
    }
}

private struct ContentView: View {
    @ObservedObject private var container: DIContainer
    @ObservedObject private var pathModel: PathModel
    @ObservedObject private var viewModel: MainViewModel

    fileprivate init(container: DIContainer, pathModel: PathModel, viewModel: MainViewModel) {
        self.container = container
        self.pathModel = pathModel
        self.viewModel = viewModel
    }

    @ViewBuilder
    fileprivate var body: some View {
        switch viewModel.phase {
        case .notRequested:
            PlaceholderView()
                .onAppear {
                    viewModel.send(action: .load)
                }
        case .loading:
            LoadingView()
        case .success:
            LoadedView(container: container, pathModel: pathModel, viewModel: viewModel)
        case .fail:
            ErrorView()
        }
    }
}

private struct LoadedView: View {
    @ObservedObject private var container: DIContainer
    @ObservedObject private var pathModel: PathModel
    @ObservedObject private var viewModel: MainViewModel
    @State private var isTopDrag: Bool = true
    @State private var isBottomDrag: Bool = false
    @State private var startingOffsetY: CGFloat = UIScreen.main.bounds.height * 0.78
    @State private var currentDragOffsetY: CGFloat = 0
    @State private var endingOffsetY: CGFloat = 0

    fileprivate init(container: DIContainer, pathModel: PathModel, viewModel: MainViewModel) {
        self.container = container
        self.pathModel = pathModel
        self.viewModel = viewModel
    }

    fileprivate var body: some View {
        ZStack {
            MapView()
                .environmentObject(viewModel)

            ToolbarView(pathModel: pathModel, viewModel: viewModel)

            SheetView(mainViewModel: viewModel)
                .offset(y: startingOffsetY)
                .offset(y: currentDragOffsetY)
                .offset(y: endingOffsetY)
                .gesture(drag)
        }
    }

    var drag: some Gesture {
        DragGesture()
            .onChanged({ value in
                withAnimation(.spring()) {
                    if isTopDrag {
                        currentDragOffsetY = value.translation.height
                    } else if value.translation.height > 0  {
                        currentDragOffsetY = value.translation.height
                    }

                    if currentDragOffsetY < -200 {
                        isTopDrag = false
                    }
                }
            })
            .onEnded({ value in
                withAnimation(.spring()) {
                    if currentDragOffsetY < -150 {
                        endingOffsetY = -UIScreen.main.bounds.height * 0.7
                        isTopDrag = false
                        currentDragOffsetY = .zero
                    } else if endingOffsetY != 0 && currentDragOffsetY > 150 {
                        isTopDrag = true
                        endingOffsetY = .zero
                        currentDragOffsetY = .zero
                    } else {

                        currentDragOffsetY = .zero
                    }
                }
            })
    }
}

private struct ToolbarView: View {
    @ObservedObject private var pathModel: PathModel
    @ObservedObject private var viewModel: MainViewModel

    fileprivate init(pathModel: PathModel, viewModel: MainViewModel) {
        self.pathModel = pathModel
        self.viewModel = viewModel
    }

    fileprivate var body: some View {
        VStack {
            HStack {
                Button(action: {
                    pathModel.paths.append(.setting)

                }, label: {
                    CustomIcon(iconName: "settingIcon")
                })

                Spacer()

                Button(action: {

                }, label: {
                    CustomIcon(iconName: "phoneIcon")
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
