//
//  SourceEditorCommand.swift
//  detectSchemeURL
//
//  Created by Niraj Kadam on 11/25/17.
//  Copyright © 2017 Niraj Kadam. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
		defer { completionHandler(nil) }

		if invocation.commandIdentifier.hasSuffix("Add") {
			addSchemeURLWarning(with: invocation)
		} else if invocation.commandIdentifier.hasSuffix("Remove") {
			removeSchemeURLWarning(with: invocation)
		}
    }

	// add warning after detecting usage of SchemeURL
	func addSchemeURLWarning(with invocation: XCSourceEditorCommandInvocation) {

		// we need to indent our TODO warning statement one level lower than the detected schemeURL
		let extraIndent: String

		if invocation.buffer.usesTabsForIndentation {
			// indent with an extra tab
			extraIndent = "\t"
		} else {
			// indent with as many spaces as needed
			extraIndent = String(repeatElement(" ", count: invocation.buffer.indentationWidth))
		}

		// REGEX: Any spaces or tabs, then some protocol text (e.g. "twitter, todo"), then "delimiter", then the host name, then path and/or params
		guard let regex = try? NSRegularExpression(pattern: "((\\bhttps\\b)(://)([^\n]*))", options: .caseInsensitive) else { return }

		// REPLACEMENT: Print the original protocol of the SchemeURL, then add our TODO warning commenting out the remaining part
		invocation.buffer.completeBuffer = regex.stringByReplacingMatches(in: invocation.buffer.completeBuffer, options: [], range: NSRange(location: 0, length: invocation.buffer.completeBuffer.utf16.count), withTemplate: "$1\n\n\(extraIndent)\(extraIndent)// FIXME:\n")
	}

	// remove added warning
	func removeSchemeURLWarning(with invocation: XCSourceEditorCommandInvocation) {

		guard let regex = try? NSRegularExpression(pattern: "\n\n\t\t// FIXME:\n", options: .caseInsensitive) else { return }

		// REPLACEMENT: Added warning string of comment
		invocation.buffer.completeBuffer = regex.stringByReplacingMatches(in: invocation.buffer.completeBuffer, options: [], range: NSRange(location: 0, length: invocation.buffer.completeBuffer.utf16.count), withTemplate: "")
	}
}

