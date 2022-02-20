//
//  PreferencesView.swift
//  
//
//  Created by Danis Tazetdinov on 18.02.2022.
//

import SwiftUI
import DataModel
import UniformTypeIdentifiers
import Logger
import Localization

@MainActor
public struct PreferencesView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.persistentContainer) private var container

    @State private var showExport = false
    @State private var showImport = false

    @State private var ongoingExport = false
    @State private var ongoingImport = false
    @State private var showImportSuccess = false
    @State private var showImportError = false
    @State private var showExportError = false

    @State private var archiveDocument: ArchiveDocument? = nil
    @State private var scene: UIWindowScene? = nil

    public init() { }
    
    private func appVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
#if DEBUG
        return L10n.Preferences.versionFormat.localized(with: version, build) + " - DEBUG"
#else
        return L10n.Preferences.versionFormat.localized(with: version, build)
#endif
    }
    
    private func exportFileName() -> String {
        let dateString = Date().formatted(.dateTime)
            .replacingOccurrences(of: "/", with: ".")
            .replacingOccurrences(of: ":", with: ".")
            .replacingOccurrences(of: "\\", with: ".")
        return "StuffExport \(dateString).aar"
    }

    private func createArchive() async {
        ongoingExport = true
        let context = container.newBackgroundContext()
        do {
            var document: ArchiveDocument? = nil
            try await context.perform {
                let tempFolder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                try FileManager.default.createDirectory(at: tempFolder, withIntermediateDirectories: true)
                let tempName = tempFolder.appendingPathComponent(exportFileName())
                
                let archive = Archive(context: viewContext)
                let archiveURL = try archive.saveArchive()
                try CompressionRoutines.compress(source: archiveURL, to: tempName)
                document = try ArchiveDocument(url: tempName)
            }
            ongoingExport = false
            if let document = document {
                updateDocument(document: document)
            }
        }
        catch {
            Logger.default.error("failed to archive data: \(error)")
            ongoingExport = false
        }
    }

    private func updateDocument(document: ArchiveDocument) {
        archiveDocument = document
        showExport = true
    }

    private func extractData(url: URL) async {
        ongoingImport = true
        let context = container.newBackgroundContext()
        do {
            try await context.perform {
                let tempName = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                try CompressionRoutines.decompress(source: url, to: tempName)
                let archive = try Archive(url: tempName)
                archive.extract(to: context)
                try context.save()
            }
            ongoingImport = false
            showImportSuccess = true
        } catch {
            Logger.default.error("failed to archive data: \(error)")
            ongoingImport = false
            showImportError = true
        }
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Text(L10n.Preferences.exportImportTitle.localized)
                    .font(.title2)
                    .foregroundColor(.secondary)

                GroupBox {
                    HStack {
                        Text(L10n.Preferences.exportAction.localized)
                        Spacer()
                        Button {
                            Task {
                                await createArchive()
                            }
                        } label: {
                            Label(L10n.Preferences.exportButtonTitle.localized, systemImage: "square.and.arrow.up")
                                .contentShape(Rectangle())
                        }
                    }
                    .font(.title3)
                    .padding(8)
                } label: {
                    Text(L10n.Preferences.exportTitle.localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                GroupBox {
                    HStack {
                        Text(L10n.Preferences.importAction.localized)
                        Spacer()
                        Button {
                            showImport = true
                        } label: {
                            Label(L10n.Preferences.importButtonTitle.localized, systemImage: "square.and.arrow.down")
                                .contentShape(Rectangle())
                        }
                    }
                    .font(.title3)
                    .padding(8)
                } label: {
                    Text(L10n.Preferences.importTitle.localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(appVersion())
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if UIDevice.current.isMac {
                        Button(role: .cancel) {
                            if let scene = scene {
                                Logger.default.info("[SCENE] processing captured scene: \(scene)")
                                UIApplication.shared.requestSceneSessionDestruction(scene.session, options: nil) { error in
                                    Logger.default.error("[SCENE] failed to dismiss scene \(error)")
                                }
                            } else {
                                Logger.default.error("[SCENE] no scene, could not dismiss window")
                            }
                        } label: {
                            Text(L10n.Common.buttonDismiss.localized)
                        }
                    }
                }
            }
            .withWindow { window in
                scene = window?.windowScene
                window?.windowScene?.title = L10n.Preferences.title.localized
            }
            .disabled(ongoingExport || ongoingImport)
            .overlay(ZStack(alignment: .center) {
                if ongoingExport || ongoingImport  {
                    VStack(spacing: 20) {
                        ProgressView(ongoingImport ? L10n.Preferences.importingData.localized : L10n.Preferences.exportingData.localized)
                            .progressViewStyle(.circular)
                    }
                    .padding(40)
                    .background(Material.regular)
                    .cornerRadius(8)
                }
            })
            .padding()
            .fileImporter(isPresented: $showImport, allowedContentTypes: [.appleArchive]) { result in
                switch result {
                case .success(let url):
                    Logger.default.info("loading url -> \(url)")
                    Task {
                        await extractData(url: url)
                    }

                case .failure(let error):
                    Logger.default.error("could open file: \(error)")
                }
            }
            .fileExporter(isPresented: $showExport, document: archiveDocument, contentType: .appleArchive, defaultFilename: "StuffExport.aar") { result in
                switch result {
                case .success(let url):
                    Logger.default.info("saving url -> \(url)")

                case .failure(let error):
                    Logger.default.error("could open file: \(error)")
                }
            }
            .sheet(isPresented: $showImportSuccess) {
                ConfirmationView(title: L10n.Preferences.importSuccessTitle.localized,
                                 details: L10n.Preferences.importSuccessDetails.localized,
                                 imageName: "checkmark.circle.fill",
                                 imageColor: .green)
            }
            .sheet(isPresented: $showImportError) {
                ConfirmationView(title: L10n.Preferences.importFailureTitle.localized,
                                 details: L10n.Preferences.importFailureDetails.localized,
                                 imageName: "xmark.circle.fill",
                                 imageColor: .red)
            }
            .sheet(isPresented: $showExportError) {
                ConfirmationView(title: L10n.Preferences.exportFailureTitle.localized,
                                 details: L10n.Preferences.exportFailureDetails.localized,
                                 imageName: "xmark.circle.fill",
                                 imageColor: .red)
            }
            .navigationTitle(L10n.Preferences.title.localized)
        }
        .navigationViewStyle(.stack)
        .tabItem {
            Label(L10n.Preferences.title.localized, systemImage: "gear")
        }

    }
}
