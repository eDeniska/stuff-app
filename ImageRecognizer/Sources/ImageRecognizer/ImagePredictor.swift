/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Makes predictions from images using the MobileNet model.
*/

import Vision
import UIKit

public struct ItemPrediction {
    public let classification: String
    public var confidence: Double

    public init(classification: String, confidence: Double) {
        self.classification = classification
        self.confidence = confidence
    }
}

/// A convenience class that makes image classification predictions.
///
/// The Image Predictor creates and reuses an instance of a Core ML image classifier inside a ``VNCoreMLRequest``.
/// Each time it makes a prediction, the class:
/// - Creates a `VNImageRequestHandler` with an image
/// - Starts an image classification request for that image
/// - Converts the prediction results in a completion handler
/// - Updates the delegate's `predictions` property
/// - Tag: ImagePredictor
public class ImagePredictor {
    /// - Tag: name
    private static func createImageClassifier() -> VNCoreMLModel {
        // Use a default model configuration.
        let defaultConfig = MLModelConfiguration()

        // Create an instance of the image classifier's wrapper class.
        let imageClassifierWrapper = try? MobileNetV2(configuration: defaultConfig)

        guard let imageClassifier = imageClassifierWrapper else {
            fatalError("App failed to create an image classifier model instance.")
        }

        // Get the underlying model instance.
        let imageClassifierModel = imageClassifier.model

        // Create a Vision instance using the image classifier's model instance.
        guard let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifierModel) else {
            fatalError("App failed to create a `VNCoreMLModel` instance.")
        }

        return imageClassifierVisionModel
    }

    public init() {
    }

    /// A common image classifier instance that all Image Predictor instances use to generate predictions.
    ///
    /// Share one ``VNCoreMLModel`` instance --- for each Core ML model file --- across the app,
    /// since each can be expensive in time and resources.
    private static let imageClassifier = createImageClassifier()

    /// The function signature the caller must provide as a completion handler.
    public typealias ImagePredictionHandler = (_ predictions: [ItemPrediction]?) -> Void

    /// A dictionary of prediction handler functions, each keyed by its Vision request.
    private var predictionHandlers = [VNRequest: ImagePredictionHandler]()

    private var handlersLock = os_unfair_lock_s()

    /// Generates a new request instance that uses the Image Predictor's image classifier model.
    private func createImageClassificationRequest() -> VNImageBasedRequest {
        // Create an image classification request with an image classifier model.

        let imageClassificationRequest = VNCoreMLRequest(model: ImagePredictor.imageClassifier,
                                                         completionHandler: visionRequestHandler)

        imageClassificationRequest.imageCropAndScaleOption = .centerCrop
        return imageClassificationRequest
    }

    public func makePredictions(for photo: UIImage) async throws -> [ItemPrediction]? {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try self.makePredictions(for: photo) { predictions in
                        continuation.resume(returning: predictions)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Generates an image classification prediction for a photo.
    /// - Parameter photo: An image, typically of an object or a scene.
    /// - Tag: makePredictions
    public func makePredictions(for photo: UIImage, completionHandler: @escaping ImagePredictionHandler) throws {
        let orientation = CGImagePropertyOrientation(photo.imageOrientation)

        guard let photoImage = photo.cgImage else {
            fatalError("Photo doesn't have underlying CGImage.")
        }

        let imageClassificationRequest = createImageClassificationRequest()
        os_unfair_lock_lock(&handlersLock)
        predictionHandlers[imageClassificationRequest] = completionHandler
        os_unfair_lock_unlock(&handlersLock)

        let handler = VNImageRequestHandler(cgImage: photoImage, orientation: orientation)
        let requests: [VNRequest] = [imageClassificationRequest]

        // Start the image classification request.
        try handler.perform(requests)
    }

    /// The completion handler method that Vision calls when it completes a request.
    /// - Parameters:
    ///   - request: A Vision request.
    ///   - error: An error if the request produced an error; otherwise `nil`.
    ///
    ///   The method checks for errors and validates the request's results.
    /// - Tag: visionRequestHandler
    private func visionRequestHandler(_ request: VNRequest, error: Error?) {
        // Remove the caller's handler from the dictionary and keep a reference to it.
        os_unfair_lock_lock(&handlersLock)
        guard let predictionHandler = predictionHandlers.removeValue(forKey: request) else {
            fatalError("Every request must have a prediction handler.")
        }
        os_unfair_lock_unlock(&handlersLock)

        // Start with a `nil` value in case there's a problem.
        var predictions: [ItemPrediction]? = nil

        // Call the client's completion handler after the method returns.
        defer {
            // Send the predictions back to the client.
            predictionHandler(predictions)
        }

        // Check for an error first.
        if let error = error {
            print("Vision image classification error...\n\n\(error.localizedDescription)")
            return
        }

        // Check that the results aren't `nil`.
        if request.results == nil {
            print("Vision request had no results.")
            return
        }

        // Cast the request's results as an `VNClassificationObservation` array.
        guard let observations = request.results as? [VNClassificationObservation] else {
            // Image classifiers, like MobileNet, only produce classification observations.
            // However, other Core ML model types can produce other observations.
            // For example, a style transfer model produces `VNPixelBufferObservation` instances.
            print("VNRequest produced the wrong result type: \(type(of: request.results)).")
            return
        }

        // Create a prediction array from the observations.
        predictions = observations.map { observation in
            // Convert each observation into an `ImagePredictor.Prediction` instance.
            ItemPrediction(classification: observation.identifier,
                           confidence: Double(observation.confidence))
        }
    }
}
