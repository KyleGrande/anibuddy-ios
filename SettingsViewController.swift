//
//  SettingsViewController.swift
//  Anibuddy
//
//  Created by Kyle Grande.
//

import UIKit


class SettingsViewController: UIViewController {

	// Delegate to communicate changes back to SearchAnimeVC
	weak var delegate: SettingsViewControllerDelegate?

	// Outlet for the dark mode switch & fetchtype
	@IBOutlet weak var darkMode: UISwitch!
	@IBOutlet weak var fetchTypeControl: UISegmentedControl!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Set the switchs to the user's preference
		let darkModeEnabled = UserDefaults.standard.bool(forKey: "darkModeEnabled")
		darkMode.isOn = darkModeEnabled
		let fetchTop = UserDefaults.standard.bool(forKey: "fetchTop")
			fetchTypeControl.selectedSegmentIndex = fetchTop ? 1 : 0
	}
	
	// Action triggered when the fetchTypeControl's value changes
	@IBAction func fetchTypeControlValueChanged(_ sender: UISegmentedControl) {
		let fetchTop = sender.selectedSegmentIndex == 1
		UserDefaults.standard.set(fetchTop, forKey: "fetchTop")
		delegate?.didChangeFetchType(to: fetchTop)
	}

	@IBAction func darkModeSwitchValueChanged(_ sender: UISwitch) {
		// Save user preference
		UserDefaults.standard.set(sender.isOn, forKey: "darkModeEnabled")

		// Apply the selected user interface style to all windows in the scene
		if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
			if sender.isOn {
				// Enable dark mode
				windowScene.windows.forEach { window in
					window.overrideUserInterfaceStyle = .dark
				}
			} else {
				// Disable dark mode
				windowScene.windows.forEach { window in
					window.overrideUserInterfaceStyle = .light
				}
			}
		}
	}
}
