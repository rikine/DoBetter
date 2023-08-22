//
//  NSMutableAttributedString.swift
//  VisionInvestUtils
//
//  Created by Вадим Серегин on 29.11.2022.
//  Copyright © 2022 vision-invest. All rights reserved.
//

import Foundation

public extension NSMutableAttributedString {

    func replaceOccurrences(of: String, with: String) {
        guard let range = string.nsRange(of: of), range.location != NSNotFound else { return }
        replaceCharacters(in: range, with: with)
    }
}
