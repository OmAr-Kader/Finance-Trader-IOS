//
//  BottomBar.swift
//  BottomBar
//
//  Created by Bezhan Odinaev on 7/2/19.
//  Copyright © 2019 Bezhan Odinaev. All rights reserved.
//

import SwiftUI

public struct BottomBar : View {
    public var selectedIndex: Int
    public var onSelected: (Int) -> ()
    
    public let backColor: Color
    public let items: [BottomBarItem]
    
    public init(selectedIndex: Int, items: [BottomBarItem], backColor: Color, onSelected: @escaping (Int) -> ()) {
        self.selectedIndex = selectedIndex
        self.items = items
        self.backColor = backColor
        self.onSelected = onSelected
    }
    
    
    public init(selectedIndex: Int, @BarBuilder items: () -> [BottomBarItem], backColor: Color, onSelected: @escaping (Int) -> ()){
        self = BottomBar(selectedIndex: selectedIndex,
                         items: items(), backColor: backColor, onSelected: onSelected)
    }
    
    
    public init(selectedIndex: Int, item: BottomBarItem, backColor: Color, onSelected: @escaping (Int) -> ()){
        self = BottomBar(selectedIndex: selectedIndex,
                         items: [item], backColor: backColor, onSelected: onSelected)
    }
    
    
    func itemView(at index: Int) -> some View {
        Button(action: {
            withAnimation { onSelected(index) }
        }) {
            BottomBarItemView(selected: self.selectedIndex,
                              index: index,
                              item: items[index])
        }
    }
    
    public var body: some View {
        VStack {
            Spacer().frame(height: 5)
            HStack(alignment: .bottom) {
                Spacer()
                ForEach(0..<items.count, id: \.self) { index in
                    self.itemView(at: index)
                    
                    if index != self.items.count-1 {
                        Spacer()
                    }
                }
                Spacer()
            }.animation(.default, value: selectedIndex)
        }.background(backColor).ignoresSafeArea()
    }
}
