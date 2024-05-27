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
    @EnvironmentObject private var container: DIContainer
    @EnvironmentObject var mainViewModel: MainViewModel
    
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
        .sheet(isPresented: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Is Presented@*/.constant(false)/*@END_MENU_TOKEN@*/, content: {
            /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Content@*/Text("Sheet Content")/*@END_MENU_TOKEN@*/
        })
        .onAppear {
            coordinator.checkIfLocationServiceIsEnabled()
           
        }
        .onChange(of: mapViewModel.userMarkerList) { oldValue, newValue in
            coordinator.setMarker(markers: newValue)
        }
        .task {
            await mapViewModel.send(action: .loadUserMarker(mainViewModel.myUser ?? .init(name: "이름", email: ""),
                                                      mainViewModel.users))
        }
        
    }
    
    var locationBtnView: some View {
        HStack {
            Spacer()
            Button {
                coordinator.setPositionMode(mode: .direction)
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
                        MyInfoCellView(mapViewModel.myMarker ?? .stubMarker1,
                                       centerVisibleUser: $coordinator.centerVisibleUser,
                                       mapViewModel: mapViewModel)
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 10)
                            .id(mapViewModel.myMarker?.id)
                        
                        ForEach(mapViewModel.userMarkerList, id: \.self) { user in
                            OtherInfoCellView(user: user,
                                             centerVisibleUser: $coordinator.centerVisibleUser,
                                             mapViewModel: mapViewModel)
                                .containerRelativeFrame(.horizontal, count: 1, spacing: 10)
                                .id(user.id)
                        }
                        PlusCellView()
                    }
                    .scrollTargetLayout()
                    .onChange(of: coordinator.selectedUser) { oldValue, newValue in
                        withAnimation {                
                            proxy.scrollTo(newValue?.id, anchor: .center)
                        }
                    }
                    
                }
            }
            .safeAreaPadding(.horizontal, 40)
            .frame(height: UIScreen.main.bounds.height/5)
            .scrollTargetBehavior(.viewAligned)
            .scrollBounceBehavior(.always)
        }
    }
}

struct NaverMap: UIViewRepresentable {
    @EnvironmentObject private var mainViewModel: MainViewModel
    @ObservedObject private var mapViewModel: MapViewModel
    
    private var coordinator: Coordinator
    
    init(coordinator: Coordinator, mapViewModel: MapViewModel) {
        self.coordinator = coordinator
        self.mapViewModel = mapViewModel
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
    MapView(mapViewModel: MapViewModel(container: .init(services: StubService())), coordinator: Coordinator(container: DIContainer(services: StubService())))
        .environmentObject(MainViewModel(container: .init(services: StubService())))
}
