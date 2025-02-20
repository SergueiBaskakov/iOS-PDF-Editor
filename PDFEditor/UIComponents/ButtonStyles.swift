//
//  ButtonStyles.swift
//  PDFEditor
//
//  Created by Serguei Diaz on 18.02.2025.
//

import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {
    
    public init(){}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(Color.teal)
            .overlay {
                Color.white.opacity(configuration.isPressed ? 0.2 : 0)
            }
            .cornerRadius(8)
            .shadow(radius: 4, x: 0, y: 4)

    }
}

public struct SecondaryButtonStyle: ButtonStyle {
    
    public init(){}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .foregroundColor(.teal)
            .background(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .inset(by: 0.5)
                    .stroke(.teal)
            )
            .overlay {
                Color.black.opacity(configuration.isPressed ? 0.2 : 0)
            }
            .cornerRadius(8)
            .shadow(radius: 4, x: 0, y: 4)
    }
}

public struct AlertButtonStyle: ButtonStyle {
    
    public init(){}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(Color.red)
            .overlay {
                Color.white.opacity(configuration.isPressed ? 0.2 : 0)
            }
            .cornerRadius(8)
            .shadow(radius: 4, x: 0, y: 4)

    }
}
