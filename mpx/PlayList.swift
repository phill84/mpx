//
//  PlayList.swift
//  mpx
//
//  Created by Jiening Wen on 10/01/16.
//  Copyright (c) 2016 phill84.
//
//  This file is part mpx.
//
//  mpx is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 2 of the License, or
//  (at your option) any later version.
//
//  mpx is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with mpx.  If not, see <http://www.gnu.org/licenses/>.
//

class PlayList: NSObject {
	var urls: [NSURL] = []
	var currentFileIndex = 0
	
	func replacePlayList(urls: [NSURL]) {
		self.urls = urls
	}
	
	func appendFilesToPlayList(urls: [NSURL]) {
		self.urls.appendContentsOf(urls)
	}
	
	func isEmpty() -> Bool {
		return urls.isEmpty
	}
	
	func isCurrentFileTheLast() -> Bool {
		return currentFileIndex == urls.count - 1
	}
	
	// list is never empty for this function
	func getNextFileForPlaying() -> NSURL {
		currentFileIndex += 1
		return urls[currentFileIndex]
	}
	
	func getCurrentFileName() -> String {
		let currentFile = urls[currentFileIndex]
		return currentFile.lastPathComponent!
	}
}
