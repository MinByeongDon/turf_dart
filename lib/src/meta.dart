import 'geojson.dart';

typedef GeomEachCallback = dynamic Function(
  GeometryObject? currentGeometry,
  int? featureIndex,
  Map<String, dynamic>? featureProperties,
  BBox? featureBBox,
  dynamic featureId,
);

/// A simple class to manage short circuiting from *Each functions while still
/// allowing an Exception to be thrown and raised
class _ShortCircuit {
  _ShortCircuit();
}

/// Iterate over each geometry in [geoJSON], calling [callback] on each
/// iteration. Similar to Array.forEach()
///
/// For example:
///
/// ```dart
/// FeatureCollection featureCollection = FeatureCollection(
///   features: [
///     point1,
///     point2,
///     point3,
///   ],
/// );
/// geomEach(featureCollection, (currentGeometry, featureIndex, featureProperties, featureBBox, featureId) {
///   someOperationOnEachPoint(currentGeometry);
/// });
/// ```
void geomEach(GeoJSONObject geoJSON, GeomEachCallback callback) {
  try {
    if (geoJSON is FeatureCollection) {
      _forEachGeomInFeatureCollection(geoJSON, callback);
    } else if (geoJSON is Feature) {
      _forEachGeomInFeature(geoJSON, callback, 0);
    } else if (geoJSON is GeometryObject) {
      _forEachGeomInGeometryObject(geoJSON, callback, {}, null, null, 0);
    } else {
      throw Exception('Unknown Geometry Type');
    }
  } on _ShortCircuit {
    return;
  }
}

void _forEachGeomInFeatureCollection(
    FeatureCollection featureCollection, GeomEachCallback callback) {
  int featuresLength = featureCollection.features.length;
  for (int featureIndex = 0; featureIndex < featuresLength; featureIndex++) {
    _forEachGeomInFeature(
        featureCollection.features[featureIndex], callback, featureIndex);
  }
}

void _forEachGeomInFeature(Feature<GeometryObject> feature,
    GeomEachCallback callback, int featureIndex) {
  _forEachGeomInGeometryObject(feature.geometry, callback, feature.properties,
      feature.bbox, feature.id, featureIndex);
}

void _forEachGeomInGeometryObject(
    GeometryObject? geometryObject,
    GeomEachCallback callback,
    Map<String, dynamic>? featureProperties,
    BBox? featureBBox,
    dynamic featureId,
    int featureIndex) {
  if (geometryObject is GeometryType) {
    if (callback(
          geometryObject,
          featureIndex,
          featureProperties,
          featureBBox,
          featureId,
        ) ==
        false) {
      throw _ShortCircuit();
    }
  } else if (geometryObject is GeometryCollection) {
    num geometryCollectionLength = geometryObject.geometries.length;

    for (int geometryIndex = 0;
        geometryIndex < geometryCollectionLength;
        geometryIndex++) {
      _forEachGeomInGeometryObject(
        geometryObject.geometries[geometryIndex],
        callback,
        featureProperties,
        featureBBox,
        featureId,
        featureIndex,
      );
    }
  } else {
    throw Exception('Unknown Geometry Type');
  }
}

/// Callback for propEach
typedef PropEachCallback = dynamic Function(
    Map<String, dynamic>? currentProperties, num featureIndex);

/// Iterate over properties in any [geoJSON] object, calling [callback] on each
/// iteration. Similar to Array.forEach()
///
/// For example:
///
/// ```dart
/// FeatureCollection featureCollection = FeatureCollection(
///   features: [
///     point1,
///     point2,
///     point3,
///   ],
/// );
/// propEach(featureCollection, (currentProperties, featureIndex) {
///   someOperationOnEachProperty(currentProperties);
/// });
/// ```
void propEach(GeoJSONObject geoJSON, PropEachCallback callback) {
  if (geoJSON is FeatureCollection) {
    for (var i = 0; i < geoJSON.features.length; i++) {
      if (callback(geoJSON.features[i].properties, i) == false) break;
    }
  } else if (geoJSON is Feature) {
    callback(geoJSON.properties, 0);
  } else {
    throw Exception('Unknown Feature/FeatureCollection Type');
  }
}

/// Callback for featureEach
typedef FeatureEachCallback = dynamic Function(
    Feature currentFeature, num featureIndex);

/// Iterate over features in any [geoJSON] object, calling [callback] on each
/// iteration. Similar to Array.forEach.
///
/// For example:
///
/// ```dart
/// FeatureCollection featureCollection = FeatureCollection(
///   features: [
///     point1,
///     point2,
///     point3,
///   ],
/// );
/// featureEach(featureCollection, (currentFeature, featureIndex) {
///   someOperationOnEachFeature(currentFeature);
/// });
/// ```
void featureEach(GeoJSONObject geoJSON, FeatureEachCallback callback) {
  if (geoJSON is Feature) {
    callback(geoJSON, 0);
  } else if (geoJSON is FeatureCollection) {
    for (var i = 0; i < geoJSON.features.length; i++) {
      if (callback(geoJSON.features[i], i) == false) break;
    }
  } else {
    throw Exception('Unknown Feature/FeatureCollection Type');
  }
}

/// Callback for flattenEach
typedef FlattenEachCallback = dynamic Function(
    Feature currentFeature, int featureIndex, int multiFeatureIndex);

/// Iterate over flattened features in any [geoJSON] object, similar to
/// Array.forEach, calling [callback] on each flattened feature

///
/// flattenEach(featureCollection, (currentFeature, featureIndex, multiFeatureIndex) {
///   someOperationOnEachFeature(currentFeature);
/// });
/// ```
void flattenEach(GeoJSONObject geoJSON, FlattenEachCallback callback) {
  try {
    geomEach(geoJSON, (currentGeomObject, featureIndex, featureProperties,
        featureBBox, featureId) {
      if (currentGeomObject is GeometryCollection) {
        // turf.js code didn't really handle the GeometryCollection case
        // TODO figure out how to support this and what the behavior is supposed
        // to be
        return;
      } else if (currentGeomObject == null ||
          currentGeomObject is Point ||
          currentGeomObject is LineString ||
          currentGeomObject is Polygon) {
        if (callback(
                Feature(
                  geometry: currentGeomObject,
                  properties: featureProperties,
                  bbox: featureBBox,
                  id: featureId,
                ),
                featureIndex ?? 0,
                0) ==
            false) throw _ShortCircuit();
        return;
      }

      _forEachFeatureOfMultiFeature(
          currentGeomObject, callback, featureProperties, featureIndex);
    });
  } on _ShortCircuit {
    return;
  }
}

void _forEachFeatureOfMultiFeature(
    GeoJSONObject currentGeomObject,
    FlattenEachCallback callback,
    Map<String, dynamic>? featureProperties,
    int? featureIndex) {
  if (currentGeomObject is GeometryType) {
    for (int multiFeatureIndex = 0;
        multiFeatureIndex < currentGeomObject.coordinates.length;
        multiFeatureIndex++) {
      GeometryType geom;
      if (currentGeomObject is MultiPoint) {
        geom = Point(
            coordinates: currentGeomObject.coordinates[multiFeatureIndex]);
      } else if (currentGeomObject is MultiLineString) {
        geom = LineString(
            coordinates: currentGeomObject.coordinates[multiFeatureIndex]);
      } else if (currentGeomObject is MultiPolygon) {
        geom = Polygon(
            coordinates: currentGeomObject.coordinates[multiFeatureIndex]);
      } else {
        throw Exception('Unsupported Geometry type');
      }
      _callFlattenEachCallback(
          callback, geom, featureProperties, featureIndex, multiFeatureIndex);
    }
  }
}

void _callFlattenEachCallback(
    FlattenEachCallback callback,
    GeometryType<dynamic> geom,
    Map<String, dynamic>? featureProperties,
    int? featureIndex,
    int multiFeatureIndex) {
  if (callback(
          Feature(
            geometry: geom,
            properties: featureProperties,
          ),
          featureIndex ?? 0,
          multiFeatureIndex) ==
      false) {
    throw _ShortCircuit();
  }
}
