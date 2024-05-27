//
//  PlusUserView.swift
//  project
//
//  Created by 최안용 on 5/27/24.
//

import SwiftUI

struct PlusUserView: View {
    @StateObject var viewModel: PlusUserViewModel
    
    var body: some View {
        ZStack() {
            HeaderView()
            
            Text("이메일")
            TextField("이메일을 입력해주세요", text: $viewModel.email)
        }
        .toolbar {
            ToolbarItem {
                Image("")
            }
        }
    }
}

extension PlusUserView {
    private struct HeaderView: View {
        var body: some View {
            VStack {
                HStack {
                    Text("친구 추가")
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                }
                Spacer()
            }
            .padding(.horizontal, 30)
        }
    }
}

#Preview {
    PlusUserView(viewModel: PlusUserViewModel())
}
