//
//  SheetView.swift
//  project
//
//  Created by 최안용 on 3/31/24.
//

import SwiftUI

struct SheetView: View {
    @ObservedObject private var mainViewModel: MainViewModel
    
    init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }
    
    var body: some View {
        VStack {
            topView()
            UserInfoView(mainViewModel: mainViewModel)
            if mainViewModel.users.isEmpty {
                BeginningView()
            } else {
                SheetScrollView(mainViewModel: mainViewModel)
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
    @ObservedObject private var mainViewModel: MainViewModel
    
    fileprivate init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }
    
    var body: some View {
        ScrollView {
            
            
            OtherInfoCellListView(mainViewModel: mainViewModel)
            
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
            Spacer()
            Text("연동된 계정이 없습니다.")
            Text("")
            
            Button(action: {
                
            }, label: {
                /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
            })
            Spacer()
        }
    }
}

fileprivate struct UserInfoView: View {
    @ObservedObject private var mainViewModel: MainViewModel
    
    fileprivate init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }
    
    var body: some View {
        HStack {
            Image("personIcon")
                .resizable()
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text(mainViewModel.myUser?.name ?? "이름")
                    .font(.system(size: 18, weight: .bold))
                
                Text(mainViewModel.myUser?.description ?? "상태 메시지를 입력하세요")
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
    @ObservedObject private var mainViewModel: MainViewModel
    
    fileprivate init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }
    
    var body: some View {
        LazyVStack {
            ForEach(mainViewModel.users, id: \.self) { user in
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
                Text(other.description ?? "상태 메시지를 입려하세요.")
                    .font(.system(size: 15, weight: .regular))
            }
            Spacer()
        }
    }
}

#Preview {
    SheetView(mainViewModel: MainViewModel(container: .init(services: StubService())))
}
