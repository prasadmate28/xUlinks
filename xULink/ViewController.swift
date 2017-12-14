//
//  ViewController.swift
//  xULink
//
//  Created by Niraj Kadam on 11/24/17.
//  Copyright © 2017 Niraj Kadam. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, XMLParserDelegate, NSURLConnectionDataDelegate {

	// MARK: -

	@IBOutlet var directoryPathHolder: NSTextField!
	@IBOutlet var isDirectoryUploaded: NSTextField!

	// MARK: -

	@IBOutlet var verificationStep1:    NSTextField!
	@IBOutlet var verificationStep3:    NSTextField!
	@IBOutlet var verificationStep5:    NSTextField!
	@IBOutlet var verificationStep5Num: NSTextField!
	@IBOutlet var verificationStep6:    NSTextField!
	@IBOutlet var verificationStep7:    NSTextField!
	@IBOutlet var verificationStep7Num: NSTextField!

	// MARK: -

	@IBOutlet var indicatorView1: NSBox!
	@IBOutlet var indicatorView2: NSBox!
	@IBOutlet var indicatorView3: NSBox!
	@IBOutlet var indicatorView4: NSBox!
	@IBOutlet var indicatorView5: NSBox!

	// MARK: -

	var foundURL 			 : URL!
	var foundEntitlementFile : URL!
	var xmlParser			 : XMLParser!

	// MARK: -

	override func viewDidLoad() {
		super.viewDidLoad()

        self.isDirectoryUploaded.isHidden  = true

		self.indicatorView1.isHidden = true
		self.indicatorView2.isHidden = true
		self.indicatorView3.isHidden = true
		self.indicatorView4.isHidden = true
		self.indicatorView5.isHidden = true
		
		self.indicatorView1.fillColor = .systemRed
		self.indicatorView2.fillColor = .systemRed
		self.indicatorView3.fillColor = .systemRed
		self.indicatorView4.fillColor = .systemRed
		self.indicatorView5.fillColor = .systemRed
	}

	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}

	@IBAction func browseFile(sender: AnyObject) {

        let dialog                     = NSOpenPanel();

        dialog.title                   = "Choose your .xCodeProject directory";
        dialog.prompt                  = "Choose Directory"
        dialog.worksWhenModal          = true
        dialog.canChooseFiles          = false
        dialog.canChooseDirectories    = true
        dialog.allowsMultipleSelection = false
        dialog.canCreateDirectories    = false
        dialog.resolvesAliases         = true

		if (dialog.runModal() == NSApplication.ModalResponse.OK) {

			foundURL = dialog.url // pathname of the directory

			if (foundURL != nil) {
				let path = foundURL!.path

                self.directoryPathHolder.stringValue = path
                self.isDirectoryUploaded.isHidden    = false
				
				self.beginEvaluation()
			}
		} else {
			// user clicked on "Cancel"
			return
		}
	}

	func beginEvaluation() {

		// refine the URL found
		let pathArray : [String] = "\(foundURL!)".components(separatedBy: "/")
		let projectName = String(describing: pathArray.suffix(2).first!)

        let docsDir     : URL    = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        let dbPath      : URL    = docsDir.appendingPathComponent("\(projectName)/\(projectName)/\(projectName).entitlements")
		
		foundEntitlementFile = docsDir.appendingPathComponent("\(projectName)/\(projectName)/\(projectName).entitlements")

        let strDBPath   : String = dbPath.path

		print("Printing document directory:: \(docsDir)")

		do {
			let _ : Bool = try dbPath.checkResourceIsReachable()

			print("File exists at path :: \(dbPath.path)")

			self.parseXML()

		} catch {
			print("File NOT Found at :: \(strDBPath)")

            self.indicatorView1.fillColor = .systemRed
            self.indicatorView1.isHidden  = false

            self.indicatorView2.isHidden = true
            self.indicatorView3.isHidden = true
            self.indicatorView4.isHidden = true
            self.indicatorView5.isHidden = true
		}
	}

	func parseXML() {

        let urlString           = URL(string: "\(foundEntitlementFile!)")
        self.xmlParser          = XMLParser(contentsOf: urlString!)!
        self.xmlParser.delegate = self
        let success:Bool        = self.xmlParser.parse()

		if success {
			print("success")
		} else {
			print("parse failure!")
		}
	}

	// XMLParserDelegate

	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
		print("found opener:: \(elementName)")
	}

	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		print("found closer:: \(elementName)")
	}

	func parser(_ parser: XMLParser, foundCharacters string: String) {

		print("found character:: \(string)")

		if (string == "com.apple.developer.associated-domains") {
            self.indicatorView1.fillColor = .systemGreen
            self.indicatorView1.isHidden  = false
		}

		if string.contains("applink") {

			let pathArray : [String] = string.components(separatedBy: ":")
			let domainAddress = String(describing: pathArray.last!)

			self.makeNetworkCall("https://\(domainAddress)/.well-known/")
		}

		self.indicatorView2.isHidden = true
		self.indicatorView3.isHidden = true
		self.indicatorView4.isHidden = true
		self.indicatorView5.isHidden = true
	}

	func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
		print("failure error:: ", parseError)
	}

	func makeNetworkCall(_ ipName: String) {

		var request = URLRequest(url: URL(string: ipName)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)

		request.httpMethod = "GET"
		let task = URLSession.shared.dataTask(with: request) { data, response, error in

			guard let data = data, error == nil else {
				// check for fundamental networking error
				print("error=\(String(describing: error!))")

				DispatchQueue.main.async {
                    self.indicatorView2.fillColor = .systemRed
                    self.indicatorView2.isHidden  = false
//					self.indicatorView3.isHidden  = true
//					self.indicatorView4.isHidden  = true
//					self.indicatorView5.isHidden  = true
				}
				return
			}

			if let httpResponse = response as? HTTPURLResponse,
				let contentType = httpResponse.allHeaderFields["Content-Type"] as? String {
				// use contentType here
				print("Content-Type:: \(contentType)")

				if contentType == "application/octet-stream" {
					DispatchQueue.main.async {
						self.indicatorView4.fillColor = .systemGreen
						self.indicatorView4.isHidden  = false
					}
				}
			}
			
			if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
				// check for http errors
				print("statusCode should be 200, but is \(httpStatus.statusCode)")
				print("response = \(String(describing: response!))")

				DispatchQueue.main.async {
					self.indicatorView2.fillColor = .systemRed
					self.indicatorView2.isHidden  = false
					self.indicatorView3.fillColor = .systemRed
					self.indicatorView3.isHidden  = false
				}
			}

			if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200 {
				// check for http errors
				print("statusCode returned is 200! ie: \(httpStatus.statusCode)")
				print("response = \(String(describing: response!))")

				DispatchQueue.main.async {
					self.indicatorView2.fillColor = .systemGreen
					self.indicatorView2.isHidden  = false
					self.indicatorView3.fillColor = .systemGreen
					self.indicatorView3.isHidden  = false
				}
			}

			do {
				let parsedData = try JSONSerialization.jsonObject(with: data) as! [String:Any]
//				let currentConditions = parsedData["currently"] as! [String:Any]

				print(parsedData)

				DispatchQueue.main.async {
					self.indicatorView5.fillColor = .systemGreen
					self.indicatorView5.isHidden  = false
				}

			} catch let error as NSError {
				print("JSON error:: \(error)")

				DispatchQueue.main.async {
					self.indicatorView5.fillColor = .systemRed
					self.indicatorView5.isHidden  = false
				}
			}
		}
		task.resume()
	}
	
	func makeSecureNetworkCall(ipName: String) {
		let urlSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self as? URLSessionDelegate, delegateQueue: nil)
		
		urlSession.dataTask(with: NSURL(string:ipName)! as URL, completionHandler: { data, response, error in
			// response management code

			
		}).resume()
	}
}
