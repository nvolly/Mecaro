//
//  LocationService.swift
//  Mecaro
//
//  Location and CoreLocation management
//

import Foundation
import CoreLocation
import Combine

@MainActor
class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    // MARK: - Published Properties
    
    @Published var currentLocation: CLLocation?
    @Published var currentCity: String?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocating = false
    @Published var error: LocationError?
    
    // MARK: - Private Properties
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    // Default location (Bucharest center)
    static let defaultLocation = CLLocation(latitude: 44.4268, longitude: 26.1025)
    static let defaultCity = "București"
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    // MARK: - Public Methods
    
    /// Request location permission
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Start updating location
    func startUpdating() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestPermission()
            return
        }
        
        isLocating = true
        locationManager.startUpdatingLocation()
    }
    
    /// Stop updating location
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
        isLocating = false
    }
    
    /// Get current location once
    func getCurrentLocation() async -> CLLocation {
        // If we already have a recent location, return it
        if let location = currentLocation,
           Date().timeIntervalSince(location.timestamp) < 300 { // 5 minutes
            return location
        }
        
        // Check permission
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return Self.defaultLocation
        }
        
        // Request location update
        isLocating = true
        locationManager.requestLocation()
        
        // Wait for location (with timeout)
        return await withCheckedContinuation { continuation in
            Task {
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 second timeout
                
                await MainActor.run {
                    isLocating = false
                    continuation.resume(returning: currentLocation ?? Self.defaultLocation)
                }
            }
        }
    }
    
    /// Calculate distance between two coordinates
    func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation) / 1000 // kilometers
    }
    
    /// Reverse geocode to get city name
    func reverseGeocode(location: CLLocation) async -> String? {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                return placemark.locality ?? placemark.administrativeArea
            }
        } catch {
            print("Geocoding error: \(error)")
        }
        return nil
    }
    
    /// Get coordinates from address
    func geocode(address: String) async -> CLLocationCoordinate2D? {
        do {
            let placemarks = try await geocoder.geocodeAddressString(address + ", Romania")
            if let location = placemarks.first?.location {
                return location.coordinate
            }
        } catch {
            print("Geocoding error: \(error)")
        }
        return nil
    }
    
    // MARK: - Permission Status
    
    var hasPermission: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    var needsPermission: Bool {
        authorizationStatus == .notDetermined
    }
    
    var permissionDenied: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }
    
    /// Effective location (current or default)
    var effectiveLocation: CLLocation {
        currentLocation ?? Self.defaultLocation
    }
    
    /// Effective city (current or default)
    var effectiveCity: String {
        currentCity ?? Self.defaultCity
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            self.currentLocation = location
            self.isLocating = false
            self.error = nil
            
            // Update city name
            if let city = await reverseGeocode(location: location) {
                self.currentCity = city
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.isLocating = false
            
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    self.error = .permissionDenied
                case .locationUnknown:
                    self.error = .locationUnknown
                case .network:
                    self.error = .networkError
                default:
                    self.error = .unknown(error.localizedDescription)
                }
            } else {
                self.error = .unknown(error.localizedDescription)
            }
        }
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                // Permission granted, request location
                manager.requestLocation()
            case .denied, .restricted:
                self.error = .permissionDenied
            default:
                break
            }
        }
    }
}

// MARK: - Location Errors

enum LocationError: LocalizedError {
    case permissionDenied
    case locationUnknown
    case networkError
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Accesul la locație a fost refuzat. Te rugăm să activezi locația din Setări."
        case .locationUnknown:
            return "Nu am putut determina locația ta."
        case .networkError:
            return "Eroare de rețea la obținerea locației."
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - CLLocationCoordinate2D Extension

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

