


import 'package:turf/helpers.dart';

Point? lineIntersect(LineString line1, LineString line2) {
  Map<String, bool> unique = {};
  if (line1.coordinates.length == 2 && line2.coordinates.length == 2) {
    final intersect = intersects(line1, line2);
    if (intersect != null) {
      return intersect;
    }
  }
  return null;
}

/// Find a point that intersects LineStrings with two coordinates each
/// 
/// [line1] {Feature<LineString>} line1 GeoJSON LineString (Must only contain 2 coordinates)
/// 
/// [line2] {Feature<LineString>} line2 GeoJSON LineString (Must only contain 2 coordinates)
/// 
/// returns {Feature<Point>} intersecting GeoJSON Point
Point? intersects(LineString line1, LineString line2) {
  final coords1 = line1.coordinates;
  final coords2 = line2.coordinates;
  if (coords1.length != 2) {
    throw Exception("<intersects> line1 must only contain 2 coordinates");
  }
  if (coords2.length != 2) {
    throw Exception("<intersects> line2 must only contain 2 coordinates");
  }
  final x1 = coords1[0][0]!;
  final y1 = coords1[0][1]!;
  final x2 = coords1[1][0]!;
  final y2 = coords1[1][1]!;
  final x3 = coords2[0][0]!;
  final y3 = coords2[0][1]!;
  final x4 = coords2[1][0]!;
  final y4 = coords2[1][1]!;
  final denom = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1);
  final numeA = (x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3);
  final numeB = (x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3);

  if (denom == 0) {
    if (numeA == 0 && numeB == 0) {
      return null;
    }
    return null;
  }

  final uA = numeA / denom;
  final uB = numeB / denom;

  if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {
    final x = x1 + uA * (x2 - x1);
    final y = y1 + uA * (y2 - y1);
    return Point(coordinates: Position(x, y));
  }
  return null;
}

