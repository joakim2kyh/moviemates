//
//  HomeView.swift
//  MovieMates
//
//  Created by Gustav Söderberg on 2022-05-02.
//

/**
 - Description: In this view we have three tabs. The first is for the profileView where information is about the current user. Second is the homeView where we have three tabs. Here we can find reviews that friends have made but also a tab where reviews from the whole app can be shown. The third tab is searchView, where we can search for a movie/serie and a user.
 
 */

import SwiftUI

struct HomeView: View {
    @AppStorage("darkmode") private var darkmode = true
    
    @State var index = "friends"
    @State var showMovieView = false
    @State var showProfileView = false
    @State var currentMovie: Movie? = nil
    @State var presentMovie: Movie? = nil
    @State var isUpcoming = false
    @State var userProfile: User? = nil
    
    @ObservedObject var viewModel = MovieListViewModel()
    @ObservedObject var orm = rm
    
    var body: some View {
        ZStack{
            Color("background")
                .ignoresSafeArea()
            
            VStack{
                Picker(selection: $index, label: Text("Review List"), content: {
                    Text("Friends").tag(FRIENDS)
                    Text("Trending").tag(TRENDING)
                    Text("Discover").tag(DISCOVER)
                    
                })
                .padding(.horizontal)
                .padding(.top, 20)
                .pickerStyle(SegmentedPickerStyle())
                .colorMultiply(Color("accent-color"))
                
                ScrollView{
                    LazyVStack {
                        switch index {
                            
                        case FRIENDS:
                            ForEach(orm.groupReviews(reviews: orm.getAllReviews(onlyFriends: true)), id: \.self) { reviews in
                                if reviews.count == 1 {
                                    ReviewCard(review: reviews[0], movieFS: rm.getMovieFS(movieId: "\(reviews[0].movieId)"), currentMovie: $currentMovie, showMovieView: $showMovieView, userProfile: $userProfile, showProfileView: $showProfileView, displayName: true, displayTitle: true, blurSpoiler: true)
                                } else {
                                    GroupHeader(reviews: reviews, currentMovie: $currentMovie, showMovieView: $showMovieView, userProfile: $userProfile, showProfileView: $showProfileView, blurSpoiler: true)
                                }
                            }
                            
                        case TRENDING:
                            ForEach(orm.groupReviews(reviews: orm.getAllReviews(onlyFriends: false)), id: \.self) { reviews in
                                if reviews.count == 1 {
                                    ReviewCard(review: reviews[0], movieFS: rm.getMovieFS(movieId: "\(reviews[0].movieId)"), currentMovie: $currentMovie, showMovieView: $showMovieView, userProfile: $userProfile, showProfileView: $showProfileView, displayName: true, displayTitle: true, blurSpoiler: true)
                                } else {
                                    GroupHeader(reviews: reviews, currentMovie: $currentMovie, showMovieView: $showMovieView, userProfile: $userProfile, showProfileView: $showProfileView, blurSpoiler: true)
                                }
                            }
                            
                        case DISCOVER:
                            DicoverView()
                        default:
                            ForEach(friendsReviews) { review in
                                ReviewCard(review: review, movieFS: rm.getMovieFS(movieId: "\(review.movieId)"), currentMovie: $currentMovie, showMovieView: $showMovieView, userProfile: $userProfile, showProfileView: $showProfileView, displayName: true, displayTitle: true, blurSpoiler: true)
                            }
                        }
                    }
                    .padding()
                    .sheet(isPresented: $showMovieView) {
                        
                        if let currentMovie = currentMovie {
                            MovieViewController(movie: currentMovie, isUpcoming: isUpcoming, showMovieView: $showMovieView)
                            
                                .preferredColorScheme(darkmode ? .dark : .light)
                        }
                    }
                    .sheet(isPresented: $showProfileView) {
                        if let userProfile = userProfile {
                            ProfileView(user: userProfile)
                                .preferredColorScheme(darkmode ? .dark : .light)
                        }
                    }
                }
            }
        }
    }
}



func formatDate(date: Date) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d MMMM yyyy"
    return dateFormatter.string(from: date)
}


private var friendsReviews = [Review]()

private var trendingReviews = [Review]()
