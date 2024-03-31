//
//  SheetView.swift
//  project
//
//  Created by 최안용 on 3/31/24.
//

import SwiftUI

struct ContentView: View {
    @State private var offset = UIScreen.main.bounds.height / 4
    @State private var isShowingDrawer = false
    
    var body: some View {
        ZStack {
            // Main content
            Color.white.edgesIgnoringSafeArea(.all)
            
            // Additional content (drawer)
            DrawerView()
                .offset(y: isShowingDrawer ? 0 : offset)
                .animation(.easeInOut)
        }
        .gesture(DragGesture()
                    .onChanged({ value in
                        if value.translation.height > 0 {
                            isShowingDrawer = true
                        }
                    })
                    .onEnded({ value in
                        if value.translation.height < offset / 2 {
                            isShowingDrawer = true
                        } else {
                            isShowingDrawer = false
                        }
                    }))
    }
}

struct DrawerView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .foregroundColor(.gray)
            .frame(height: 200)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
