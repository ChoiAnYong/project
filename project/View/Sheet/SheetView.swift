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
            topView()
            
            SheetScrollView()
        }
        .background(Color.grayCool)
        .cornerRadius(15)
        .shadow(radius: 6)
        
    }
}

fileprivate struct topView: View {
    var body: some View {

            Image("minusIcon")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.grayLight)
                .frame(width: 50, height: 40)

        .background(Color.grayCool)
    }
}

fileprivate struct SheetScrollView: View {
    let ex: [Int] = [Int](0..<100)
    
    var body: some View {
        ScrollView {
            UserInfoView()
            
            LazyVStack {
                ForEach(ex, id: \.self) { ex in
                    Text("\(ex)")
                }
            }
            .padding(.all, 8)
            .background(RoundedRectangle(cornerRadius: 18).foregroundColor(Color.white))
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .scrollIndicators(.hidden)
        .padding(.bottom, 50)
        
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
        .padding(.all, 8)
        .background(RoundedRectangle(cornerRadius: 18).foregroundColor(Color.white))
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
}

//fileprivate struct OtherInfoView: View {
//    
//    var body: some View {
//        ScrollView {
//            
//        }
//       
//    }
//}


#Preview {
    SheetView()
}
