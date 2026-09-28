//
//  CourtsView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import Combine

/// 网球场馆列表页。
struct CourtsView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header
                ForEach(app.courts) { court in
                    NavigationLink(destination: CourtDetailView(court: court)) {
                        CourtCard(court: court)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Theme.pagePadding)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Courts")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Theme.dark)
                Text("Book a court near you")
                    .font(.subheadline)
                    .foregroundColor(Theme.secondaryText)
            }
            Spacer()
        }
        .padding(.top, 4)
    }
}

/// 场馆卡片。
struct CourtCard: View {
    let court: Court

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AssetImage(name: court.imageName, fallbackSystemImage: "sportscourt")
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .clipped()

            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text(court.name)
                        .font(.headline)
                        .foregroundColor(Theme.dark)
                    Spacer()
                    Label(String(format: "%.1f", court.rating), systemImage: "star.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                Label(court.location, systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundColor(Theme.secondaryText)
                Label(court.openHours, systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(Theme.secondaryText)
                HStack {
                    Text(court.price)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Theme.primary)
                    Text("·")
                        .foregroundColor(Theme.secondaryText)
                    Text(court.surface)
                        .font(.caption)
                        .foregroundColor(Theme.secondaryText)
                }
            }
            .padding(13)
        }
        .background(Theme.card)
        .cornerRadius(Theme.cornerRadius)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}
