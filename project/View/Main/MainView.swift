//
//  MainView.swift
//  project
//
//  Created by 최안용 on 3/31/24.
//

import SwiftUI

struct MainView: View {
    @StateObject var pathModel: PathModel
    
    var body: some View {
        NavigationStack(path: $pathModel.paths) {
            ZStack {
                MapView()
                
                toolbarView(pathModel: pathModel)
                                
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
                    
                    
                }, label: {
                    CustomIcon(iconName: "phoneIcon")
                })
            }
            Spacer()
        }
        .padding(.horizontal, 15)
    }
}

fileprivate struct UserInfoView: View {
    var body: some View {
        VStack {
            Text("이름")
            Text("상태 메시지")
            Spacer()
        }
        .background(Color.red)
    }
}

#Preview {
    MainView(pathModel: PathModel())
}
