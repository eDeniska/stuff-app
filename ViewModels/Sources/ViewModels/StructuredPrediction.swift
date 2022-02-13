//
//  StructuredPrediction.swift
//  
//
//  Created by Danis Tazetdinov on 16.01.2022.
//

import Foundation
import ImageRecognizer
import DataModel

struct StructuredPrediction {
    var confidence: Double
    let prediction: String
    let detectedItem: DetectedItem
}

extension Array where Element == ItemPrediction {
    func aggregate(minimumConfidence: Double = 0.1) -> [StructuredPrediction] {
        // we're summing up confidence here.
        // this is not correct, however, I'd like to give boost for those options

        map { StructuredPrediction(confidence: $0.confidence,
                                   prediction: $0.classification,
                                   detectedItem: DetectedItem(prediction: $0.classification)) }
        .reduce([StructuredPrediction]()) { predictions, prediction in
            guard prediction.confidence >= minimumConfidence else {
                return predictions
            }
            var existingPredictions = predictions
            if let index = existingPredictions.firstIndex(where: { $0.detectedItem == prediction.detectedItem}) {
                var existingPrediction = existingPredictions[index]
                existingPrediction.confidence += prediction.confidence
                existingPredictions[index] = existingPrediction
            } else {
                existingPredictions.append(prediction)
            }
            return existingPredictions
        }
    }
}
