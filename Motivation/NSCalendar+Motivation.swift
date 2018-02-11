//
//  NSCalendar+Motivation.swift
//  Motivation
//
//  Created by Sam Soffes on 8/14/15.
//  Copyright © 2015 Sam Soffes. All rights reserved.
//

import Foundation

extension Calendar {
	func daysInYear(date: Date = Date()) -> Int? {
        let year = dateComponents([.year], from: date).year
		return year.flatMap(days)
	}

	func days(inYear year: Int) -> Int? {
        guard let begin = lastDay(ofYear: year - 1), let end = lastDay(ofYear: year) else { return nil }
		return dateComponents([.day], from: begin, to: end).day
	}

	func lastDay(ofYear year: Int) -> Date? {
		var components = DateComponents()
		components.year = year

        guard let years = date(from: components),
            let month = range(of: .month, in: .year, for: years)?.count else { return nil }

        components.month = month

        guard let months = date(from: components),
            let day = range(of: .day, in: .month, for: months)?.count else { return nil }

		components.day = day

        return date(from: components)
	}
}
