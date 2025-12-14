//
//  QuoteWidgetBundle.swift
//  QuoteWidget
//
//  Created by Trung Nguyen on 14/12/25.
//

import WidgetKit
import SwiftUI

@main
struct QuoteWidgetBundle: WidgetBundle {
    var body: some Widget {
        QuoteWidget()
        QuoteWidgetControl()
        QuoteWidgetLiveActivity()
    }
}
