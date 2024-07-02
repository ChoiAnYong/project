//
//  SettingView.swift
//  project
//
//  Created by 최안용 on 3/31/24.
//

import SwiftUI

struct SettingView: View {
    @StateObject var viewModel: SettingViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                Text("dk")
            }
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        viewModel.send(action: .pop)
                    }, label: {
                        Image("ic_back")
                            .resizable()
                            .frame(width: 20, height: 20)
                    })
                }
                
                ToolbarItem(placement: .principal) {
                    Text("설정")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.bkFix)
                }
            }
        }
    }
}

#Preview {
    SettingView(viewModel: .init(container: .stub))
}

