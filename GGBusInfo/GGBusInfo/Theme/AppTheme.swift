//
//  AppTheme.swift
//  GGBusInfo
//
//  Created by sumin on 2/4/25.
//

import SwiftUI

struct AppTheme {
    // 앱 전반에서 사용하는 색상, 폰트 등 정의
    static let backgroundColor = Color(UIColor.systemGroupedBackground)
    static let primaryColor = Color.blue
    static let accentColor = Color.yellow
    static let textFieldBackground = Color(UIColor.systemGray6)
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppTheme.primaryColor)
            .foregroundColor(.white)
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding(8)
            .background(Color.white)
            .cornerRadius(8)
    }
}
