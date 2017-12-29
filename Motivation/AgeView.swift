//
//  AgeView.swift
//  Motivation
//
//  Created by Sam Soffes on 8/6/15.
//  Copyright (c) 2015 Sam Soffes. All rights reserved.
//

import Foundation
import ScreenSaver

class AgeView: ScreenSaverView {

	// MARK: - Properties

	fileprivate let textLabel: NSTextField = {
		let label = NSTextField()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.isEditable = false
		label.drawsBackground = false
		label.isBordered = false
		label.isBezeled = false
		label.isSelectable = false
		label.textColor = .white
		return label
	}()

	fileprivate lazy var configurationWindowController: NSWindowController = {
		return ConfigurationWindowController()
	}()

	fileprivate var motivationLevel: MotivationLevel

	fileprivate var birthday: Date? {
		didSet {
			updateFont()
		}
	}


	// MARK: - Initializers

	convenience init() {
		self.init(frame: CGRect.zero, isPreview: false)
	}

	override init!(frame: NSRect, isPreview: Bool) {
		motivationLevel = Preferences().motivationLevel
		super.init(frame: frame, isPreview: isPreview)
		initialize()
	}

	required init?(coder: NSCoder) {
		motivationLevel = Preferences().motivationLevel
		super.init(coder: coder)
		initialize()
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	

	// MARK: - NSView

	override func draw(_ rect: NSRect) {
		let backgroundColor: NSColor = .black

		backgroundColor.setFill()
		NSBezierPath.fill(bounds)
	}

	// If the screen saver changes size, update the font
	override func resize(withOldSuperviewSize oldSize: NSSize) {
		super.resize(withOldSuperviewSize: oldSize)
		updateFont()
	}


	// MARK: - ScreenSaverView

	override func animateOneFrame() {
		if let birthday = birthday {
			let age = ageForBirthday(birthday)
			let format = "%0.\(motivationLevel.decimalPlaces)f"
			textLabel.stringValue = String(format: format, age)
		} else {
			textLabel.stringValue = "Open Screen Saver Options to set your birthday."
		}
	}

	override func hasConfigureSheet() -> Bool {
		return true
	}

	override func configureSheet() -> NSWindow? {
		return configurationWindowController.window
	}
	

	// MARK: - Private

	/// Shared initializer
	fileprivate func initialize() {
		// Set animation time interval
		animationTimeInterval = 1 / 30

		// Recall preferences
		birthday = Preferences().birthday as! Date

		// Setup the label
		addSubview(textLabel)
		addConstraints([
			NSLayoutConstraint(item: textLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: textLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
		])

		// Listen for configuration changes
		NotificationCenter.default.addObserver(self, selector: #selector(AgeView.motivationLevelDidChange(_:)), name: NSNotification.Name(rawValue: Preferences.motivationLevelDidChangeNotificationName), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(AgeView.birthdayDidChange(_:)), name: NSNotification.Name(rawValue: Preferences.birthdayDidChangeNotificationName), object: nil)
	}

	/// Age calculation
	fileprivate func ageForBirthday(_ birthday: Date) -> Double {
		let calendar = Calendar.current
		let now = Date()

		// An age is defined as the number of years you've been alive plus the number of days, seconds, and nanoseconds
		// you've been alive out of that many units in the current year.
		let components = (calendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.day, NSCalendar.Unit.second, NSCalendar.Unit.nanosecond], from: birthday, to: now, options: [])

		// We calculate these every time since the values can change when you cross a boundary. Things are too
		// complicated to try to figure out when that is and cache them. NSCalendar is made for this.
		let daysInYear = Double(calendar.daysInYear(now) ?? 365)
		let hoursInDay = Double((calendar as NSCalendar).range(of: NSCalendar.Unit.hour, in: NSCalendar.Unit.day, for: now).length)
		let minutesInHour = Double((calendar as NSCalendar).range(of: NSCalendar.Unit.minute, in: NSCalendar.Unit.hour, for: now).length)
		let secondsInMinute = Double((calendar as NSCalendar).range(of: NSCalendar.Unit.second, in: NSCalendar.Unit.minute, for: now).length)
		let nanosecondsInSecond = Double((calendar as NSCalendar).range(of: NSCalendar.Unit.nanosecond, in: NSCalendar.Unit.second, for: now).length)

		// Now that we have all of the values, assembling them is easy. We don't get minutes and hours from the calendar
		// since it will overflow nicely to seconds. We need days and years since the number of days in a year changes
		// more frequently. This will handle leap seconds, days, and years.
		let seconds = Double(components.second!) + (Double(components.nanosecond!) / nanosecondsInSecond)
		let minutes = seconds / secondsInMinute
		let hours = minutes / minutesInHour
		let days = Double(components.day!) + (hours / hoursInDay)
		let years = Double(components.year) + (days / daysInYear)

		return years
	}

	/// Motiviation level changed
	@objc fileprivate func motivationLevelDidChange(_ notification: Notification?) {
		motivationLevel = Preferences().motivationLevel
	}

	/// Birthday changed
	@objc fileprivate func birthdayDidChange(_ notification: Notification?) {
		birthday = Preferences().birthday as! Date
	}

	/// Update the font for the current size
	fileprivate func updateFont() {
		if birthday != nil {
			textLabel.font = fontWithSize(bounds.width / 10)
		} else {
			textLabel.font = fontWithSize(bounds.width / 30, monospace: false)
		}
	}

	/// Get a font
	fileprivate func fontWithSize(_ fontSize: CGFloat, monospace: Bool = true) -> NSFont {
		let font: NSFont
		if #available(OSX 10.11, *) {
			font = .systemFont(ofSize: fontSize, weight: NSFontWeightThin)
		} else {
			font = NSFont(name: "HelveticaNeue-Thin", size: fontSize)!
		}

		let fontDescriptor: NSFontDescriptor
		if monospace {
			fontDescriptor = font.fontDescriptor.addingAttributes([
				NSFontFeatureSettingsAttribute: [
					[
						NSFontFeatureTypeIdentifierKey: kNumberSpacingType,
						NSFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector
					]
				]
			])
		} else {
			fontDescriptor = font.fontDescriptor
		}

		return NSFont(descriptor: fontDescriptor, size: fontSize)!
	}
}
