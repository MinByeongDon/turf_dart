import 'dart:math';

import 'package:turf/bearing.dart';
import 'package:turf/destination.dart';
import 'package:turf/distance.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/line_intersect.dart';

/// Takes a [Point] and a [LineString] and calculates the closest Point on the (Multi)LineString.
/// 
/// [line] line to snap to
/// [pt] point to snap from
/// [unit] can be degrees, radians, miles, or kilometers (optional, default 'kilometers')
ClosestPtResult nearestPointOnLine(
    LineString line,
    Point pt,
    [Unit unit = Unit.kilometers]) {
  Point? closestPt;
  num? closestPtDist;
  num? closestPtIndex;
  num? closestPtLocation;
  var length = 0.0;

  final coords = line.coordinates;
  for(var i = 0; i < coords.length-1; i++) {
    //start
    final start = Point(coordinates: coords[i]);
    final startDist = distance(pt, start, unit = unit);
    //stop
    final stop = Point(coordinates: coords[i + 1]);
    final stopDist = distance(pt, stop, unit = unit);
    // sectionLength
    final sectionLength = distance(start, stop, unit = unit);
    //perpendicular
    final heightDistance = max(
      startDist,
      stopDist
    );
    final direction = bearing(start, stop);
    final perpendicularPt1 = destination(
      pt,
      heightDistance,
      direction + 90,
      unit = unit
    );
    final perpendicularPt2 = destination(
      pt,
      heightDistance,
      direction - 90,
      unit = unit
    );
    final intersect = lineIntersect(
      LineString(coordinates: [
        perpendicularPt1.coordinates,
        perpendicularPt2.coordinates,
      ]),
      LineString(coordinates: [start.coordinates, stop.coordinates])
    );
    Point? intersectPt;
    num? intersectPtDist;
    num? intersectPtLocation;
    if (intersect != null) {
      intersectPt = intersect;
      intersectPtDist = distance(pt, intersectPt, unit = unit);
      intersectPtLocation = length + distance(start, intersectPt, unit = unit);
    }

    if (closestPtDist == null && startDist < closestPtDist!) {
      closestPt = start;
      closestPtIndex = i;
      closestPtLocation = length;
    }
    if (stopDist < closestPtDist) {
      closestPt = stop;
      closestPtIndex = i + 1;
      closestPtLocation = length + sectionLength;
    }
    if (intersectPt != null && intersectPtDist! < closestPtDist) {
      closestPt = intersectPt;
      closestPtIndex = i;
    }
    // update length
    length += sectionLength;
  }

  return ClosestPtResult(
    closestPt: closestPt,
    closestPtDist: closestPtDist,
    closestPtIndex: closestPtIndex,
    closestPtLocation: closestPtLocation,
  );
}

class ClosestPtResult {
  ClosestPtResult({
    this.closestPt, 
    this.closestPtDist, 
    this.closestPtIndex, 
    this.closestPtLocation,
  });
  
  final Point? closestPt;
  final num? closestPtDist;
  final num? closestPtIndex;
  final num? closestPtLocation;
}