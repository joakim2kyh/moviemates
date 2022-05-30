//
//  Carousel.swift
//  MovieMates
//
//  Created by Denis Rakitin on 2022-05-26.
//

/**
 - Description: The struct that makes the carousel on the "discover" tab on HomeView. 
 */
import SwiftUI

struct Carousel<Content: View, T: Identifiable>: View {
    
    
    var content: (T) -> Content
    var list: [T]
    
    var spacing: CGFloat
    var trailingSpace: CGFloat
    @GestureState var offset: CGFloat = 0
    @State var currentIndex: Int = 0
    @Binding var index: Int
    
    init(spacing: CGFloat = 15, trailingSpace: CGFloat = 100, index: Binding<Int>, items: [T], @ViewBuilder content: @escaping (T)->Content){
        self.list = items
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self.content = content
        self._index = index
    }
    
    
    var body: some View {
        GeometryReader{proxy in
                   let width = proxy.size.width - ( trailingSpace - spacing )
                   let adjustMentWidth = (trailingSpace / 2) - spacing
                   
                   HStack (spacing: spacing) {
                       ForEach(list) { item in
                           content(item)
                               .frame(width: proxy.size.width - trailingSpace)
                       }

                   }
                   .padding(.horizontal, spacing)
                   .offset(x: (CGFloat(currentIndex) * -width) + ( currentIndex != 0 ? adjustMentWidth : 0 ) + offset)
                   .gesture(
                       DragGesture()
                           .updating($offset, body: { value, out, _ in
                               out = value.translation.width
                           })
                           .onEnded({ value in

                               let offsetX = value.translation.width
                            
                               let progress = -offsetX / width
                               let roundIndex = progress.rounded()
                           
                               currentIndex = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                               currentIndex = index
                           })
                           .onChanged({ value in
                               let offsetX = value.translation.width
                               let progress = -offsetX / width
                               let roundIndex = progress.rounded()
                           
                               index = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                           
                           })
                   )
                   
               }
               .animation(.easeInOut, value: offset == 0)
               
           }
    }
