import SwiftUI

public struct ImageSlider: View {
    @Binding var value: Double
    let configurator: ImageSliderConfigurator
    
    @State private var currentValue: Double
    @State private var lastCoordinateValue: Double = 0.0
    @State private var sliding: Bool = false
    
    private let range: ClosedRange<Double>
    private let feedback = UIImpactFeedbackGenerator(style: .soft)
    
    @Environment(\.colorScheme) private var colorScheme
    
    public init(value: Binding<Double>, configurator: ImageSliderConfigurator) {
        _value = value
        _currentValue = State(wrappedValue: value.wrappedValue/configurator.step)
        
        self.configurator = configurator
        
        let lowerBound = configurator.range.lowerBound
        let upperBound = lowerBound + (configurator.range.upperBound - lowerBound)/configurator.step
        self.range = lowerBound...upperBound
    }
    
    public var body: some View {
        GeometryReader { gr in
            let size = gr.size
            let thumbSize = size.height
            let radius = size.height * 0.5
            let maxX = size.width - thumbSize
            
            let scaleFactor = maxX / Double(range.upperBound - range.lowerBound)
            let sliderViewXOffset = max((self.currentValue - range.lowerBound) * scaleFactor, 0)
           
            ZStack {
                HStack {}
                    .frame(width: size.width, height: size.height * 0.75)
                    .background(LinearGradient(colors: configurator.colors,
                                               startPoint: .leading,
                                               endPoint: .trailing))
                    .clipShape(RoundedRectangle(cornerRadius: radius))
                HStack {
                    configurator.image
                        .resizable()
                        .scaledToFill()
                        .frame(width: thumbSize, height: thumbSize)
                        .scaleEffect(sliding ? 1.2 : 1)
                        .animation(.default, value: sliding)
                        .offset(x: sliderViewXOffset)
                        .gesture(
                            DragGesture(minimumDistance: 0.0)
                                .onChanged { value in
                                    feedback.impactOccurred(intensity: 0.5)
                                    sliding = true
                                    let translationWidth = value.translation.width
                                    let nextCoordinateValue = nextCoordinate(translationWidth, sliderViewXOffset, maxX)
                                    let currentValue = nextCoordinateValue / scaleFactor
                                    self.value = (floor(currentValue) * configurator.step) + range.lowerBound
                                    self.currentValue = currentValue + range.lowerBound
                                }
                                .onEnded { _ in
                                    sliding = false
                                }
                        )
                    Spacer()
                }
            }
        }
    }
    
    private func nextCoordinate(_ currentPosition: Double, _ offest: Double, _ maxX: Double) -> Double {
        //set inital value when start sliding
        if (abs(currentPosition) < 0.1) { self.lastCoordinateValue = offest }
        return currentPosition > 0
                ? min(maxX, self.lastCoordinateValue + currentPosition)
                : max(0, self.lastCoordinateValue + currentPosition)
    }
}

struct SliderView_Previews: PreviewProvider {
    struct PreviewConfigurator: ImageSliderConfigurator {
        var range: ClosedRange<Double> { 1...100 }
        var step: Double { 10 }
        var colors: [Color] { [.green.opacity(0.6), .red.opacity(0.8)] }
        var image: Image { Image(systemName: "clock.circle.fill") }
    }
    static var previews: some View {
        ImageSlider(value: .constant(1), configurator: PreviewConfigurator())
        .frame(height: 44)
        .padding(.horizontal, 10)
    }
}
