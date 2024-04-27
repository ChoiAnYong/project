//
//  SheetView.swift
//  project
//
//  Created by 최안용 on 3/31/24.
//

import SwiftUI

struct SheetView: View {
    @ObservedObject var mainViewModel: MainViewModel
    
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
            }
        }
        .background(Color.grayCool)
        .cornerRadius(15)
        .shadow(radius: 6)
        .ignoresSafeArea()
    }
}

private struct topView: View {
    fileprivate var body: some View {
            Image("minusIcon")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.grayLight)
                .frame(width: 50, height: 40)

        .background(Color.grayCool)
    }
}

private struct SheetScrollView: View {
    @ObservedObject var mainViewModel: MainViewModel
    
    fileprivate init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }
    
    fileprivate var body: some View {
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

private struct BeginningView: View {
    fileprivate var body: some View {
        VStack {
            Spacer()
            Text("연동된 계정이 없습니다.")
            Text("")
            
            Button {
                
            } label: {
                Text("친구 추가")
                    .font(.system(size: 15))
                    .foregroundColor(.black)
                    .padding(.vertical, 9)
                    .padding(.horizontal, 24)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.appOrange)
            }
            Spacer()
        }
        .foregroundColor(.bkFix)
    }
}

private struct UserInfoView: View {
    @ObservedObject var mainViewModel: MainViewModel
    
    fileprivate init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }
    
    fileprivate var body: some View {
        HStack {
            Image("personIcon")
                .resizable()
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text(mainViewModel.myUser?.name ?? "이름")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.bkFix)
                
                Text(mainViewModel.myUser?.email ?? "이메일 없음")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.bkFix)
            }
            Spacer()
        }
        .padding(.all, 8)
        .background(RoundedRectangle(cornerRadius: 18).foregroundColor(Color.white))
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
}

private struct OtherInfoCellListView: View {
    @ObservedObject var mainViewModel: MainViewModel
    
    fileprivate init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }
    
    fileprivate var body: some View {
        LazyVStack {
            ForEach(mainViewModel.users, id: \.self) { user in
                OtherInfoCellView(other: user)
            }
        }
    }
}

private struct OtherInfoCellView: View {
    private var other: ConnectedUser
    
    fileprivate init(other: ConnectedUser) {
        self.other = other
    }
    
    fileprivate var body: some View {
        HStack {
            Image("personIcon")
                .resizable()
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text(other.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.bkFix)
                Text(other.email)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.bkFix)
            }
            Spacer()
        }
    }
}

#Preview {
    SheetView(mainViewModel: MainViewModel(container: .init(services: StubService())))
}
