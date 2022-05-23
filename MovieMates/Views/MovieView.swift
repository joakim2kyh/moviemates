//
//  MovieView.swift
//  MovieMates
//
//  Created by Oscar Karlsson on 2022-05-03.
//

import SwiftUI
import Alamofire
import UIKit

enum Sheet {
    case MovieView, ReviewSheet
}

struct MovieViewController: View {
    @State var sheetShowing: Sheet = .MovieView
    @State var movie: Movie
    @State var movieFS: MovieFS?
    @Binding var showMovieView: Bool
    
    var body: some View {
        
        VStack {
            switch self.sheetShowing {
                
            case .MovieView:
                MovieView(sheetShowing: $sheetShowing, currentMovie: $movie, showMovieView: $showMovieView, movieFS: $movieFS)
                
            case .ReviewSheet:
                ReviewSheet(sheetShowing: $sheetShowing, currentMovie: $movie)
            }
        }
        .interactiveDismissDisabled()
        .onAppear {
            if rm.checkIfMovieExists(movieId: "\(movie.id)") {
                movieFS = rm.getMovieFS(movieId: "\(movie.id)")
            }
        }
    }
}

struct MovieView: View {
    @AppStorage("darkmode") private var darkmode = true
    
    @Binding var sheetShowing: Sheet
    @Binding var currentMovie: Movie
    @Binding var showMovieView: Bool
    @Binding var movieFS: MovieFS?
    
    @State var friendsReviews = [Review]()
    
    @State var title : String = "Movie Title"
    @State var description : String = "Movie Description"
    @State var poster : Image = Image("bill_poster")
    @State var ratingGlobalScore : String = "0"
    @State var ratingLocalScore : String = "0"
    
    @State var onWatchlist = false
    @State var watchlistText  = "Add to Watchlist?"
    
    @State var descFull = false
    @State var descHeight: CGFloat? = 110
    
    @State var index = "friends"
    @State var watchlist = false
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Text("Done")
                        .foregroundColor(.clear)
                    VStack{
                        gap(height: 2)
                        Text(title)
                            .font(Font.headline.weight(.bold))
                            .multilineTextAlignment(.center)
                    }
                    Text("Review")
                        .foregroundColor(.clear)
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Done")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            showMovieView = false
                        }
                    Spacer()
                    Text("Review")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            sheetShowing = .ReviewSheet
                        }
                }
                .padding(.horizontal)
            }
            
            gap(height: 5)
            Divider()
            
            ScrollView {
                VStack {
                    AsyncImage(url: currentMovie.backdropURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: .infinity, height: 220, alignment: .center)
                    
                    Text(description)
                        .onTapGesture {
                            withAnimation() {
                                if !descFull {
                                    descFull = true
                                    descHeight = .infinity
                                }
                                else {
                                    descFull = false
                                    descHeight = 110
                                }
                            }
                        }
                        .frame(maxHeight: descHeight)
                }
                .padding(.horizontal)
                .frame(width: UIScreen.main.bounds.size.width)
                
                HStack {
                    Button {
                        if !onWatchlist {
                            watchlistText = "On Watchlist"
                            um.addToWatchlist(movieID: "\(currentMovie.id)")
                            onWatchlist = true
                        } else {
                            watchlistText = "Add to Watchlist"
                            um.removeMovieWatchlist(movieID: "\(currentMovie.id)")
                            onWatchlist =  false

                        }
                    } label: {
                        Text("\(watchlistText)")
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                            .background(onWatchlist ? Color("accent-color") : Color("secondary-background"))
                            .cornerRadius(5)
                            .font(Font.headline.weight(.bold))
                            .font(.system(size: 15))
                            .foregroundColor(darkmode ? .white : .black)
                    }
                    .onAppear {
                        onWatchlist = um.currentUser!.watchlist.contains("\(currentMovie.id)") ? true : false
                            watchlistText = um.currentUser!.watchlist.contains("\(currentMovie.id)") ? "On Watchlist" : "Add to Watchlist"
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.leading, 15)
                
                VStack(spacing:0){
                    ZStack{
                        Rectangle()
                            .cornerRadius(15)
                            .padding(.horizontal)
                            .frame(height: 90)
                            .foregroundColor(Color("secondary-background"))
                        
                        VStack(spacing:0) {
                            HStack{
                                Text("RATINGS")
                                    .font(Font.headline.weight(.bold))
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.leading, 12)
                            
                            Divider()
                                .padding(.horizontal)
                            
                            gap(height: 5)
                            
                            HStack{
                                Text("GLOBAL")
                                Spacer()
                                HStack(spacing: 2) {
                                    ForEach(1..<6) { i in
                                        ReviewClapper(pos: i, score: $ratingGlobalScore)
                                    }
                                }
                                .frame(height: 20)
                                
                                Text("\(ratingGlobalScore)")
                                    .frame(maxWidth: 30, alignment: .leading)
                                Spacer()
                            }
                            .padding(.horizontal, 30.0)
                            
                            gap(height: 5)
                            
                            HStack{
                                Text("FRIENDS")
                                Spacer()
                                HStack(spacing: 2) {
                                    ForEach(1..<6) { i in
                                        ReviewClapper(pos: i, score: $ratingLocalScore)
                                    }
                                }
                                .frame(height: 20)
                                
                                Text("\(ratingLocalScore)")
                                    .frame(maxWidth: 30, alignment: .leading)
                                Spacer()
                            }
                            .padding(.horizontal, 30.0)
                        }
                    }
                }
                
                Divider()
                
                VStack(spacing:0){
                    ZStack{
                        VStack(spacing: 0){
                            HStack{
                                Text("REVIEWS")
                                    .font(Font.headline.weight(.bold))
                                    //.foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.leading, 12)
                            
                            
                            
                            Picker(selection: $index, label: Text("Review List"), content: {
                                Text("Friends").tag("friends")
                                Text("Global").tag("global")
                            })
                            .padding(.horizontal, 14)
                            .pickerStyle(SegmentedPickerStyle())
                            .colorMultiply(Color("accent-color"))
                        }
                
                    }
                    
                    gap(height: 5)
                    
                    LazyVStack(spacing: 2) {
                        switch index {
                        case "friends":
                            if movieFS != nil {
                                ForEach(friendsReviews) { review in
                                    MovieReviewCardView(review: review)
                                }
                            } else {
                                Text("No Reviews")
                            }
                            
                        case "global":
                            if let movieFS = movieFS {
                                ForEach(movieFS.reviews) { review in
                                    MovieReviewCardView(review: review)
                                }
                            } else {
                                Text("No Reviews")
                            }
                            
                        default:
                            ForEach(friendsReviews) { review in
                                MovieReviewCardView(review: review)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .onAppear {
                        if let movieFS = movieFS {
                            friendsReviews = getFriendsReviews(movieFS: movieFS)
                        }
                    }
                }
            }
            
        }
        .onAppear(perform: {
            title = currentMovie.title ?? "Title"
            description = currentMovie.overview ?? "Description"
            //Search for "O", think it's the third movie
            if description == "" {
                description = "No further description"
            }
            
            ratingGlobalScore = "\(movieFS?.rating ?? 0.0)"
            ratingGlobalScore = String(ratingGlobalScore.prefix(3))
            ratingLocalScore = "\(rm.getAverageRating(movieId: currentMovie.id, onlyFriends: true))"
            ratingLocalScore = String(ratingLocalScore.prefix(3))
            ratingLocalScore = ratingLocalScore == "nan" ? "-" : ratingLocalScore
            
            if ratingGlobalScore.hasSuffix("0") {
                ratingGlobalScore = String(ratingGlobalScore.prefix(1))
            }
            
            if ratingLocalScore.hasSuffix("0") {
                ratingLocalScore = String(ratingLocalScore.prefix(1))
            }
        })
//        .onChange(of: sheetShowing, perform: { _ in
//            ratingLocalScore = "\(rm.getAverageRating(movieId: currentMovie.id, onlyFriends: true))"
//            ratingLocalScore = ratingLocalScore == "nan" ? "-" : ratingLocalScore
//
//            if ratingLocalScore.hasSuffix("0") {
//                ratingLocalScore = String(ratingLocalScore.prefix(1))
//            }
//        })
    }
}

func getFriendsReviews(movieFS: MovieFS) -> [Review]{
    var friendsReviews = [Review]()
    for review in movieFS.reviews {
        if um.currentUser!.friends.contains(review.authorId) {
            friendsReviews.append(review)
        }
    }
    return friendsReviews
}


struct ReviewClapper: View {
    var pos : Int
    @Binding var score : String
    @State var width : Float = 20
    
    var body: some View {
        GeometryReader { geo in
            Rectangle()
                .frame(width: 20, height: 20)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
            
            Rectangle()
                .frame(width: CGFloat(width), height: 20)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.black)
            
            Image("clapper_hollow")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(Color("secondary-background"))
        }
        .frame(width: 20, height: 20)
        .onAppear(perform: {
            if Int(score.prefix(1)) ?? 0 >= pos {
                width = 20
            } else if ((Int(score.prefix(1)) ?? 0) + 1) == pos {
                width = ((Float(score.prefix(3)) ?? 0) - (Float(score.prefix(1)) ?? 0))*20
            } else {
                width = 0
            }
            //print("pos: \(pos), score: \(score), width: \(width)")
        })
    }
}

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


struct MovieReviewCardView: View {
    
    let review: Review
    @State var fullText = false
    @State var lineLimit = 3
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color("secondary-background"))
            HStack(alignment: .top){
                VStack(alignment: .leading){
                    HStack{
                        Text(um.getUser(id: review.authorId).username)
                        Spacer()
                        Text(formatDate(date: review.timestamp))
                            .font(.system(size: 12))
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
                            } else if review.whereAt == "cinema" {
                                Image(systemName: "film.circle")
                            }
                            
                            if review.withWho == "alone" {
                                Image(systemName: "person.circle")
                            } else if review.withWho == "friends" {
                                Image(systemName: "person.2.circle")
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct gap :View {
    var height: CGFloat?
    var body: some View {
        Rectangle()
            .frame(height: height)
            .foregroundColor(.clear)
    }
}

struct line :View {
    var color: Color?
    var body: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(color)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}



//Preview!!
struct MovieView_Previews: PreviewProvider {
    static var previews: some View {
        MovieViewController(movie: Movie(id: 1, adult: nil, backdropPath: "/f53Jujiap580mgfefID0T0g2e17.jpg", genreIDS: nil, originalLanguage: nil, originalTitle: nil, overview: "Poe Dameron and BB-8 must face the greedy crime boss Graballa the Hutt, who has purchased Darth Vader’s castle and is renovating it into the galaxy’s first all-inclusive Sith-inspired luxury hotel.", releaseDate: nil, posterPath: "/fYiaBZDjyXjvlY6EDZMAxIhBO1I.jpg", popularity: nil, title: "LEGO Star Wars Terrifying Tales", video: nil, voteAverage: nil, voteCount: nil), showMovieView: .constant(true))
    }
}

 
