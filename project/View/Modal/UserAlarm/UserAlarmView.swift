//
//  UserAlarmView.swift
//  project
//
//  Created by 최안용 on 5/13/24.
//

import SwiftUI

struct UserAlarmView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: UserAlarmViewModel
    
    var body: some View {
        NavigationStack {
            Text("\(viewModel.userEmail)")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Text("Button")
                        })
                    }
                }
        }
    }
}

#Preview {
    UserAlarmView(viewModel: .init(userEmail: "d", container: DIContainer(services: StubService())))
}
