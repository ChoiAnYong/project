//
//  MainView.swift
//  project
//
//  Created by 최안용 on 3/31/24.
//

import SwiftUI

struct MainView: View {
    @StateObject var pathModel: PathModel
    @State private var isTopDrag: Bool = true
    @State private var startingOffsetY: CGFloat = UIScreen.main.bounds.height * 0.78
    @State private var currentDragOffsetY: CGFloat = 0
    @State private var endingOffsetY: CGFloat = 0
    
    var body: some View {
        NavigationStack(path: $pathModel.paths) {
            ZStack {
                MapView()
                
                toolbarView(pathModel: pathModel)
                
                SheetView()
                    .offset(y: startingOffsetY)
                    .offset(y: currentDragOffsetY)
                    .offset(y: endingOffsetY)
                    .gesture(drag)
            }
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
    
    var drag: some Gesture {
        DragGesture()
            .onChanged({ value in
                withAnimation(.spring()) {
                    if isTopDrag {
                        currentDragOffsetY = value.translation.height
                    } else if value.translation.height > 0  {
                        currentDragOffsetY = value.translation.height
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

fileprivate struct toolbarView: View {
    @ObservedObject private var pathModel: PathModel
    
    init(pathModel: PathModel) {
        self.pathModel = pathModel
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    pathModel.paths.append(.setting)
                    
                }, label: {
                    CustomIcon(iconName: "settingIcon")
                })
                
                Spacer()
                
                Button(action: {
                    let tk = KeychainManager()
                    
                    guard let accessToken = tk.read("https://emgapp.shop/login/apple", account: "accessToken") else {
                        return
                    }
                    
                    print(accessToken)
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
    MainView(pathModel: PathModel())
}