//
//  SettingView.swift
//  project
//
//  Created by 최안용 on 3/31/24.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var pathModel: PathModel
    
    var body: some View {
        VStack {
            Text("dk")
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: {
                    pathModel.paths.removeLast()
                }, label: {
                    Image("ic_back")
                        .resizable()
                        .frame(width: 20, height: 20)
                })
            }
            
            
        }
        .navigationTitle("설정")
    }
}

#Preview {
    SettingView()
}

