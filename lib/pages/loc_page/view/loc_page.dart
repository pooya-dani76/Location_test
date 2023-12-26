import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:loc_test/pages/loc_page/controller/loc_controller.dart';

class LocPage extends StatefulWidget {
  const LocPage({super.key});

  @override
  State<LocPage> createState() => _LocPageState();
}

class _LocPageState extends State<LocPage> with TickerProviderStateMixin {
  LocController locController = Get.put(LocController());

  void animatedMapMove() {
    final animationController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    locController.moveMapCamera(animationController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<LocController>(builder: (controller) {
        return Stack(
          children: [
            FlutterMap(
              mapController: controller.mapController,
              options: const MapOptions(
                initialZoom: 3,
                initialCenter: LatLng(2.0, 5.0),
                maxZoom: 22,
                minZoom: 3,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                if (controller.gotPermission != null) ...{
                  if (controller.gotPermission!) ...{
                    if (controller.currentPosition != null) ...{
                      MarkerLayer(
                        markers: [
                          Marker(
                            child: const Icon(
                              CupertinoIcons.location_solid,
                              color: Colors.red,
                              size: 40,
                            ),
                            point: controller.currentPosition!,
                            rotate: false,
                          ),
                        ],
                      ),
                    }
                  }
                }
              ],
            ),
            if (controller.gotPermission != null) ...{
              if (controller.gotPermission!) ...{
                Positioned(
                  bottom: 0,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => animatedMapMove(),
                        child: Container(
                            color: Colors.grey,
                            padding: const EdgeInsets.all(5),
                            child: const Icon(Icons.my_location_rounded)),
                      ),
                    ],
                  ),
                ),
              }
            }
          ],
        );
      }),
    );
  }
}
