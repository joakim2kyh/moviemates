//
//  ReviewManager.swift
//  MovieMates
//
//  Created by Gustav Söderberg on 2022-05-16.
//

import Foundation

class ReviewManager : ObservableObject {
    
    @Published var listOfMovieFS = [MovieFS]()
    @Published var refresh = 0
    
    func getReviews(movieId: Int, onlyFriends: Bool) -> [Review] {
        
        var reviewArray = [Review]()
        for movie in listOfMovieFS {
            
            if "\(movieId)" == movie.id!{
                
                if onlyFriends {
                    
                    for review in movie.reviews {
                        
                        if um.currentUser!.friends.contains(review.authorId) {
                            
                            reviewArray.append(review)
                            
                        }
                        
                    }
                }
                else {
                    
                    return movie.reviews
                    
                    
                }
                
            }
            
        }
        
        return reviewArray
    }
    
    func getAverageRating(movieId: Int, newReview: Bool, rating: Int, onlyFriends: Bool) -> Float {
        let allReviews = getReviews(movieId: movieId, onlyFriends: onlyFriends)
        var totalScore: Int = newReview ? rating : 0
        for review in allReviews {
            totalScore += review.rating
        }
        print("number of ratings: \(allReviews.count)")
        return Float(totalScore)/Float(allReviews.count)
    }
    
    func checkIfMovieExists(movieId: String) -> Bool {

        for movieFS in listOfMovieFS {
            
            if movieFS.id == movieId {
                
                return true
                
            }
        }
        
        return false
        
    }
    
    func saveReview(movie: Movie, rating: Int, text: String, whereAt: String, withWho: String) {
        

        if checkIfMovieExists(movieId: "\(movie.id)") {
            
            var newReview = true
            let review = Review(authorId: um.currentUser!.id!, movieId: movie.id, rating: rating, reviewText: text, whereAt: whereAt, withWho: withWho, timestamp: Date.now)
            
            var reviews = getReviews(movieId: movie.id, onlyFriends: false)
            
            for (index, review1) in reviews.enumerated() {
                if review1.authorId == um.currentUser!.id! {
                    reviews.remove(at: index)
                    newReview = false
                    break;
                }
            }
            
            //Updates Average Rating
            fm.updateAverageRating(movieId: movie.id, newReview: newReview, rating: rating)
            
            reviews.append(review)
            
            if fm.updateReviewsToFirestore(movieId: "\(movie.id)", reviews: reviews) {
                print("Successfully created a new movie with the new review")
            }
            else {
                print("E: ReviewManager - saveReview() Failed to create a new movie + add the review")
            }
            
        }
        else {
            
            let review = Review(authorId: um.currentUser!.id!, movieId: movie.id, rating: rating, reviewText: text, whereAt: whereAt, withWho: withWho, timestamp: Date.now)
            
            var reviews = getReviews(movieId: movie.id, onlyFriends: false)
            reviews.append(review)
            
            if fm.saveMovieToFirestore(movieFS: MovieFS(id: "\(movie.id)", title: movie.title!, photoUrl: movie.posterURL, rating: Double(rating), description: movie.overview!, reviews: reviews)) {
                print("Successfully added the review to an existing movie")
            }
            else {
                print("E: ReviewManager - saveReview() Failed to add review to an existing movie")
            }
        }
        
    }
    
    func getReview(movieId: String) -> Review {
        
        for movie in listOfMovieFS {
            if movie.id == movieId {
                for review in movie.reviews {
                    if review.authorId == um.currentUser!.id! {
                        return review
                    }
                }
            }
        }
        
        return Review(id: "\(UUID())", authorId: um.currentUser!.id!, movieId: 0, rating: 0, reviewText: "", whereAt: "", withWho: "", timestamp: Date.now)
    }
    
    func getMovieFS(movieId: String) -> MovieFS? {
        
        for movieFS in listOfMovieFS {
            if movieFS.id == movieId {
                return movieFS
            }
        }
        return nil
    }
}

