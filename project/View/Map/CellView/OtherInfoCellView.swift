//
//  OtherInfoCellView.swift
//  project
//
//  Created by 최안용 on 5/26/24.
//

import SwiftUI

struct OtherInfoCellView: View {
    var user: UserMarker
    @Binding var centerVisibleUser: UserMarker?
    @ObservedObject private var mapViewModel: MapViewModel
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    init(user: UserMarker, centerVisibleUser: Binding<UserMarker?>, mapViewModel: MapViewModel) {
        self.user = user
        self._centerVisibleUser = centerVisibleUser
        self.mapViewModel = mapViewModel
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                URLImageView(urlString: user.imgUrl)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(user.name)")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.bkFix)
                    
                    Text("\(user.address ?? "")")
                        .font(.system(size: 15))
                        .foregroundStyle(.grayText)
                    
                    HStack(spacing: 5) {
                        Image(.icLocationText)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 13, height: 13)
                            .foregroundColor(.gray)
                        
                        Text("500m")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.grayText)
                    }
                }
                Spacer()
            }
            
            Spacer()
                .frame(height: 10)
            
            Button(action: {
                
            }, label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.appOrange)
                    Text("알림 보기")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.whFix)
                }
                .frame(height: 55)
            })                                    
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .frame(width: screenWidth/5 * 4, height: screenHeight/5)
        .background(Color.grayCool)
        .cornerRadius(22)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        updateCenterCell(with: geo)
                    }
                    .onChange(of: geo.frame(in: .global)) {
                        updateCenterCell(with: geo)
                    }
            }
        )
    }
    
    func updateCenterCell(with geo: GeometryProxy) {
        let screenMidX = UIScreen.main.bounds.midX
        if abs(geo.frame(in: .global).midX - screenMidX) < geo.size.width / 2 {
            DispatchQueue.main.async {
                centerVisibleUser = user
            }
        }
    }
}

#Preview {
    OtherInfoCellView(user: .stubMarker2, centerVisibleUser: .constant(.stubMarker1),
                      mapViewModel: MapViewModel(container: .init(services: StubService())))
    .environmentObject(DIContainer(services: StubService()))
}
