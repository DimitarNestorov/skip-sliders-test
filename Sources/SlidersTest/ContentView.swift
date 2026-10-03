// Licensed under the GNU General Public License v2.0 or later
// SPDX-License-Identifier: GPL-2.0-or-later

import SwiftUI


struct ContentView: View {
    @AppStorage("name") var welcomeName = "Skipper"

    var body: some View {
        WelcomeView(welcomeName: $welcomeName)
    }
}

struct WelcomeView : View {
    @State var testViewModel = TestViewModel(duration: 30, range: 0.0...15.0)
    @State var heartBeating = false
    @Binding var welcomeName: String

    var body: some View {
        VStack(spacing: 0) {
            Text("Hello [\(welcomeName)](https://skip.dev)!")
                .padding()

			RangeSlider(
				track: AnyView(
					RangeSlider.HorizontalRangeTrack(
						view: AnyView(Color.red),
						mask: AnyView(Rectangle()),
					)
					.background(RoundedRectangle(cornerRadius: 6.0).foregroundColor(Color.accentColor.opacity(0.2)))
					.frame(maxHeight: 100)
				),
				range: $testViewModel.range,
				in: 0.0 ... testViewModel.duration,
				distance: 0.0 ... 30.0,
				onEditingChanged: { dragging in
                    print("dragging: \(dragging)")
				}
			)
			
        }
        .font(.largeTitle)
    }
}


@Observable public class TestViewModel: Identifiable {
	let duration: Double
	var range: ClosedRange<Double> = 0.0 ... 30.0
	
	public init(duration: Double, range: ClosedRange<Double>? = nil) {
		self.duration = duration
		self.range = range ?? 0.0 ... 30.0
	}
}

