//
//  AppTheme.swift
//  GGBusInfo
//
//  Created by sumin on 2/4/25.
//

import SwiftUI

struct AppTheme {
    // 기존 시스템 색상
    static let backgroundColor = Color(UIColor.systemGroupedBackground)
    static let primaryColor = Color.blue
    static let accentColor = Color.yellow
    static let textFieldBackground = Color(UIColor.systemGroupedBackground)
    
    // Assets에 등록한 커스텀 색상
    // CustomBlack: 기본 하얀색, 다크모드시 검정색
    // CustomWhite: 기본 검정색, 다크모드시 하얀색
    // CustomGray: 기본 밝은 회색, 다크모드시 어두운 회색
    static let customBlack = Color("CustomBlack")
    static let customWhite = Color("CustomWhite")
    static let customGray = Color("CustomGray")
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppTheme.primaryColor)
            .foregroundColor(AppTheme.customBlack)
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
