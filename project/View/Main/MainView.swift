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
    @StateObject var mainViewModel: MainViewModel
    @State private var isTopDrag: Bool = true
    @State private var isBottomDrag: Bool = false
    @State private var startingOffsetY: CGFloat = UIScreen.main.bounds.height * 0.78
    @State private var currentDragOffsetY: CGFloat = 0
    @State private var endingOffsetY: CGFloat = 0
    
    var body: some View {
        NavigationStack(path: $pathModel.paths) {
            contentView
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
    
    @ViewBuilder
    var contentView: some View {
        switch mainViewModel.phase {
        case .notRequested:
            PlaceholderView()
                .onAppear {
                    mainViewModel.send(action: .load)
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
            MapView()
                .environmentObject(mainViewModel)
            
            toolbarView
            
            SheetView(mainViewModel: mainViewModel)
                .offset(y: startingOffsetY)
                .offset(y: currentDragOffsetY)
                .offset(y: endingOffsetY)
                .gesture(drag)
        }
    }
    
    var toolbarView: some View {
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

#Preview {
    MainView(pathModel: PathModel(), mainViewModel: MainViewModel(container: .init(services: StubService())))
        .environmentObject(DIContainer(services: StubService()))
}
