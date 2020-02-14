//
//  CGFloat.swift
//  RFRoundedProgressButton
//
//  Created by Raffaele Forgione on 14/02/2020.
//  Copyright © 2020 Raffaele Forgione. All rights reserved.
//

import UIKit

extension CGFloat {
    func round() -> CGFloat {
        return CGFloat(floorf(Float(self) * 100 + 0.5)) / 100
    }
}
