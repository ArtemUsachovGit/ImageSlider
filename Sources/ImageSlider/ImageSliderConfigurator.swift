//
//  File.swift
//  
//
//  Created by Artem Usachov on 18.11.2022.
//

import SwiftUI

public protocol ImageSliderConfigurator {
    var range: ClosedRange<Double> { get }
    var step: Double { get }
    var image: Image { get }
    var colors: [Color] { get }
}
