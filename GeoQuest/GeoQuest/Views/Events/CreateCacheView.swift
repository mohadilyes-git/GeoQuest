import SwiftUI
import MapKit
import CoreLocation

// Tappable map for users

struct TappableMapView: UIViewRepresentable {
    @Binding var droppedPin: CLLocationCoordinate2D?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator

        // Request location permission and track user
        context.coordinator.locationManager.delegate = context.coordinator
        context.coordinator.locationManager.requestWhenInUseAuthorization()
        context.coordinator.locationManager.startUpdatingLocation()
        context.coordinator.mapView = mapView

        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        mapView.addGestureRecognizer(tap)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        if let pin = droppedPin {
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin
            annotation.title = "Cache Location"
            uiView.addAnnotation(annotation)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        var parent: TappableMapView
        var locationManager = CLLocationManager()
        var mapView: MKMapView?
        var hasZoomedToUser = false

        init(_ parent: TappableMapView) {
            self.parent = parent
        }

        // Centers the map on the user's location the first time it's received
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard !hasZoomedToUser, let location = locations.first else { return }
            hasZoomedToUser = true

            let region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            mapView?.setRegion(region, animated: true)
            manager.stopUpdatingLocation()
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let mapView = gesture.view as! MKMapView
            let screenPoint = gesture.location(in: mapView)
            let coordinate = mapView.convert(screenPoint, toCoordinateFrom: mapView)
            parent.droppedPin = coordinate
        }
    }
}

// Create Cache View

struct CreateCacheView: View {

    let event: Event
    let onSuccess: () -> Void

    @Environment(\.dismiss) var dismiss

    @State private var cacheName = ""
    @State private var cacheDescription = ""
    @State private var cacheClue = ""
    @State private var cachePoints = "10"
    @State private var cacheImageURL = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var cacheCreated = false

    @State private var droppedPin: CLLocationCoordinate2D? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color.gqLightStone.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {

                        if cacheCreated {
                            // Success state
                            VStack(spacing: 16) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(Color.gqLeafGreen)
                                Text("Cache Created!")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color.gqLeafGreen)
                                Text("The cache has been added to the map")
                                    .foregroundColor(.secondary)
                                Button("Done") {
                                    onSuccess()
                                    dismiss()
                                }
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.gqLeafGreen)
                                .cornerRadius(12)
                                .padding(.horizontal, 16)
                            }
                            .padding(.top, 40)

                        } else {
                            // Map Pin Dropper
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "map.fill")
                                        .foregroundColor(Color.gqLeafGreen)
                                    Text(droppedPin == nil
                                         ? "Tap the map to place your cache"
                                         : "📍 Pin placed — tap again to move it")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 4)

                                TappableMapView(droppedPin: $droppedPin)
                                    .frame(height: 220)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                droppedPin != nil ? Color.gqLeafGreen : Color.gray.opacity(0.3),
                                                lineWidth: droppedPin != nil ? 2 : 1
                                            )
                                    )

                                if let pin = droppedPin {
                                    Text(String(format: "Lat: %.5f,  Lon: %.5f", pin.latitude, pin.longitude))
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 4)
                                }
                            }
                            .padding(.horizontal, 16)

                            // Form fields for cache
                            VStack(spacing: 14) {
                                GQTextField(
                                    icon: "mappin",
                                    placeholder: "Cache name",
                                    text: $cacheName
                                )

                                GQTextField(
                                    icon: "text.alignleft",
                                    placeholder: "Description",
                                    text: $cacheDescription
                                )

                                GQTextField(
                                    icon: "questionmark.circle",
                                    placeholder: "Clue",
                                    text: $cacheClue
                                )

                                GQTextField(
                                    icon: "star",
                                    placeholder: "Points (e.g. 10)",
                                    text: $cachePoints
                                )
                                .keyboardType(.numberPad)

                                GQTextField(
                                    icon: "photo",
                                    placeholder: "Image URL",
                                    text: $cacheImageURL
                                )
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                            }
                            .padding(.horizontal, 16)

                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .foregroundColor(Color.gqCacheRed)
                                    .font(.system(size: 13))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                            }

                            //Submit Button
                            Button {
                                Task { await createCache() }
                            } label: {
                                ZStack {
                                    Text("Add Cache to Map")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                        .opacity(isLoading ? 0 : 1)
                                    if isLoading {
                                        ProgressView().tint(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.gqLeafGreen)
                                .cornerRadius(12)
                            }
                            .disabled(isLoading)
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Add Cache")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color.gqLeafGreen)
                }
            }
        }
    }

    // Create Cache Logic

    func createCache() async {
        errorMessage = ""

        if cacheName.isEmpty {
            errorMessage = "Please enter a cache name"
            return
        }

        if cacheDescription.isEmpty {
            errorMessage = "Please enter a description"
            return
        }

        if cacheClue.isEmpty {
            errorMessage = "Please enter a clue"
            return
        }

        if cachePoints.isEmpty {
            errorMessage = "Please enter a points value"
            return
        }

        if cacheImageURL.isEmpty {
            errorMessage = "Please enter an image URL"
            return
        }

        guard let points = Int(cachePoints), points > 0 else {
            errorMessage = "Points must be a valid number greater than 0"
            return
        }

        guard let pin = droppedPin else {
            errorMessage = "Please tap the map to place your cache location"
            return
        }

        isLoading = true

        let payload = CachePayload(
            cacheName: cacheName,
            cacheDescription: cacheDescription,
            cacheEventID: event.eventID,
            cacheImageURL: cacheImageURL,
            cacheClue: cacheClue,
            cachePoints: points,
            cacheLatitude: pin.latitude,
            cacheLongitude: pin.longitude
        )

        do {
            let _ = try await GeoQuestAPIManager.shared.createCache(payload: payload)
            cacheCreated = true
        } catch {
            errorMessage = "Failed to create cache. Please try again."
        }

        isLoading = false
    }
}


#Preview {
    CreateCacheView(event: Event(
        eventID: 1,
        eventName: "Test",
        eventDescription: "Test",
        eventOwnerID: 1,
        eventIspublic: false,
        eventStart: "2026-04-09T12:00:00.000Z",
        eventFinish: "2026-04-09T13:00:00.000Z",
        eventStatusID: 1,
        eventOwner: nil,
        eventStatus: nil
    ), onSuccess: {})
}
