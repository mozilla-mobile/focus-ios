/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

class SearchEngineManager {
    public static let prefKeyEngine = "prefKeyEngine"
    private static let prefKeyDisabledEngines = "prefKeyDisabledEngines"
    private static let prefKeyCustomEngines = "prefKeyCustomEngines"

    private let prefs: UserDefaults
    var engines: [SearchEngine]
    
    init(prefs: UserDefaults) {
        self.prefs = prefs

        // Get the directories to look for engines, from most to least specific.
        var components = Locale.preferredLanguages.first!.components(separatedBy: "-")
        if components.count == 3 {
            components.remove(at: 1)
        }
        let searchPaths = [components.joined(separator: "-"), components[0], "default"]

        let parser = OpenSearchParser(pluginMode: true)
        let pluginsPath = Bundle.main.url(forResource: "SearchPlugins", withExtension: nil)!
        let enginesPath = Bundle.main.path(forResource: "SearchEngines", ofType: "plist")!
        let engineMap = NSDictionary(contentsOfFile: enginesPath) as! [String: [String]]
        var engines = searchPaths.flatMap { engineMap[$0] }.first!

        let disabledEngines = prefs.stringArray(forKey: SearchEngineManager.prefKeyDisabledEngines) ?? [String]()
        
        // Filter out disabled engines
        engines = engines.filter { name in
            return !disabledEngines.contains(name)
        }
        
        // Find and parse the engines for this locale.
        self.engines = engines.flatMap { name in
            let path = searchPaths
                .map({ pluginsPath.appendingPathComponent($0).appendingPathComponent(name + ".xml") })
                .first { FileManager.default.fileExists(atPath: $0.path) }!
            return parser.parse(file: path)
        }
        
        // Add in custom engines
        let customEngines = readCustomEngines()
        self.engines.append(contentsOf: customEngines)
        
        // Sort alphabetically
        self.engines.sort { (aEngine, bEngine) -> Bool in
            return aEngine.name < bEngine.name
        }
    }
    
    func addEngine(name: String, template: String) {
        let correctedTemplate = template.replacingOccurrences(of: "%s", with: "{searchTerms}")
        let engine = SearchEngine(name: name, image: nil, searchTemplate: correctedTemplate, suggestionsTemplate: nil)
        
        var customEngines = readCustomEngines()
        customEngines.append(engine)
        saveCustomEngines(customEngines: customEngines)
        
        engines.append(engine)
    }
    
    private func readCustomEngines() -> [SearchEngine] {
        if let archiveData = prefs.value(forKey: SearchEngineManager.prefKeyCustomEngines) as? NSData {
            let archivedCustomEngines = NSKeyedUnarchiver.unarchiveObject(with: archiveData as Data)
            return archivedCustomEngines as? [SearchEngine] ?? [SearchEngine]()
        }
        return [SearchEngine]()
        //return prefs.array(forKey: SearchEngineManager.prefKeyCustomEngines) as? [SearchEngine] ?? [SearchEngine]()
    }
    
    private func saveCustomEngines(customEngines: [SearchEngine]) {
        prefs.set(NSKeyedArchiver.archivedData(withRootObject: customEngines), forKey: SearchEngineManager.prefKeyCustomEngines)
    }

    var activeEngine: SearchEngine {
        get {
            let selectName = prefs.string(forKey: SearchEngineManager.prefKeyEngine)
            return engines.first { $0.name == selectName } ?? engines.first!
        }

        set {
            prefs.set(newValue.name, forKey: SearchEngineManager.prefKeyEngine)
        }
    }
}
