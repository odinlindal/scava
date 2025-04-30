//
//  SettingsRowView.swift
//  scava
//
//  Created by Odin Lindal on 4/26/25.
//

import SwiftUI

struct SettingsRowView: View {
    let imageName: String
    let title: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: imageName)
                .imageScale(.small)
                .font(.title)
                .foregroundColor(Color(Theme.primary))
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(Theme.primary)
        }
    }
}

#Preview {
    SettingsRowView(imageName: "gear", title: "Version")
}
