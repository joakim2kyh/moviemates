//
//  ProfileView.swift
//  MovieMates
//
//  Created by Gustav Söderberg on 2022-05-02.
//

import SwiftUI
import FirebaseAuth


struct ProfileView: View {
    
    @State var index = "reviews"
    @State private var showingSheet = false
    @State private var addFriend = false
    
    var body: some View {
        ZStack{
            Color("background")
                .ignoresSafeArea()
            
            VStack{
                
                ZStack{
                    
                    Text(um.currentUser!.username)
                        .font(.largeTitle)
                        .lineLimit(1)
                        .frame(width: 250)
                    
                    HStack{
                        Spacer()
                        
                        if um.currentUser!.authId != um.currentUser!.authId {
                            Button {
                                print("added friendo")
                            } label: {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .padding(.trailing, 20)
                            }
                            
                        } else {
                            
                            Button {
                                showingSheet = true
                            } label: {
                                Image(systemName: "slider.horizontal.3")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .padding(.trailing, 20)
                            }.sheet(isPresented: $showingSheet) {
                                SettingsSheet(showProfileSheet: $showingSheet)
                                
                            }
                        }
                    }
                    
                }
                Spacer()
                AsyncImage(url: um.currentUser!.photoUrl) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .cornerRadius(50)
                } placeholder: {
                    ProgressView()
                }
                Spacer()
                
                
                Picker(selection: $index,
                       label: Text("Reviews"),
                       content: {
                    Text("Reviews").tag("reviews")
                    Text("Watchlist").tag("watchlist")
                    Text("About").tag("about")
                    
                })
                    .padding()
                    .pickerStyle(SegmentedPickerStyle())
                    .colorMultiply(.red)
                
                
                switch index {
                case "reviews":
                    UserReviewView()
                case "watchlist":
                    WatchListView()
                case "about":
                    AboutMeView()
                default:
                    UserReviewView()
                }
                
                Spacer()
            }
        }
    }
    
}

struct UserReviewView: View {
    var body: some View{
        VStack{
            Text("Hej min favoritfilm är Batman!!")
            ScrollView{
                LazyVStack{
                    ForEach(myReviews) { review in
                        MyReviewCardView(review: review)
                    }
                }
                .padding()
            }
        }
    }
}

struct WatchListView: View {
    var body: some View{
        VStack{
            Text("Jag vill se den nya Dr Strange!!")
            ScrollView{
                LazyVStack{
                    //                    ForEach(watchlist) { movie in
                    //                        MovieCardView(movie: movie)
                    //                    }
                }
                .padding()
            }
        }
    }
}

struct AboutMeView: View {
    
    @State var bio: String = "this is my bio fix me later this is my bio fix me later this is my this is my bio fix me laterthis is my bio fix me laterthis is my bio fix me laterthis is my bio fix me laterthis is my bio fix me laterthis is my bio fix me laterthis is my bio fix me laterthis is my bio fix me laterbio fix me later"
    
    init() {
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View{
        VStack{
            ScrollView{
                HStack{
                    Text("Biography")
                        .font(.title2)
                        .padding()
                    Spacer()
                }
                ZStack(alignment: .leading){
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(Color("secondary-background"))
                        .frame(minHeight: 100)
                    
                    VStack{
                        if um.currentUser!.authId != um.currentUser!.authId {
                            Text(bio)
                                .padding()
                        }else if um.currentUser!.authId == um.currentUser!.authId {
                            TextEditor(text: $bio)
                                .background(Color("secondary-background"))
                                .foregroundColor(.white)
                                .frame(minHeight: 100)
                                .cornerRadius(25)
                            
                        }
                        
                        
                        Spacer()
                        
                    }
                }.padding()
                HStack{
                    Text("Summary of \(um.currentUser!.username)")
                        .font(.title2)
                        .padding()
                    Spacer()
                }
                
                ZStack(alignment: .leading){
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(Color("secondary-background"))
                        .frame(minHeight: 100)
                    
                    VStack{
                        Text("about blblblbbababa ska kasokdak ajsjd jiasd jiasdj as bla bla bla ")
                            .padding()
                        Spacer()
                    }
                }.padding()
            }
        }
    }
}




struct MyReviewCardView: View {
    
    let review: Review
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(.gray)
            HStack(alignment: .top){
                Image(systemName: "film")
                    .aspectRatio(CGSize(width: 2, height: 3), contentMode: .fit)
                    .frame(width: 100, height: 150, alignment: .center)
                    .border(Color.black, width: 3)
                VStack(alignment: .leading){
                    
                    Text(review.timestamp.formatted())
                        .font(.system(size: 12))
                        .frame(maxWidth: 1000, alignment: .trailing)
                    
                    Text(review.title)
                        .font(.title)
                    Text(review.rating)
                    Spacer()
                    Text(review.reviewText)
                        .font(.system(size: 15))
                        .lineLimit(3)
                    Spacer()
                }
                Spacer()
            }
            .padding()
        }
    }
}



private var myReviews = [
    Review(username: "Sarah", title: "The Batman", rating: "5/5", reviewText: "Siken film! jag grät, jag skrek, jag belv en helt ny människa!"),
    Review(username: "Sarah", title: "The Duckman", rating: "4/5", reviewText: "Jag gillar ankor så denna film var helt perfekt för mig! Dock så var det ett himla kvackande i biosalongen."),
    Review(username: "Sarah", title: "The Birdman", rating: "1/5", reviewText: "Trodde filmen skulle handla om en fågel som ville bli människa, men det var ju helt fel! Den handlar om en man som trodde han var en fågel. Falsk marknadsföring!"),
    Review(username: "Sarah", title: "The Spiderman", rating: "5/5", reviewText: "Jag somnade efter 30min och vaknade strax innan slutet. Bästa tuppluren jag haft på länge! Rekomenderas starkt!")
]

//private var watchlist = [
//    Movie(id: 1, adult: false, backdropPath: nil, genreIDS: nil, originalLanguage: nil, originalTitle: "spider man", overview: "fasdfdsafasdf", releaseDate: nil, posterPath: nil, popularity: nil, title: "Spooder-Man", video: nil, voteAverage: nil, voteCount: nil)
////    Movie(title: "Spooder-Man", description: "See spider man in one of his gazillion movies"),
////    Movie(title: "Star Wars A New Hope", description: "Small farm boy destoys big buisness"),
////    Movie(title: "Bill. A documentary", description: "From teacher to hero, follow this man on his journey through the world of computers")
//]

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

