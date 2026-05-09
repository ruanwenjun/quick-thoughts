import SwiftUI
import KeyboardShortcuts
import ServiceManagement
import AppKit

struct SettingsView: View {
    let dataFileURL: URL

    @State private var launchAtLogin: Bool = (SMAppService.mainApp.status == .enabled)
    @State private var loginToggleError: String?

    var body: some View {
        Form {
            Section("快捷键") {
                LabeledContent("唤起捕捉弹窗") {
                    KeyboardShortcuts.Recorder(for: .toggleCapture)
                }
            }

            Section("启动") {
                Toggle("登录时启动 Quick Thoughts", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        applyLaunchAtLogin(newValue)
                    }
                if let err = loginToggleError {
                    Text(err)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Section("数据文件") {
                LabeledContent("路径") {
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
                        .help("在 Finder 中显示")
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 480, height: 320)
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
            loginToggleError = "切换失败：\(error.localizedDescription)。该功能需要已签名的 App 包，开发模式下可能不可用。"
            launchAtLogin = !enabled
        }
    }
}
