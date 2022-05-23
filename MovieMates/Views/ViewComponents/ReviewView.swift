//
//  ReviewView.swift
//  MovieMates
//
//  Created by Oscar Karlsson on 2022-05-23.
//

import SwiftUI

struct ReviewCard: View {
    let review: Review
    var movieFS: MovieFS?
    @Binding var currentMovie: Movie?
    @Binding var showMovieView : Bool
    let displayName: Bool
    let displayTitle: Bool
    
    private let movieViewModel: MovieViewModel = MovieViewModel.shared
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color("secondary-background"))
            
            
            HStack {
                if let movie = movieFS {
                    AsyncImage(url: movie.photoUrl){ image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 100, height: 150, alignment: .center)
                    .border(Color.black, width: 3)
                    .onTapGesture {
                        loadMovie(id: movie.id!)
                        showMovieView = true
                    }
                }
                
                VStack(spacing: 0) {
                    ReviewInfo(review: review, displayName: displayName, displayTitle: displayTitle)
                    Spacer()
                }
            }
            .padding()
        }
    }
    
    func loadMovie(id: String) {
        currentMovie = nil
        movieViewModel.fetchMovie(id: Int(id)!) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let movie):
                    currentMovie = movie
                }
            }
        }
    }
}



struct ReviewInfo: View {
    let review: Review
    let displayName: Bool
    let displayTitle: Bool
    @State var fullText = false
    @State var lineLimit = 3
    let tagSize: CGFloat = 25
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5){
                HStack{
                    if displayName {
                        Text(um.getUser(id: review.authorId).username)
                    } else {
                        Text(um.getMovie(movieID: String(review.movieId))!.title)
                    }
                    Spacer()
                    Text(formatDate(date: review.timestamp))
                        .font(.system(size: 12))
                }
                if displayTitle && displayName {
                    Text(um.getMovie(movieID: String(review.movieId))!.title)
                }
                HStack{
                    ForEach(1..<6) { i in
                        ClapperImage(pos: i, score: "\(review.rating)")
                    }
                    Spacer()
                }
                Text(review.reviewText)
                    .font(.system(size: 15))
                    .lineLimit(lineLimit)
                    .onTapGesture {
                        withAnimation() {
                            if !fullText {
                                fullText = true
                                lineLimit = .max
                            } else {
                                fullText = false
                                lineLimit = 3
                            }
                        }
                    }
                
                Spacer()
                HStack {
                    if review.whereAt != "" || review.withWho != "" {
                        if review.whereAt == "home" {
                            Image(systemName: "house.circle")
                                .font(.system(size: tagSize))
                        } else if review.whereAt == "cinema" {
                            Image(systemName: "film.circle")
                                .font(.system(size: tagSize))
                        }
                        
                        if review.withWho == "alone" {
                            Image(systemName: "person.circle")
                                .font(.system(size: tagSize))
                        } else if review.withWho == "friends" {
                            Image(systemName: "person.2.circle")
                                .font(.system(size: tagSize))
                        }
                    } else {
                        Text("")
                    }
                    Spacer()
                    VStack(spacing: 0) {
                        LikeButton()
//                        Text("2")
//                            .font(.system(size: 12))
                    }
                }
            }
        }
    }
}

//struct ReviewTab: View {
//    
//    var body: some View {
//        
//    }
//}

struct ClapperImage: View {
    var pos : Int
    var score : String
    @State var filled : Bool = false
    
    var body: some View {
        Image("clapper-big")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(filled ? .black : .white)
            .onAppear(perform: {
                if Int(score.prefix(1)) ?? 0 >= pos {
                    filled = true
                } else {
                    filled = false
                }
            })
    }
}
