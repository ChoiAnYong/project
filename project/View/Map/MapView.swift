//
//  MapView.swift
//  project
//
//  Created by 최안용 on 3/27/24.
//

import SwiftUI
import NMapsMap
import UIKit

struct MapView: View {
    @State var scrollToIndex = 0
    @EnvironmentObject private var container: DIContainer
    
    @ObservedObject var mainViewModel: MainViewModel
    
    @StateObject var mapViewModel: MapViewModel
    @StateObject var coordinator: Coordinator
    
    var body: some View {
        ZStack {
            NaverMap(coordinator: coordinator, mapViewModel: mapViewModel)
                .edgesIgnoringSafeArea(.all)
            
            locationBtnView
                .offset(x:0, y: UIScreen.main.bounds.height/5)
            
            userInfoView
                .shadow(radius: 5)
            
        }
        .onAppear {
            coordinator.checkIfLocationServiceIsEnabled()
            mapViewModel.send(action: .loadUserMarker(mainViewModel.users))
            
        }
    }
    
    var locationBtnView: some View {
        HStack {
            Spacer()
            Button {
                coordinator.moveMapToUserLocation()
            } label: {
                CustomIcon(iconName: "ic_locationBtn")
            }
        }
        .padding(.horizontal, 15)
    }
    
    var userInfoView: some View {
        VStack {
            Spacer()
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader {proxy in
                    LazyHStack(spacing: 20) {
                        ForEach(mapViewModel.userMarkerList, id: \.self) { user in
                            UserInfoCellView(user)
                                .containerRelativeFrame(.horizontal, count: 1, spacing: 10)
                                .id(user.id)
                                .onTapGesture {
                                    mapViewModel.selectedUser = user
                                }
                        }
                    }
                    .scrollTargetLayout()
                    .onChange(of: mapViewModel.selectedUser) { oldValue, newValue in
                        withAnimation {
                            proxy.scrollTo(newValue?.id, anchor: .center)
                        }
                    }
                    
                }
            }
            .safeAreaPadding(.horizontal, 40)
            .frame(height: 160)
            .scrollTargetBehavior(.viewAligned)
            .scrollBounceBehavior(.always)
        }
    }
}

private struct UserInfoCellView: View {
    var user: UserMarker
    
    fileprivate init(_ user: UserMarker) {
        self.user = user
    }
    
    
    fileprivate var body: some View {
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
        .background(Color.grayCool)
        .cornerRadius(22)
    }
}

struct NaverMap: UIViewRepresentable {
    @EnvironmentObject private var mainViewModel: MainViewModel
    @ObservedObject private var mapViewModel: MapViewModel
    
    private var coordinator: Coordinator
    
    init(coordinator: Coordinator, mapViewModel: MapViewModel) {
        self.coordinator = coordinator
        self.mapViewModel = mapViewModel
        coordinator.setMarker(markers: mapViewModel.userMarkerList)
    }
    
    func makeCoordinator() -> Coordinator {
        coordinator
    }
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        coordinator.getNaverMapView()
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        
    }
}



#Preview {
    MapView(mainViewModel: MainViewModel(container: .init(services: StubService())), mapViewModel: MapViewModel(), coordinator: Coordinator(container: DIContainer(services: StubService())))
        .environmentObject(MainViewModel(container: .init(services: StubService())))
}
