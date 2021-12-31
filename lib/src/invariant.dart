import 'package:turf/helpers.dart';

/// Unwrap coordinates from a Feature, Geometry Object or an Array
///
/// [coords] coords Feature, Geometry Object or an Array
/// 
/// return coordinates
/// 
/// For example:
///
/// ```dart
/// Feature<Polygon> feature = Feature.fromJson({
///   "type": "Feature",
///   "geometry": {
///     "type": "Polygon",
///     "coordinates": [[[119.32, -8.7], [119.55, -8.69], [119.51, -8.54], [119.32, -8.7]]]
///   },
/// });
/// var coords = getCoords(feature);
/// /*= [[[119.32, -8.7], [119.55, -8.69], [119.51, -8.54], [119.32, -8.7]]] */
/// ```
dynamic getCoords(dynamic coords) {
  if (coords is List) {
    return coords;
  }

  // Feature
  if(coords is Feature<GeometryType>) {
    if(coords.geometry != null && [
      GeoJSONObjectType.point,
      GeoJSONObjectType.lineString,
      GeoJSONObjectType.polygon,
      GeoJSONObjectType.multiPoint,
      GeoJSONObjectType.multiLineString,
      GeoJSONObjectType.multiPolygon,
    ].contains(coords.geometry!.type)) {
      return coords.geometry!.coordinates;
    }
  } else if(coords is GeometryType) {
    // Geometry
    return coords.coordinates;
  }

  throw Exception("coords must be GeoJSON Feature, Geometry Object or an Array");
}

/// Unwrap coordinates from a Feature
///
/// [coords] coords Feature
/// 
/// return coordinates
/// 
/// For example:
///
/// ```dart
/// Feature<Polygon> feature = Feature.fromJson({
///   "type": "Feature",
///   "geometry": {
///     "type": "Polygon",
///     "coordinates": [[[119.32, -8.7], [119.55, -8.69], [119.51, -8.54], [119.32, -8.7]]]
///   },
/// });
/// var coords = getCoordsOfFeature(feature);
/// /*= [[[119.32, -8.7], [119.55, -8.69], [119.51, -8.54], [119.32, -8.7]]] */
/// ```
T getCoordsOfFeature<T>(Feature<GeometryType<T>> coords) {
  if(coords.geometry != null && [
    GeoJSONObjectType.point,
    GeoJSONObjectType.lineString,
    GeoJSONObjectType.polygon,
    GeoJSONObjectType.multiPoint,
    GeoJSONObjectType.multiLineString,
    GeoJSONObjectType.multiPolygon,
  ].contains(coords.geometry!.type)) {
    return coords.geometry!.coordinates;
  }
  throw Exception("coords must be GeoJSON Feature");
}

/// Unwrap coordinates from a Geometry Object
///
/// [coords] coords Geometry Object
/// 
/// return coordinates
/// 
/// For example:
///
/// ```dart
/// Polygon poly = Polygon(coordinates: [
///   [
///     Position(119.32, -8.7), 
///     Position(119.55, -8.69), 
///     Position(119.51, -8.54), 
///     Position(119.32, -8.7),
///   ]
/// ]);
/// var coords = getCoordsOfGeometry(poly);
/// /*= [[[119.32, -8.7], [119.55, -8.69], [119.51, -8.54], [119.32, -8.7]]] */
/// ```
T getCoordsOfGeometry<T>(GeometryType<T> coords) {
  return coords.coordinates;
}
