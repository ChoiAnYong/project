//
//  PlusUserView.swift
//  project
//
//  Created by 최안용 on 5/27/24.
//

import SwiftUI

struct PlusUserView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: PlusUserViewModel
    @FocusState private var isFocused: Bool
    private let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("친구 이메일", text: $viewModel.email)
                    .frame(width: screenWidth - 50)
                    .focused($isFocused)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .padding(.top, 10)
                
                Rectangle()
                    .frame(width: screenWidth - 50, height: 1)
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(.icClose)
                            .renderingMode(.template)
                            .foregroundColor(.bkFix)
                    })
                }
                ToolbarItem(placement: .principal) {
                    Text("이메일로 친구 추가")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.bkFix)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        // TODO: - 친구 요청 전송
                    }, label: {
                        Text("확인")
                            .font(.system(size: 19))
                            .foregroundColor(.grayText)
                    })
                }
            }
        }

        .background(Color.grayCool)
        .onTapGesture {
            isFocused = false
        }
        
        .onAppear {
            isFocused = true
        }
    }
}

#Preview {
    PlusUserView(viewModel: PlusUserViewModel())
}
