//
//  SettingView.swift
//  project
//
//  Created by 최안용 on 3/31/24.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        VStack {
            Text("dk")
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: {
                    
                }, label: {
                    Image("ic_back")
                        .resizable()
                        .frame(width: 30, height: 30)
                        
                })
            }
        }
    }
}

#Preview {
    SettingView()
}

