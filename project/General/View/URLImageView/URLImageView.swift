//
//  URLImageView.swift
//  project
//
//  Created by 최안용 on 5/14/24.
//

import SwiftUI

struct URLImageView: View {
    @EnvironmentObject var container: DIContainer
    
    let urlString: String?
    let placeholderName = "ic_placeholder"
    
    init(urlString: String?) {
        self.urlString = urlString
    }
    
    var body: some View {
        if let urlString, !urlString.isEmpty {
            URLInnerView(viewModel: .init(urlString: urlString, container: container),
                         placeholderName: placeholderName)
                .id(urlString)
        } else {
            Image(placeholderName)
                .resizable()
                .background(Color.grayLight)
        }
    }
}

fileprivate struct URLInnerView: View {
    @StateObject var viewModel: URLImageViewModel
    
    let placeholderName: String
    
    var placeholderImage: UIImage {
        UIImage(named: placeholderName) ?? UIImage()
    }
    
    var body: some View {
        Image(uiImage: viewModel.loadedImage ?? placeholderImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .background(Color.grayLight)
            .onAppear {
                if !viewModel.loadingOrSuccess {
                    viewModel.start()
                }
            }
    }
}



#Preview {
    URLImageView(urlString: nil)
}
