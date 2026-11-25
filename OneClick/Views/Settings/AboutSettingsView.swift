//
//  AboutSettingsView.swift
//  OneClick
//

import SwiftUI

struct AboutSettingsView: View {
    private var version: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "–"
        let build = info?["CFBundleVersion"] as? String ?? "–"
        return "Version \(short) (\(build))"
    }

    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 112, height: 112)
            Text("OneClick")
                .font(.largeTitle.weight(.semibold))
            Text(version)
                .foregroundStyle(.secondary)
            Text("Quick access to macOS settings from the menu bar.")
                .multilineTextAlignment(.center)
            Spacer()
            HStack(spacing: 12) {
                Link(destination: URL(string: "https://github.com/mik3sw/OneClick")!) {
                    Label("GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                }
                Link(destination: URL(string: "https://github.com/mik3sw/OneClick/issues")!) {
                    Label("Report an Issue", systemImage: "ladybug")
                }
            }
            .buttonStyle(.glass)
            Text("Made by mik3sw · Icon from Lucide (ISC License)")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}
