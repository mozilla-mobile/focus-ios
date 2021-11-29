//
//  main.swift
//  ios-l10n-tools
//
//  Created by Jeff Boek on 10/21/20.
//

// todo: copy over
//
//required_ids = [
//    "NSCameraUsageDescription',
//    'NSLocationWhenInUseUsageDescription',
//    'NSMicrophoneUsageDescription',
//    'NSPhotoLibraryAddUsageDescription',
//    'ShortcutItemTitleNewPrivateTab',
//    'ShortcutItemTitleNewTab',
//    'ShortcutItemTitleQRCode',
//]
// from en locale if missing or app will crash on those locales.

// run this by flod if we still need this
//# Using locale folder as locale code. In some cases we need to map this
//    # value to a different locale code
//    # http://www.ibabbleon.com/iOS-Language-Codes-ISO-639.html
//    # See Bug 1193530, Bug 1160467.
//    locale_code = file_path.split(os.sep)[-2]
//    locale_mapping = {
//        'es-ES': 'es',
//        'ga-IE': 'ga',
//        'nb-NO': 'nb',
//        'nn-NO': 'nn',
//        'sv-SE': 'sv',
//        'tl'   : 'fil',
//        'zgh'  : 'tzm',
//        'sat'  : 'sat-Olck'
//    }
//
//
//
// and this
//for locale in ${locale_list};
//do
//    # Exclude en-US and templates
//    if [ "${locale}" != "en-US" ] && [ "${locale}" != "templates" ]

import Foundation
import ArgumentParser

struct L10NTools: ParsableCommand {
    @Option(help: "Path to the project")
    var projectPath: String
    
    @Option(name: .customLong("l10n-project-path"), help: "Path to the l10n project")
    var l10nProjectPath: String
    
    @Flag(name: .customLong("export"), help: "To determine if we should run the export task.")
    var runExportTask = false
    
    @Flag(name: .customLong("import"), help: "To determine if we should run the import task.")
    var runImportTask = false
    
    static var configuration: CommandConfiguration {
        CommandConfiguration(commandName: "l10nTools", abstract: "Scripts for automating l10n for Mozilla iOS projects.", discussion: "", version: "1.0", shouldDisplay: true, subcommands: [], defaultSubcommand: nil, helpNames: .long)
        
    }
    
    private func validateArguments() -> Bool {
        switch (runExportTask, runImportTask) {
        case (false, false):
            print("Please specify which task to run with --export, --import")
            return false
        case (true, true):
            print("Please choose a single task to run")
            return false
        default: return true;
        }
    }
    
    private func listAllFileNamesExtension(nameDirectory: String, extensionWanted: String) -> (names : [String], paths : [URL]) {

       let documentURL =  URL(fileURLWithPath: projectPath)
       let Path = documentURL.appendingPathComponent(nameDirectory).absoluteURL

       do {
           try FileManager.default.createDirectory(atPath: Path.relativePath, withIntermediateDirectories: true)
           // Get the directory contents urls (including subfolders urls)
           let directoryContents = try FileManager.default.contentsOfDirectory(at: Path, includingPropertiesForKeys: nil, options: [])

           // if you want to filter the directory contents you can do like this:
           let FilesPath = directoryContents.filter{ $0.pathExtension == extensionWanted }
           let FileNames = FilesPath.map{ $0.deletingPathExtension().lastPathComponent }

           return (names : FileNames, paths : FilesPath);

       } catch {
           print(error.localizedDescription)
       }

       return (names : [], paths : [])
   }

    private func getLocalesFromProjectFolder () -> (Array<String>) {
        var myLocalesList:[String] = []
        let blockzillaFolder = FileManager.default.enumerator(atPath: URL(fileURLWithPath: projectPath).deletingLastPathComponent().appendingPathComponent("Blockzilla").path)

        let filePaths = blockzillaFolder?.allObjects as! [String]
        let textFilePaths = filePaths.filter{$0.contains(".lproj")}
        for txt in textFilePaths {
            if let index = txt.firstIndex(of: ".") {
                let firstPart = txt.prefix(upTo: index)
                myLocalesList.append(String(firstPart))
            }
        }
        var uniqueLocales = Array(Set(myLocalesList))
        
        let toRemove = ["Settings"]
        
        // for k in toRemove {
            uniqueLocales = uniqueLocales.filter { $0 != "Settings" }
        //}

        for item in uniqueLocales {
            print(item)
            for (key, _) in locale_mapping {
                if item == key {
                    let position = uniqueLocales.firstIndex(of: item)!
                    uniqueLocales[position] = locale_mapping[key]!
                }
            }
        }
        
        // return uniqueLocales
    
        return uniqueLocales.sorted(by:<)
    }

    private var locale_mapping = [
        "fil" : "tl",
        "ga" : "ga-IE",
        "nb" : "nb-NO",
        "nn" : "nn-NO",
        "sv" : "sv-SE",
        "en" : "en-US"
        ]

    mutating func run() throws {
        guard validateArguments() else { L10NTools.exit() }

        let locales = getLocalesFromProjectFolder()

        if runImportTask {
            ImportTask(xcodeProjPath: projectPath, l10nRepoPath: l10nProjectPath, locales: locales).run()
        }
        
        if runExportTask {
            ExportTask(xcodeProjPath: projectPath, l10nRepoPath: l10nProjectPath).run()
            CreateTemplatesTask(l10nRepoPath: l10nProjectPath).run()
        }
    }
}

L10NTools.main()
