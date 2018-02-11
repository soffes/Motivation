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

	private let textLabel: NSTextField = {
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

	private lazy var configurationWindowController: NSWindowController = {
		return ConfigurationWindowController()
	}()

	private var motivationLevel: MotivationLevel

	private var birthday: Date? {
		didSet {
			updateFont()
		}
	}


	// MARK: - Initializers

	convenience init() {
		self.init(frame: .zero, isPreview: false)
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
            let age = self.age(forBirthday: birthday)
			let format = "%0.\(motivationLevel.decimalPlaces)f"
			textLabel.stringValue = String(format: format, age)
		} else {
			textLabel.stringValue = "Open Screen Saver Options to set your birthday."
		}
	}

    override var hasConfigureSheet: Bool {
		return true
	}

    override var configureSheet: NSWindow? {
		return configurationWindowController.window
	}
	

	// MARK: - Private

	/// Shared initializer
	private func initialize() {
		// Set animation time interval
		animationTimeInterval = 1 / 30

		// Recall preferences
		birthday = Preferences().birthday

		// Setup the label
		addSubview(textLabel)
		addConstraints([
            NSLayoutConstraint(item: textLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: textLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
		])

		// Listen for configuration changes
        NotificationCenter.default.addObserver(self, selector: #selector(motivationLevelDidChange), name: Preferences.motivationLevelDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(birthdayDidChange), name: Preferences.birthdayDidChangeNotification, object: nil)
	}

	/// Age calculation
	private func age(forBirthday birthday: Date) -> Double {
		let calendar = Calendar.current
		let now = Date()

		// An age is defined as the number of years you've been alive plus the number of days, seconds, and nanoseconds
		// you've been alive out of that many units in the current year.
		let components = calendar.dateComponents([.year, .day, .second, .nanosecond], from: birthday, to: now)

		// We calculate these every time since the values can change when you cross a boundary. Things are too
		// complicated to try to figure out when that is and cache them. NSCalendar is made for this.
        let daysInYear = Double(calendar.days(inYear: components.year!) ?? 365)
        let hoursInDay = Double(calendar.range(of: .hour, in: .day, for: now)!.count)
        let minutesInHour = Double(calendar.range(of: .minute, in: .hour, for: now)!.count)
        let secondsInMinute = Double(calendar.range(of: .second, in: .minute, for: now)!.count)
        let nanosecondsInSecond = Double(calendar.range(of: .nanosecond, in: .second, for: now)!.count)

		// Now that we have all of the values, assembling them is easy. We don't get minutes and hours from the calendar
		// since it will overflow nicely to seconds. We need days and years since the number of days in a year changes
		// more frequently. This will handle leap seconds, days, and years.
		let seconds = Double(components.second!) + (Double(components.nanosecond!) / nanosecondsInSecond)
		let minutes = seconds / secondsInMinute
		let hours = minutes / minutesInHour
		let days = Double(components.day!) + (hours / hoursInDay)
		let years = Double(components.year!) + (days / daysInYear)

		return years
	}

	/// Motiviation level changed
	@objc private func motivationLevelDidChange(notification: NSNotification?) {
		motivationLevel = Preferences().motivationLevel
	}

	/// Birthday changed
	@objc private func birthdayDidChange(notification: NSNotification?) {
		birthday = Preferences().birthday
	}

	/// Update the font for the current size
	private func updateFont() {
		if birthday != nil {
            textLabel.font = font(ofSize: bounds.width / 10)
		} else {
            textLabel.font = font(ofSize: bounds.width / 30, isMonospaced: false)
		}
	}

	/// Get a font
	private func font(ofSize fontSize: CGFloat, isMonospaced: Bool = true) -> NSFont {
		let font: NSFont
		if #available(OSX 10.11, *) {
            font = .systemFont(ofSize: fontSize, weight: .thin)
		} else {
			font = NSFont(name: "HelveticaNeue-Thin", size: fontSize)!
		}

		let fontDescriptor: NSFontDescriptor
		if isMonospaced {
            fontDescriptor = font.fontDescriptor.addingAttributes([
                NSFontDescriptor.AttributeName.featureSettings: [
					[
                        NSFontDescriptor.FeatureKey.typeIdentifier: kNumberSpacingType,
                        NSFontDescriptor.FeatureKey.selectorIdentifier: kMonospacedNumbersSelector
					]
				]
			])
		} else {
			fontDescriptor = font.fontDescriptor
		}

		return NSFont(descriptor: fontDescriptor, size: fontSize)!
	}
}
