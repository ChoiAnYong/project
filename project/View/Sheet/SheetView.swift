//
//  SheetView.swift
//  project
//
//  Created by 최안용 on 3/31/24.
//

import SwiftUI

struct SheetView: View {
    @StateObject var sheetViewModel: SheetViewModel
    
    var body: some View {
        VStack {
            topView()
            UserInfoView(sheetViewModel: sheetViewModel)
            if sheetViewModel.users.isEmpty {
                BeginningView()
            } else {
                SheetScrollView(sheetViewModel: sheetViewModel)
                    .onAppear {
                        print("스크롤뷰")
                    }
            }
        }
        .background(Color.grayCool)
        .cornerRadius(15)
        .shadow(radius: 6)
        .ignoresSafeArea()
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
    @ObservedObject private var sheetViewModel: SheetViewModel
    
    fileprivate init(sheetViewModel: SheetViewModel) {
        self.sheetViewModel = sheetViewModel
    }
    
    var body: some View {
        ScrollView {
            
            
            OtherInfoCellListView(sheetViewModel: sheetViewModel)
            
            .padding(.all, 8)
            .background(RoundedRectangle(cornerRadius: 18).foregroundColor(Color.white))
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .scrollIndicators(.hidden)
        .padding(.bottom, 50)
        
    }
}

fileprivate struct BeginningView: View {
    var body: some View {
        VStack {
            Text("연동된 계정이 없습니다.")
            
        }
    }
}

fileprivate struct UserInfoView: View {
    @ObservedObject private var sheetViewModel: SheetViewModel
    
    fileprivate init(sheetViewModel: SheetViewModel) {
        self.sheetViewModel = sheetViewModel
    }
    
    var body: some View {
        HStack {
            Image("personIcon")
                .resizable()
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text(sheetViewModel.user.name )
                    .font(.system(size: 18, weight: .bold))
                
                Text(sheetViewModel.user.descriptino ?? "상태 메시지를 입력하세요")
                    .font(.system(size: 15, weight: .regular))
            }
            Spacer()
        }
        .padding(.all, 8)
        .background(RoundedRectangle(cornerRadius: 18).foregroundColor(Color.white))
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
}

fileprivate struct OtherInfoCellListView: View {
    @ObservedObject private var sheetViewModel: SheetViewModel
    
    fileprivate init(sheetViewModel: SheetViewModel) {
        self.sheetViewModel = sheetViewModel
    }
    
    var body: some View {
        LazyVStack {
            ForEach(sheetViewModel.users, id: \.self) { user in
                OtherInfoCellView(other: user)
            }
        }
    }
}

fileprivate struct OtherInfoCellView: View {
    private var other: User
    
    fileprivate init(other: User) {
        self.other = other
    }
    
    var body: some View {
        HStack {
            Image("personIcon")
                .resizable()
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text(other.name)
                    .font(.system(size: 18, weight: .bold))
                Text(other.descriptino ?? "상태 메시지를 입려하세요.")
                    .font(.system(size: 15, weight: .regular))
            }
            Spacer()
        }
    }
}

#Preview {
    SheetView(sheetViewModel: SheetViewModel(container: .init(services: StubService())))
}
