import SwiftUI

struct RangeSlider: View {
	@State internal var dragOffset: CGFloat?
	
	private var configuration: RangeSliderStyleConfiguration

	private let lowerThumb = DefaultThumb()
	private let upperThumb = DefaultThumb()
	
	let track: AnyView

	private let lowerThumbSize = CGSize(width: 27, height: 27)
	private let upperThumbSize = CGSize(width: 27, height: 27)

	private let lowerThumbInteractiveSize = CGSize(width: 44, height: 44)
	private let upperThumbInteractiveSize = CGSize(width: 44, height: 44)

	private let options: RangeSliderOptions = .defaultOptions

	@ViewBuilder func makeBody(configuration: RangeSliderStyleConfiguration) -> some View {
		GeometryReader { geometry in
			ZStack {
				self.track
					.environment(\.trackRange, configuration.range.wrappedValue)
					.environment(\.rangeTrackConfiguration, RangeTrackConfiguration(
						bounds: configuration.bounds,
						lowerLeadingOffset: self.lowerThumbSize.width / 2,
						lowerTrailingOffset: self.lowerThumbSize.width / 2 + self.upperThumbSize.width,
						upperLeadingOffset: self.lowerThumbSize.width + self.upperThumbSize.width / 2,
						upperTrailingOffset: self.upperThumbSize.width / 2
					))
//					.accentColor(Color.accentColor)

				ZStack {
					self.lowerThumb
						.frame(width: self.lowerThumbSize.width, height: self.lowerThumbSize.height)
				}
				.frame(minWidth: self.lowerThumbInteractiveSize.width, minHeight: self.lowerThumbInteractiveSize.height)
				.position(
					x: distanceFrom(
						value: configuration.range.wrappedValue.lowerBound,
						availableDistance: geometry.size.width - self.upperThumbSize.width,
						bounds: configuration.bounds,
						leadingOffset: self.lowerThumbSize.width / 2,
						trailingOffset: self.lowerThumbSize.width / 2
					),
					y: geometry.size.height / 2
				)
				.gesture(
					DragGesture(minimumDistance: 0)
						.onChanged { gestureValue in
							configuration.onEditingChanged(true)

							if configuration.dragOffset.wrappedValue == nil {
								configuration.dragOffset.wrappedValue = gestureValue.startLocation.x - distanceFrom(
									value: configuration.range.wrappedValue.lowerBound,
									availableDistance: geometry.size.width - self.upperThumbSize.width,
									bounds: configuration.bounds,
									leadingOffset: self.lowerThumbSize.width / 2,
									trailingOffset: self.lowerThumbSize.width / 2
								)
							}

							let computedLowerBound = valueFrom(
								distance: gestureValue.location.x - (configuration.dragOffset.wrappedValue ?? 0),
								availableDistance: geometry.size.width - self.upperThumbSize.width,
								bounds: configuration.bounds,
								step: configuration.step,
								leadingOffset: self.lowerThumbSize.width / 2,
								trailingOffset: self.lowerThumbSize.width / 2
							)
							
							configuration.range.wrappedValue = rangeFrom(
								updatedLowerBound: computedLowerBound,
								upperBound: configuration.range.wrappedValue.upperBound,
								bounds: configuration.bounds,
								distance: configuration.distance,
								forceAdjacent: options.contains(.forceAdjacentValue)
							)
						}
						.onEnded { _ in
							configuration.dragOffset.wrappedValue = nil
							configuration.onEditingChanged(false)
						}
				)

				ZStack {
					self.upperThumb
						.frame(width: self.upperThumbSize.width, height: self.upperThumbSize.height)
				}
				.frame(minWidth: self.upperThumbInteractiveSize.width, minHeight: self.upperThumbInteractiveSize.height)
				.position(
					x: distanceFrom(
						value: configuration.range.wrappedValue.upperBound,
						availableDistance: geometry.size.width,
						bounds: configuration.bounds,
						leadingOffset: self.lowerThumbSize.width + self.upperThumbSize.width / 2,
						trailingOffset: self.upperThumbSize.width / 2
					),
					y: geometry.size.height / 2
				)
				.gesture(
					DragGesture(minimumDistance: 0)
						.onChanged { gestureValue in
							configuration.onEditingChanged(true)


							if configuration.dragOffset.wrappedValue == nil {
								configuration.dragOffset.wrappedValue = gestureValue.startLocation.x - distanceFrom(
									value: configuration.range.wrappedValue.upperBound,
									availableDistance: geometry.size.width,
									bounds: configuration.bounds,
									leadingOffset: self.lowerThumbSize.width + self.upperThumbSize.width / 2,
									trailingOffset: self.upperThumbSize.width / 2
								)
							}

							let computedUpperBound = valueFrom(
								distance: gestureValue.location.x - (configuration.dragOffset.wrappedValue ?? 0),
								availableDistance: geometry.size.width,
								bounds: configuration.bounds,
								step: configuration.step,
								leadingOffset: self.lowerThumbSize.width + self.upperThumbSize.width / 2,
								trailingOffset: self.upperThumbSize.width / 2
							)
							
							configuration.range.wrappedValue = rangeFrom(
								lowerBound: configuration.range.wrappedValue.lowerBound,
								updatedUpperBound: computedUpperBound,
								bounds: configuration.bounds,
								distance: configuration.distance,
								forceAdjacent: options.contains(.forceAdjacentValue)
							)
						}
						.onEnded { _ in
							configuration.dragOffset.wrappedValue = nil
							configuration.onEditingChanged(false)
						}
				)

			}
			.frame(height: geometry.size.height)
		}
		.frame(minHeight: max(self.lowerThumbInteractiveSize.height, self.upperThumbInteractiveSize.height))
	}

	var body: some View {
		self.makeBody(configuration: self.configuration.with(dragOffset: self.$dragOffset))
	}
	
	struct RangeSliderOptions: OptionSet {
		let rawValue: Int
		
		static let forceAdjacentValue = RangeSliderOptions(rawValue: 1 << 0)
		static let defaultOptions: RangeSliderOptions = .forceAdjacentValue
		
		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
	}
	
	struct RangeSliderStyleConfiguration {
		let range: Binding<ClosedRange<CGFloat>>
		let bounds: ClosedRange<CGFloat>
		let step: CGFloat
		let distance: ClosedRange<CGFloat>
		let onEditingChanged: (Bool) -> Void
		var dragOffset: Binding<CGFloat?>
		
		func with(dragOffset: Binding<CGFloat?>) -> Self {
			var mutSelf = self
			mutSelf.dragOffset = dragOffset
			return mutSelf
		}
	}
	
	struct RangeTrackConfiguration {
		static let defaultConfiguration = RangeTrackConfiguration()
		
		let bounds: ClosedRange<CGFloat>
		
		let lowerLeadingOffset: CGFloat
		let lowerTrailingOffset: CGFloat
		let upperLeadingOffset: CGFloat
		let upperTrailingOffset: CGFloat
		
		init(bounds: ClosedRange<CGFloat> = 0.0...1.0, lowerLeadingOffset: CGFloat = 0, lowerTrailingOffset: CGFloat = 0, upperLeadingOffset: CGFloat = 0, upperTrailingOffset: CGFloat = 0) {
			self.bounds = bounds
			self.lowerLeadingOffset = lowerLeadingOffset
			self.lowerTrailingOffset = lowerTrailingOffset
			self.upperLeadingOffset = upperLeadingOffset
			self.upperTrailingOffset = upperTrailingOffset
		}
		
		init(bounds: ClosedRange<CGFloat> = 0.0...1.0, lowerOffset: CGFloat = 0, upperOffset: CGFloat = 0) {
			self.bounds = bounds
			self.lowerLeadingOffset = lowerOffset / 2
			self.lowerTrailingOffset = lowerOffset / 2 + upperOffset
			self.upperLeadingOffset = lowerOffset + upperOffset / 2
			self.upperTrailingOffset = upperOffset / 2
		}
		
		init(bounds: ClosedRange<CGFloat> = 0.0...1.0, offsets: CGFloat = 0) {
			self.bounds = bounds
			self.lowerLeadingOffset = offsets / 2
			self.lowerTrailingOffset = offsets / 2 + offsets
			self.upperLeadingOffset = offsets + offsets / 2
			self.upperTrailingOffset = offsets / 2
		}
	}
	
	struct DefaultThumb: View {
		var body: some View {
			Capsule()
				.foregroundColor(.white)
				.shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1.5)
		}
	}

	struct HorizontalRangeTrack: View {
		@Environment(\.trackRange) var range
		@Environment(\.rangeTrackConfiguration) var configuration
		let view: AnyView
		let mask: AnyView

		var body: some View {
			GeometryReader { geometry in
				self.view
//					.accentColor(Color.accentColor)
					.mask(
						ZStack {
							self.mask
								 .frame(
									 width: rangeDistance(
										overallLength: geometry.size.width,
										range: self.range,
										bounds: self.configuration.bounds,
										lowerStartOffset: self.configuration.lowerLeadingOffset,
										lowerEndOffset: self.configuration.lowerTrailingOffset,
										upperStartOffset: self.configuration.upperLeadingOffset,
										upperEndOffset: self.configuration.upperTrailingOffset
									 )
								 )
								 .offset(
									 x: distanceFrom(
										value: self.range.lowerBound,
										availableDistance: geometry.size.width,
										bounds: self.configuration.bounds,
										leadingOffset: self.configuration.lowerLeadingOffset,
										trailingOffset: self.configuration.lowerTrailingOffset
									 )
								 )
						}
						.frame(width: geometry.size.width, alignment: .leading)
					)
			}
		}
	}

	
	struct DefaultHorizontalValueView: View {
		var body: some View {
			Capsule()
				.foregroundColor(Color.accentColor)
				.frame(height: 3)
		}
	}
}

extension RangeSlider {
	init(configuration: RangeSliderStyleConfiguration, track: AnyView) {
		self.configuration = configuration
		self.track = track
	}
}

extension RangeSlider {
	init<V>(
		track: AnyView,
		range: Binding<ClosedRange<V>>,
		in bounds: ClosedRange<V> = 0.0...1.0,
		step: V.Stride = 0.001,
		distance: ClosedRange<V> = 0.0 ... .infinity,
		onEditingChanged: @escaping (Bool) -> Void = { _ in }
	) where V : BinaryFloatingPoint, V.Stride : BinaryFloatingPoint {
		self.init(
			configuration: RangeSliderStyleConfiguration(
				range: Binding(
					get: { CGFloat(range.wrappedValue.clamped(to: bounds).lowerBound) ... CGFloat(range.wrappedValue.clamped(to: bounds).upperBound) },
					set: { range.wrappedValue = V($0.lowerBound) ... V($0.upperBound) }
				),
				bounds: CGFloat(bounds.lowerBound) ... CGFloat(bounds.upperBound),
				step: CGFloat(step),
				distance: CGFloat(distance.lowerBound) ... CGFloat(distance.upperBound),
				onEditingChanged: onEditingChanged,
				dragOffset: .constant(0)
			),
			track: track,
		)
	}
}

extension RangeSlider {
	public init<V>(
		track: AnyView,
		range: Binding<ClosedRange<V>>,
		in bounds: ClosedRange<V> = 0...1,
		step: V.Stride = 1,
		distance: ClosedRange<V> = 0 ... .max,
		onEditingChanged: @escaping (Bool) -> Void = { _ in }
	) where V : FixedWidthInteger, V.Stride : FixedWidthInteger {
		self.init(
			configuration: RangeSliderStyleConfiguration(
				range: Binding(
					get: { CGFloat(range.wrappedValue.clamped(to: bounds).lowerBound) ... CGFloat(range.wrappedValue.clamped(to: bounds).upperBound) },
					set: { range.wrappedValue = V($0.lowerBound) ... V($0.upperBound) }
				),
				bounds: CGFloat(bounds.lowerBound) ... CGFloat(bounds.upperBound),
				step: CGFloat(step),
				distance: CGFloat(distance.lowerBound) ... CGFloat(distance.upperBound),
				onEditingChanged: onEditingChanged,
				dragOffset: .constant(0)
			),
			track: track,
		)
	}
}


@inlinable func rangeFrom(updatedLowerBound: CGFloat, upperBound: CGFloat, bounds: ClosedRange<CGFloat>, distance: ClosedRange<CGFloat>, forceAdjacent: Bool) -> ClosedRange<CGFloat> {
	if forceAdjacent {
		let finalLowerBound = min(updatedLowerBound, bounds.upperBound - distance.lowerBound)
		let finalUpperBound = min(min(max(updatedLowerBound + distance.lowerBound, upperBound), updatedLowerBound + distance.upperBound), bounds.upperBound)
		return finalLowerBound ... finalUpperBound
	} else {
		let finalLowerBound = min(updatedLowerBound, upperBound - distance.lowerBound)
		let finalUpperBound = min(upperBound, updatedLowerBound + distance.upperBound)
		return finalLowerBound ... finalUpperBound
	}
}

@inlinable func rangeFrom(lowerBound: CGFloat, updatedUpperBound: CGFloat, bounds: ClosedRange<CGFloat>, distance: ClosedRange<CGFloat>, forceAdjacent: Bool) -> ClosedRange<CGFloat> {
	if forceAdjacent {
		let finalLowerBound = max(max(min(lowerBound, updatedUpperBound - distance.lowerBound), updatedUpperBound - distance.upperBound), bounds.lowerBound)
		let finalUpperBound = max(updatedUpperBound, bounds.lowerBound + distance.lowerBound)
		return finalLowerBound ... finalUpperBound
	} else {
		let finalLowerBound = max(lowerBound, updatedUpperBound - distance.upperBound)
		let finalUpperBound = max(lowerBound + distance.lowerBound, updatedUpperBound)
		return finalLowerBound ... finalUpperBound
	}
}

/// Calculates value for relative point in bounds with step.
/// Example: For relative value 0.5 in range 2.0..4.0 produces 3.0
@inlinable func valueFrom(distance: CGFloat, availableDistance: CGFloat, bounds: ClosedRange<CGFloat> = 0.0...1.0, step: CGFloat = 0.001, leadingOffset: CGFloat = 0, trailingOffset: CGFloat = 0) -> CGFloat {
	let relativeValue = (distance - leadingOffset) / (availableDistance - (leadingOffset + trailingOffset))
	let newValue = bounds.lowerBound + (relativeValue * (bounds.upperBound - bounds.lowerBound))
	let steppedNewValue = (round(newValue / step) * step)
	let validatedValue = min(bounds.upperBound, max(bounds.lowerBound, steppedNewValue))
	return validatedValue
}

/// Calculates distance from zero in points
@inlinable func distanceFrom(value: CGFloat, availableDistance: CGFloat, bounds: ClosedRange<CGFloat> = 0.0...1.0, leadingOffset: CGFloat = 0, trailingOffset: CGFloat = 0) -> CGFloat {
	guard availableDistance > leadingOffset + trailingOffset else { return 0 }
	let boundsLenght = bounds.upperBound - bounds.lowerBound
	let relativeValue = (value - bounds.lowerBound) / boundsLenght
	let offset = (leadingOffset - ((leadingOffset + trailingOffset) * relativeValue))
	return offset + (availableDistance * relativeValue)
}


/// Calculates range distance in points
@inlinable func rangeDistance(overallLength: CGFloat, range: ClosedRange<CGFloat>, bounds: ClosedRange<CGFloat> = 0.0...1.0, lowerStartOffset: CGFloat = 0, lowerEndOffset: CGFloat = 0, upperStartOffset: CGFloat = 0, upperEndOffset: CGFloat = 0) -> CGFloat {
	let offsetLowerValue = distanceFrom(value: range.lowerBound, availableDistance: overallLength, bounds: bounds, leadingOffset: lowerStartOffset, trailingOffset: lowerEndOffset)
	let offsetUpperValue = distanceFrom(value: range.upperBound, availableDistance: overallLength, bounds: bounds, leadingOffset: upperStartOffset, trailingOffset: upperEndOffset)
	return max(0, offsetUpperValue - offsetLowerValue)
}

extension EnvironmentValues {
	var trackRange: ClosedRange<CGFloat> {
		get {
			return self[TrackRangeKey.self]
		}
		set {
			self[TrackRangeKey.self] = newValue
		}
	}
}

struct TrackRangeKey: EnvironmentKey {
	static let defaultValue: ClosedRange<CGFloat> = 0.0...1.0
}

extension EnvironmentValues {
	var rangeTrackConfiguration: RangeSlider.RangeTrackConfiguration {
		get {
			return self[RangeTrackConfigurationKey.self]
		}
		set {
			self[RangeTrackConfigurationKey.self] = newValue
		}
	}
}

struct RangeTrackConfigurationKey: EnvironmentKey {
	static let defaultValue: RangeSlider.RangeTrackConfiguration = .defaultConfiguration
}
