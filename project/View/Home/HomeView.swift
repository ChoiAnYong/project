//
//  HomeView.swift
//  project
//
//  Created by 최안용 on 3/25/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            ProfileView()
                .padding(.horizontal, 30)
        }
    }
}

fileprivate struct ProfileView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 7) {
                Text("이름")
                    .font(.system(size: 22, weight: .bold))
                Text("상태 메시지를 입력")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "person")
                .resizable()
                .frame(width: 42, height: 42)
                .background(Color.blue)
                .clipShape(Circle())
        }
    }
}

#Preview {
    HomeView()
}
