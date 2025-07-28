import Foundation
import CoreLocation

/// Service for managing location services and location-based features
class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationEnabled = false
    @Published var lastKnownLocation: CLLocation?
    @Published var locationError: LocationError?
    
    private var locationUpdateHandler: ((CLLocation) -> Void)?
    private var errorHandler: ((LocationError) -> Void)?
    
    private override init() {
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Public Methods
    
    /// Requests location permission
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Starts location updates
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestLocationPermission()
            return
        }
        
        locationManager.startUpdatingLocation()
        isLocationEnabled = true
    }
    
    /// Stops location updates
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        isLocationEnabled = false
    }
    
    /// Gets current location once
    func getCurrentLocation(completion: @escaping (Result<CLLocation, LocationError>) -> Void) {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            completion(.failure(.permissionDenied))
            return
        }
        
        locationUpdateHandler = { location in
            completion(.success(location))
            self.locationUpdateHandler = nil
        }
        
        errorHandler = { error in
            completion(.failure(error))
            self.errorHandler = nil
        }
        
        locationManager.requestLocation()
    }
    
    /// Gets location for emergency services
    func getEmergencyLocation(completion: @escaping (Result<CLLocation, LocationError>) -> Void) {
        // For emergency situations, use the most recent location available
        if let location = currentLocation ?? lastKnownLocation {
            completion(.success(location))
        } else {
            getCurrentLocation(completion: completion)
        }
    }
    
    /// Shares location with emergency services
    func shareLocationWithEmergencyServices() {
        getEmergencyLocation { result in
            switch result {
            case .success(let location):
                self.sendLocationToEmergencyServices(location)
            case .failure(let error):
                print("Failed to get location for emergency services: \(error)")
            }
        }
    }
    
    /// Gets nearby emergency resources
    func getNearbyEmergencyResources(completion: @escaping ([EmergencyResource]) -> Void) {
        guard let location = currentLocation ?? lastKnownLocation else {
            completion([])
            return
        }
        
        // This would typically call an API to get nearby resources
        let resources = findNearbyResources(near: location)
        completion(resources)
    }
    
    /// Gets location-based crisis alerts
    func getLocationBasedAlerts(completion: @escaping ([CrisisAlert]) -> Void) {
        guard let location = currentLocation ?? lastKnownLocation else {
            completion([])
            return
        }
        
        // This would typically call an API to get location-based alerts
        let alerts = findLocationBasedAlerts(near: location)
        completion(alerts)
    }
    
    /// Checks if location services are available
    var isLocationServicesAvailable: Bool {
        return CLLocationManager.locationServicesEnabled() && 
               (authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways)
    }
    
    /// Gets location accuracy
    var locationAccuracy: CLLocationAccuracy? {
        return currentLocation?.horizontalAccuracy
    }
    
    /// Gets location timestamp
    var locationTimestamp: Date? {
        return currentLocation?.timestamp
    }
    
    // MARK: - Private Methods
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update every 10 meters
    }
    
    private func sendLocationToEmergencyServices(_ location: CLLocation) {
        // This would send location to emergency services
        // Implementation would depend on the specific emergency service API
        print("Sending location to emergency services: \(location.coordinate)")
    }
    
    private func findNearbyResources(near location: CLLocation) -> [EmergencyResource] {
        // This would typically call an API to find nearby emergency resources
        // For now, return empty array
        return []
    }
    
    private func findLocationBasedAlerts(near location: CLLocation) -> [CrisisAlert] {
        // This would typically call an API to find location-based crisis alerts
        // For now, return empty array
        return []
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        lastKnownLocation = location
        
        // Call the update handler if set
        locationUpdateHandler?(location)
        
        // Clear the handler after use
        locationUpdateHandler = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let locationError = LocationError.from(error)
        self.locationError = locationError
        
        // Call the error handler if set
        errorHandler?(locationError)
        
        // Clear the handler after use
        errorHandler = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            isLocationEnabled = true
            if isLocationEnabled {
                startLocationUpdates()
            }
        case .denied, .restricted:
            isLocationEnabled = false
            locationError = .permissionDenied
        case .notDetermined:
            isLocationEnabled = false
        @unknown default:
            isLocationEnabled = false
        }
    }
}

// MARK: - Location Error

enum LocationError: Error, LocalizedError {
    case permissionDenied
    case locationServicesDisabled
    case locationUnavailable
    case networkError
    case timeout
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission denied"
        case .locationServicesDisabled:
            return "Location services are disabled"
        case .locationUnavailable:
            return "Location is currently unavailable"
        case .networkError:
            return "Network error occurred"
        case .timeout:
            return "Location request timed out"
        case .unknown:
            return "Unknown location error"
        }
    }
    
    static func from(_ error: Error) -> LocationError {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                return .permissionDenied
            case .locationUnknown:
                return .locationUnavailable
            case .network:
                return .networkError
            default:
                return .unknown
            }
        }
        return .unknown
    }
}

// MARK: - Location Utilities

extension LocationService {
    /// Calculates distance between two locations
    func distance(from location1: CLLocation, to location2: CLLocation) -> CLLocationDistance {
        return location1.distance(from: location2)
    }
    
    /// Checks if a location is within a certain radius
    func isLocation(_ location: CLLocation, within radius: CLLocationDistance, of center: CLLocation) -> Bool {
        return location.distance(from: center) <= radius
    }
    
    /// Gets formatted address from location
    func getAddress(from location: CLLocation, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first else {
                completion(nil)
                return
            }
            
            let address = [
                placemark.thoroughfare,
                placemark.locality,
                placemark.administrativeArea,
                placemark.postalCode
            ].compactMap { $0 }.joined(separator: ", ")
            
            completion(address.isEmpty ? nil : address)
        }
    }
    
    /// Gets location from address
    func getLocation(from address: String, completion: @escaping (CLLocation?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            guard let placemark = placemarks?.first else {
                completion(nil)
                return
            }
            
            completion(placemark.location)
        }
    }
}

// MARK: - Location Monitoring

extension LocationService {
    /// Starts monitoring a specific region
    func startMonitoringRegion(center: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String) {
        let region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        locationManager.startMonitoring(for: region)
    }
    
    /// Stops monitoring a specific region
    func stopMonitoringRegion(identifier: String) {
        let regions = locationManager.monitoredRegions
        if let region = regions.first(where: { $0.identifier == identifier }) {
            locationManager.stopMonitoring(for: region)
        }
    }
    
    /// Stops monitoring all regions
    func stopMonitoringAllRegions() {
        let regions = locationManager.monitoredRegions
        for region in regions {
            locationManager.stopMonitoring(for: region)
        }
    }
} 