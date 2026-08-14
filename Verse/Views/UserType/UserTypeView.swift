//
//  UserTypeView.swift
//  Verse
//

import SwiftUI

struct UserTypeView: View {
    var onBack: () -> Void = {}
    var onSkip: () -> Void = {}
    var onContinue: () -> Void = {}

    @State private var selectedMode: UserMode = .reader

    var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .top) {
                VerseColors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        CircularIconButton(systemImage: "chevron.left", action: onBack)

                        Spacer()

                        Button("Skip", action: onSkip)
                            .font(.system(size: 22, weight: .medium))
                            .frame(width: 84, height: 40)
                            .buttonStyle(.glass)
                            .buttonBorderShape(.capsule)
                            .controlSize(.large)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 6)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("How will you use Verse")
                            .font(VerseTypography.onboardingTitle)
                            .foregroundStyle(VerseColors.textMain)

                        Text("Choose your preferred mode")
                            .font(.system(size: 19, weight: .regular))
                            .foregroundStyle(VerseColors.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    VStack(alignment: .leading, spacing: 20) {
                        UserModeRow(
                            title: "Read, review, and explore books",
                            systemImage: "book",
                            isSelected: selectedMode == .reader
                        ) {
                            selectedMode = .reader
                        }

                        UserModeRow(
                            title: "Upload and publish your books",
                            systemImage: "pencil",
                            isSelected: selectedMode == .writer
                        ) {
                            selectedMode = .writer
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)

                    Spacer(minLength: 0)
                }

                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(VerseColors.textMain)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                }
                .buttonStyle(PrimaryActionButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .accessibilityLabel("Continue as \(selectedMode.accessibilityLabel)")
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    UserTypeView()
}

private enum UserMode {
    case reader
    case writer

    var accessibilityLabel: String {
        switch self {
        case .reader:
            "a reader"
        case .writer:
            "a writer"
        }
    }
}

private struct UserModeRow: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                SelectionIndicator(isSelected: isSelected)

                Text(title)
                    .font(.system(size: 18, weight: .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.88)
                
//                Image(systemName: systemImage)
//                    .font(.system(size: 20, weight: .regular))
//                    .frame(width: 32, height: 40)



                Spacer(minLength: 0)
            }
            .foregroundStyle(VerseColors.textMain)
            .contentShape(Rectangle())
        }
        .buttonStyle(UserModeButtonStyle())
        .accessibilityLabel(title)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }
}

private struct SelectionIndicator: View {
    let isSelected: Bool

    var body: some View {
        Circle()
            .fill(isSelected ? VerseColors.selectionRing : VerseColors.background)
            .frame(width: 22, height: 22)
            .overlay {
                Circle()
                    .fill(VerseColors.primaryAction)
                    .frame(width: 18, height: 18)
                    .opacity(isSelected ? 1 : 0)
            }
            .overlay {
                Circle()
                    .stroke(VerseColors.buttonBorder, lineWidth: isSelected ? 0 : 2)
            }
            .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}

private struct CircularIconButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(VerseColors.textMain)
                .frame(width: 40, height: 40)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .accessibilityLabel("Back")
    }
}

private struct UserModeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.58 : 1)
            .scaleEffect(configuration.isPressed ? 0.985 : 1, anchor: .leading)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

private struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(VerseColors.primaryAction, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.86 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}
