//
//  homeView.swift
//  ImageMapApp
//
//  Created by William Chin on 11/12/22.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct homeView: View {
    @State var expand = false
    @State var search = " "
    @ObservedObject var RandomImages = getData()
    @State var page = 1
    @State var isSearching = false
    
    var body: some View {
        VStack (spacing: 0){

            HStack {
                //Hiding view when search bar is expanded
                if !self.expand {
                    VStack(alignment: .leading, spacing:8) {
                        Text("PhotoApp")
                            .font(.title)
                            .fontWeight(.bold)
                        
                    }
                    .foregroundColor(.black)
                }
                
                
                Spacer(minLength: 0)
                
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .onTapGesture {
                        withAnimation{
                            self.expand = true
                        }
                    }
                
                //Displaying Textfield when search bar is expanded
                if self.expand {
                    TextField("Search...", text: self.$search)
                    
                    //displaying Close button
                    
                    //displaying search button when search text is not empty
                    if self.search != "" {
                        Button (action: {
                            
                            //search content
                            self.RandomImages.Images.removeAll()
                            self.isSearching = true
                            self.page = 1
                            self.SearchData()
                             
                        }) {
                            Text("Find")
                                .fontWeight(.bold)
                                .foregroundColor(.black )
                        }
                    }
                    Button(action: {
                        withAnimation {
                            self.expand = false
                        }
                        self.search = ""
                        if self.isSearching {
                            self.isSearching = false
                            self.RandomImages.Images.removeAll()
                            self.RandomImages.updateData()
                        }
                            
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15,weight: .bold))
                            .foregroundColor(.black)
                    }
                    .padding(.leading,10)
                }
                
                
            }
            
            .padding(.top, getSafeAreaTop())
            .padding()
            .background(Color.white)
            
            if self.RandomImages.Images.isEmpty {
                //Data loading/No data
                
                Spacer()
                if self.RandomImages.noresults {
                    Text("No Reuslts Found")
                }
                else {
                    
                    Indicator()
                }
                
                Spacer()
            }
            else {
                ScrollView(.vertical, showsIndicators: false) {
                    //Collection View
                    
                    VStack(spacing:15) {
                        ForEach(self.RandomImages.Images, id: \.self) { i in
                            HStack(spacing: 20) {
                                ForEach(i) { j in
                                    AnimatedImage(url: URL(string: j.urls["thumb"]!))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    //padding on both sides 30 and spacing 20
                                    .frame(width: (UIScreen.main.bounds.width - 50)/2, height: 200)
                                    .cornerRadius(15)
                                    .contextMenu {
                                            
                                        //Save Button
                                        Button(action: {
                                            //Saving Image
                                            SDWebImageDownloader()
                                                .downloadImage(with: URL(string:j.urls["small"]!)) { (image, _, _,_)
                                                    in
                                                    
                                                UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                                            }
                                        }) {
                                            HStack {
                                                Text("Save")
                                                Spacer()
                                                Image (systemName: "square.and.arrow.down.fill")
                                            }
                                            .foregroundColor(.black)
                                        }
                                    }
                                }
                            }
                        }
                        
                        //Load More Photos
                        
                        if !self.RandomImages.Images.isEmpty {
                            
                            if self.isSearching && self.search != "" {
                                HStack {
                                    Text ("Page \(self.page)")
                                    Spacer()
                                    
                                    Button(action: {
                                        //update view
                                        self.RandomImages.Images.removeAll()
                                        self.page+=1
                                        self.SearchData()
                                    }) {
                                        Text("Load More")
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                    }
                                }
                                .padding(.horizontal,25)
                            }
                        }
                        else {
                                HStack {
                                    Spacer()
                                    
                                    Button(action: {
                                        //update view
                                        self.RandomImages.Images.removeAll()
                                        self.RandomImages.updateData()
                                    }) {
                                        Text("Load More")
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                    }
                                }
                                .padding(.horizontal,25)
                            
                        }
                    }
                }
                .padding(.top)
                Spacer()
            }
        }
        .background(Color.black.opacity(0.07).edgesIgnoringSafeArea(.all))
        .edgesIgnoringSafeArea(.top)
    }
    
    func SearchData() {
        
        let key = "ENv1oixrvWq3TvHXDDZlaFqlIw5CwG-UXR5xqWfk8CI"
        let query = self.search.replacingOccurrences(of:  " ", with: "&20")
        let url = "https://api.unsplash.com/search/photos/?page=\(self.page)&query=\(query)&client_id=\(key)"
        self.RandomImages.SearchData(url: url)
    }
}

//fetching data
class getData: ObservableObject {
    //creating a collection view of 2D array
    @Published var Images : [[Photo]] = []
    @Published var noresults = false
    
    init() {
        updateData()
    }
    func SearchData(url: String) {
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: URL(string: url)!) { (data, _, error) in
            if error != nil {
                return
            }
            guard let data = data else {
                return
            }
            //JSON Decoding
            do {
                let json = try JSONDecoder().decode(SearchPhoto.self, from: data)
                
                if json.results.isEmpty {
                    self.noresults = true
                }
                else {
                    self.noresults = false
                }
                
                //display 2 photos per row
                for i in stride(from: 0, to: json.results.count, by: 2) {
                    var ArrayData : [Photo] = []
                    
                    for j in i..<i+2 {
                        //index out of bound
                        if j < json.results.count {
                            ArrayData.append(json.results[j])
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.Images.append(ArrayData)
                    }
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func updateData() {
        
        self.noresults = false
        let key = "ENv1oixrvWq3TvHXDDZlaFqlIw5CwG-UXR5xqWfk8CI"
        let urlString = "https://api.unsplash.com/photos/random/?count=30&client_id=\(key)"
        guard let url = URL(string: urlString) else {
            return
        }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            //JSON Decoding
            do {
                let json = try JSONDecoder().decode([Photo].self, from: data)
                
                //display 2 photos per row
                for i in stride(from: 0, to: json.count, by: 2) {
                    var ArrayData : [Photo] = []
                    
                    for j in i..<i+2 {
                        //index out of bound
                        if j < json.count {
                            ArrayData.append(json[j])
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.Images.append(ArrayData)
                    }
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}

struct Photo: Identifiable, Decodable, Hashable {
    var id: String
    var urls : [String: String]
}
struct SearchPhoto: Decodable {
    var results : [Photo]
}
struct Indicator: UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .large)
        view.startAnimating()
        return view
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        
    }
}
func getSafeAreaTop()->CGFloat{
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        return (keyWindow?.safeAreaInsets.top) ?? 0
    }


struct homeView_Previews: PreviewProvider {
    static var previews: some View {
        homeView()
    }
}
