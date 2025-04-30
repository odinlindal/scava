//
//  ColoredSectionListView.swift
//  scava
//
//  Created by Odin Lindal on 4/29/25.
//

import SwiftUI

struct ColoredSectionListView<Content: View>: View {
    let title: String
    let content: Content
    
    init(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        Section(
            // Custom header view with its own background & text color
            header:
                Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Theme.primary.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 6)
                //.background(Theme.primary.opacity(0.05))
        ) {
            // Your rows…
            content
            // Row text color
                .foregroundColor(Theme.primary)
            // Row background
                .listRowBackground(Theme.primary.opacity(0.05))
        }
        // Also ensure any section footers or extra rows get the same background
        .listRowBackground(Theme.primary.opacity(0.05))
    }
}

struct ColoredSectionListView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ColoredSectionListView(
                "Sample Section"
            ) {
                Text("Row One")
                Text("Row Two")
                Text("Row Three")
            }
        }
        .listStyle(.insetGrouped)
    }
}
