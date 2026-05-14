import SwiftUI
import KeyboardShortcuts
import ServiceManagement
import AppKit

struct SettingsView: View {
    let dataFileURL: URL

    @EnvironmentObject private var localizer: Localizer
    @State private var launchAtLogin: Bool = (SMAppService.mainApp.status == .enabled)
    @State private var loginToggleError: String?

    var body: some View {
        Form {
            Section(localizer.t(.settingsKeyboardShortcuts)) {
                LabeledContent(localizer.t(.settingsToggleCapture)) {
                    KeyboardShortcuts.Recorder(for: .toggleCapture)
                }
            }

            Section(localizer.t(.settingsLanguage)) {
                Picker(localizer.t(.settingsLanguage), selection: $localizer.language) {
                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                        Text(lang.displayName(in: localizer.effective)).tag(lang)
                    }
                }
                .labelsHidden()
                .pickerStyle(.segmented)
            }

            Section(localizer.t(.settingsLaunch)) {
                Toggle(localizer.t(.settingsLaunchAtLogin), isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        applyLaunchAtLogin(newValue)
                    }
                if let err = loginToggleError {
                    Text(err)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Section(localizer.t(.settingsData)) {
                LabeledContent(localizer.t(.settingsPath)) {
                    HStack {
                        Text(dataFileURL.path)
                            .font(.callout.monospaced())
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .textSelection(.enabled)
                        Button {
                            NSWorkspace.shared.activateFileViewerSelecting([dataFileURL])
                        } label: {
                            Image(systemName: "folder")
                        }
                        .buttonStyle(.borderless)
                        .help(localizer.t(.settingsShowInFinder))
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 480, height: 360)
        .padding()
    }

    private func applyLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            loginToggleError = nil
        } catch {
            loginToggleError = localizer.t(.settingsLaunchError(error.localizedDescription))
        }
    }
}
