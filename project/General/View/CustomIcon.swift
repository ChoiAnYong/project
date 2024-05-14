//
//  CustomIcon.swift
//  project
//
//  Created by 최안용 on 3/31/24.
//

import SwiftUI

struct CustomIcon: View {
    let iconName: String
    
    var body: some View {
        Image(iconName)
            .resizable()
            .frame(width: 20, height: 20)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 15)
                     .fill(Color.white)
            )
            .shadow(radius: 5)
    }
}

#Preview {
    CustomIcon(iconName: "settingIcon")
}
