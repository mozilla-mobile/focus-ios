/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Telemetry

protocol SearchSettingsViewControllerDelegate: class {
    func searchSettingsViewController(_ searchSettingsViewController: SearchSettingsViewController, didSelectEngine engine: SearchEngine)
}

class SearchSettingsViewController: UITableViewController {
    weak var delegate: SearchSettingsViewControllerDelegate?

    private let searchEngineManager: SearchEngineManager

    init(searchEngineManager: SearchEngineManager) {
        self.searchEngineManager = searchEngineManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = UIConstants.strings.settingsSearchTitle
        view.backgroundColor = UIConstants.colors.background
        tableView.separatorColor = UIConstants.colors.settingsSeparator
        tableView.selectRow(at: IndexPath(row: 0, section: 1), animated: false, scrollPosition: .none)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchEngineManager.engines.count + 1 // Add search engine row
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == searchEngineManager.engines.count {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "addSearchEngine")
            cell.textLabel?.text = UIConstants.strings.AddSearchEngineButton
            cell.textLabel?.textColor = UIConstants.colors.settingsTextLabel
            cell.backgroundColor = UIConstants.colors.background
            return cell
        } else {
            let engine = searchEngineManager.engines[indexPath.item]
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = engine.name
            cell.textLabel?.textColor = UIConstants.colors.settingsTextLabel
            cell.imageView?.image = engine.image?.createScaled(size: CGSize(width: 32, height: 32))
            cell.backgroundColor = UIConstants.colors.background

            if engine === searchEngineManager.activeEngine {
                cell.accessoryType = .checkmark
            }

            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.item == searchEngineManager.engines.count {
            // Add search engine tapped
            let vc = AddSearchEngineViewController(delegate: self)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let engine = searchEngineManager.engines[indexPath.item]
            searchEngineManager.activeEngine = engine
            Telemetry.default.configuration.defaultSearchEngineProvider = engine.name
            
            _ = navigationController?.popViewController(animated: true)
            delegate?.searchSettingsViewController(self, didSelectEngine: engine)
        }
    }
}

extension SearchSettingsViewController: AddSearchEngineDelegate {
    func addSearchEngineViewController(_ addSearchEngineViewController: AddSearchEngineViewController, name: String, searchTemplate: String) {
        
    }
}
