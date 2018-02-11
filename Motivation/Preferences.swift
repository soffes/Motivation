//
//  Preferences.swift
//  Motivation
//
//  Created by Sam Soffes on 8/6/15.
//  Copyright (c) 2015 Sam Soffes. All rights reserved.
//

import Foundation
import ScreenSaver

enum MotivationLevel: UInt {
	case light, moderate, terrifying

	var decimalPlaces: UInt {
		switch self {
		case .light: return 7
		case .moderate: return 8
		case .terrifying: return 9
		}
	}
}

class Preferences: NSObject {

	// MARK: - Properties

    static let birthdayDidChangeNotification = Notification.Name(rawValue: "Preferences.birthdayDidChangeNotification")
    static let motivationLevelDidChangeNotification = Notification.Name(rawValue: "Preferences.motivationLevelDidChangeNotification")

	var birthday: Date? {
		get {
            let timestamp = defaults?.object(forKey: "Birthday") as? TimeInterval
			return timestamp.map { Date(timeIntervalSince1970: $0) }
		}

		set {
			if let date = newValue {
                defaults?.set(date.timeIntervalSince1970, forKey: "Birthday")
			} else {
                defaults?.removeObject(forKey: "Birthday")
			}
			defaults?.synchronize()

            NotificationCenter.default.post(name: type(of: self).birthdayDidChangeNotification, object: newValue)
		}
	}

	var motivationLevel: MotivationLevel {
		get {
            let uint = defaults?.object(forKey: "MotivationLevel") as? UInt
			return uint.flatMap { MotivationLevel(rawValue: $0) } ?? .terrifying
		}

		set {
            defaults?.set(newValue.rawValue, forKey: "MotivationLevel")
			defaults?.synchronize()

            NotificationCenter.default.post(name: type(of: self).motivationLevelDidChangeNotification, object: newValue.rawValue)
		}
	}

	private let defaults: ScreenSaverDefaults? = {
        let bundleIdentifier = Bundle(for: Preferences.self).bundleIdentifier
		return bundleIdentifier.flatMap { ScreenSaverDefaults(forModuleWithName: $0) }
	}()
}
