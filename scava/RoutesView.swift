//
//  RoutesView.swift
//  scava
//
//  Created by Odin Lindal on 1/19/25.
//
import SwiftUI

struct RoutesView: View {
    @State private var showRouteDetail = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Image("grcroute")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipped()
                            .cornerRadius(8)
                        
                        Text("Green River College")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            showRouteDetail.toggle()
                        }) {
                            Text("View Route")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.red)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
                .groupBoxStyle(RedGroupBoxStyle())
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Routes")
        .background(Color.red)
        .fullScreenCover(isPresented: $showRouteDetail) {
            RouteDetailView()
        }
    }
}

struct RedGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
        .padding(.top, 8)
        .background(Color.red.opacity(0.3))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    RoutesView()
}
