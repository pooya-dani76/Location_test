import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class LocController extends GetxController {
  Stream<Position> locationGetter = Geolocator.getPositionStream();
  LatLng? currentPosition;
  LatLng? previousPosition;
  Tween<double>? markerLatTween;
  Tween<double>? markerLngTween;
  MapController mapController = MapController();
  bool zoomed = false;
  bool? gotPermission;

  @override
  onInit() {
    previousPosition = const LatLng(0.0, 0.0);
    currentPosition = const LatLng(0.0, 0.0);
    initLocation();
    super.onInit();
  }

  listener() {
    locationGetter.listen((newPosition) {
      if (currentPosition != null) {
        previousPosition = currentPosition;
      }
      if (!zoomed) {
        mapController.moveAndRotate(LatLng(newPosition.latitude, newPosition.longitude), 18, 0);
        zoomed = true;
      }
      currentPosition = LatLng(newPosition.latitude, newPosition.longitude);
      update();
    });
  }

  initLocation() async {
    gotPermission = await getPermission();
    if (gotPermission!) {
      listener();
    }
    update();
  }

  moveMapCamera(AnimationController animationController) {
    MapCamera camera = mapController.camera;
    Tween<double> latTween =
        Tween<double>(begin: camera.center.latitude, end: currentPosition!.latitude);
    Tween<double> lngTween =
        Tween<double>(begin: camera.center.longitude, end: currentPosition!.longitude);
    Tween<double> degreeTween = Tween<double>(begin: camera.rotation, end: 0.0);
    Tween<double> zoomTween = Tween<double>(begin: camera.zoom, end: 18);

    final Animation<double> animation =
        CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn);

    animationController.addListener(() {
      mapController.moveAndRotate(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation),
          degreeTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.dispose();
      } else if (status == AnimationStatus.dismissed) {
        animationController.dispose();
      }
    });

    animationController.forward();
    update();
  }
}

Future<bool> getPermission() async {
  bool permission = await Permission.location.request().isGranted;
  return permission;
}
