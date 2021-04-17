//
//  DocumentPickerViewController.swift
//  DesktopTestBed
//
//  Created by fincher on 4/14/21.
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers

class DocumentPickerViewController: UIDocumentPickerViewController, UIDocumentPickerDelegate {
    private var onDismiss: () -> Void
    private var onPick: (URL) -> ()

    init(supportedExtensions: [String], onPick: @escaping (URL) -> Void, onDismiss: @escaping () -> Void) {
        self.onPick = { url in }
        self.onDismiss = {}
        super.init(forOpeningContentTypes: supportedExtensions.map { (ext: String) -> UTType in
            UTType(filenameExtension: ext)!
        }, asCopy: false)
        self.onDismiss = onDismiss
        self.onPick = onPick
        allowsMultipleSelection = false
        delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(documentTypes allowedUTIs: [String], in mode: UIDocumentPickerMode) {
        onPick = { url in }
        onDismiss = {}
        super.init(documentTypes: allowedUTIs, in: mode)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        urls.first!.startAccessingSecurityScopedResource()
        onPick(urls.first!)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        onDismiss()
    }
}
