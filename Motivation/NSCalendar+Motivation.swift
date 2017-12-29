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
		let year = dateComponents([.year], from: date).year
		return daysInYear(year!)
	}

	func daysInYear(_ year: Int) -> Int? {
		guard let begin = lastDayOfYear(year - 1), let end = lastDayOfYear(year) else { return nil }
		return dateComponents([.day], from: begin, to: end).day
	}

	func lastDayOfYear(_ year: Int) -> Date? {
		var components = DateComponents()
		components.year = year
		guard let years = date(from: components) else { return nil }

		components.month = range(of: Calendar.Component.month, in: Calendar.Component.year, for: years)?.count
        guard let months = date(from: components) else { return nil }

		components.day = range(of: Calendar.Component.day, in: Calendar.Component.month, for: months)?.count
		return date(from: components)
	}
}
