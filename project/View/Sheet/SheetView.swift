//
//  SheetView.swift
//  project
//
//  Created by 최안용 on 3/31/24.
//

import SwiftUI

struct SheetView: View {
    var body: some View {
        VStack {
            Image("minusIcon")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.grayLight)
                .frame(width: 50, height: 40)
            
            UserInfoView()
            
            OtherInfoView()
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 6)
    }
}

fileprivate struct UserInfoView: View {
    var body: some View {
        HStack {
            Image("personIcon")
                .resizable()
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text("이름")
                    .font(.system(size: 18, weight: .bold))
                
                Text("상태메시지")
                    .font(.system(size: 18, weight: .regular))
            }
            Spacer()
        }
        .padding(.horizontal, 30)
    }
}

fileprivate struct OtherInfoView: View {
    let ex: [Int] = [1,2,3,4,5,6,7,8,9,10]
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(ex, id: \.self) { ex in
                    Text("\(ex)")
                }
            }
        }
    }
}


#Preview {
    SheetView()
}
