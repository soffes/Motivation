//
//  NSCalendar+Motivation.swift
//  Motivation
//
//  Created by Sam Soffes on 8/14/15.
//  Copyright © 2015 Sam Soffes. All rights reserved.
//

import Foundation

extension Calendar {
	func daysInYear(_ date: Date = Date()) -> Int? {
		let year = dateComponents([NSCalendar.Unit.year], from: date).year
		return daysInYear(year!)
	}

	func daysInYear(_ year: Int) -> Int? {
		guard let begin = lastDayOfYear(year - 1), let end = lastDayOfYear(year) else { return nil }
		return dateComponents([NSCalendar.Unit.day], from: begin, to: end, options: []).day
	}

	func lastDayOfYear(_ year: Int) -> Date? {
		var components = DateComponents()
		components.year = year
		guard let years = date(from: components) else { return nil }

		components.month = range(of: NSCalendar.Unit.month, in: NSCalendar.Unit.year, for: years).length
		guard let months = date(from: components) else { return nil }

		components.day = range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: months).length

		return date(from: components)
	}
}
