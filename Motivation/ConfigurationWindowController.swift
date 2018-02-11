//
//  ConfigurationWindowController.swift
//  Motivation
//
//  Created by Sam Soffes on 8/6/15.
//  Copyright (c) 2015 Sam Soffes. All rights reserved.
//

import AppKit

class ConfigurationWindowController: NSWindowController {

	// MARK: - Properties

	@IBOutlet weak var lightRadio: NSButton!
	@IBOutlet weak var moderateRadio: NSButton!
	@IBOutlet weak var terrifyingRadio: NSButton!

	override var windowNibName: NSNib.Name {
        return NSNib.Name(rawValue: "Configuration")
	}


	// MARK: - NSWindowController

	override func windowDidLoad() {
		super.windowDidLoad()

		switch Preferences().motivationLevel {
		case .light: lightRadio.state = .on
		case .moderate: moderateRadio.state = .on
		case .terrifying: terrifyingRadio.state = .on
		}
	}


	// MARK: - Action

	@IBAction func close(sender: AnyObject?) {
		if let window = window {
			window.sheetParent?.endSheet(window)
		}
	}

	@IBAction func levelDidChange(sender: AnyObject?) {
		guard let button = sender as? NSButton, let level = MotivationLevel(rawValue: UInt(button.tag)) else { return }
		Preferences().motivationLevel = level
	}
}
