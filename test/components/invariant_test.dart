import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:turf/helpers.dart';
import 'package:turf/src/invariant.dart';

main() {
  test('getCoordsOfGeometry', () {
    var polyCoordinates = [[[119.32, -8.7], [119.55, -8.69], [119.51, -8.54], [119.32, -8.7]]];
    expect(getCoords(polyCoordinates), polyCoordinates);

    Feature<Polygon> feature = Feature.fromJson({
      "type": "Feature",
      "geometry": {
        "type": "Polygon",
        "coordinates": polyCoordinates
      },
    });
    expect(getCoords(feature), polyCoordinates);
    expect(getCoordsOfFeature(feature), polyCoordinates);

    Polygon poly1 = feature.geometry!;
    expect(getCoords(poly1), polyCoordinates);
    expect(getCoordsOfGeometry(poly1), polyCoordinates);

    Polygon poly2 = Polygon(coordinates: [
      [
        Position(119.32, -8.7), 
        Position(119.55, -8.69), 
        Position(119.51, -8.54), 
        Position(119.32, -8.7),
      ]
    ]);
    expect(getCoords(poly2), polyCoordinates);
    expect(getCoordsOfGeometry(poly2), polyCoordinates);
  });
}