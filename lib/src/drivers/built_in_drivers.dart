import 'package:upcloud/src/drivers/byse/byse_driver.dart';
import 'package:upcloud/src/drivers/mediafire/mediafire_driver.dart';
import 'package:upcloud/src/drivers/xvs/xvs_driver.dart';
import 'package:upcloud/src/registry/cloud_driver.dart';

/// Every driver shipped with the package.
const List<CloudDriver> builtInDrivers = [
  xvsDriver,
  byseDriver,
  mediaFireDriver,
];
