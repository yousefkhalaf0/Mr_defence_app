import 'package:flutter/material.dart';
import '../../../core/utils/assets.dart';

class EmergencyType {
  final String name;
  final String iconPath;
  final Color backgroundColor;

  EmergencyType({
    required this.name,
    required this.iconPath,
    required this.backgroundColor,
  });
}

final List<EmergencyType> emergenciesInAlertPage = [
  EmergencyType(
    name: 'Fire',
    iconPath: AssetsData.fire,
    backgroundColor: Colors.redAccent,
  ),
  EmergencyType(
    name: 'Animal attack',
    iconPath: AssetsData.animalAttack,
    backgroundColor: Colors.green,
  ),
  EmergencyType(
    name: 'Gun',
    iconPath: AssetsData.gun,
    backgroundColor: Colors.orange,
  ),
  EmergencyType(
    name: 'Collision',
    iconPath: AssetsData.collision,
    backgroundColor: Colors.purple,
  ),
  EmergencyType(
    name: 'Missing pet',
    iconPath: AssetsData.missingPet,
    backgroundColor: Colors.teal,
  ),
];

final List<EmergencyType> theWholeEmergencies = [
  EmergencyType(
    name: 'Fire',
    iconPath: AssetsData.fire,
    backgroundColor: Colors.redAccent,
  ),
  EmergencyType(
    name: 'Collision',
    iconPath: AssetsData.collision,
    backgroundColor: Colors.blue,
  ),
  EmergencyType(
    name: 'Missing pet',
    iconPath: AssetsData.missingPet,
    backgroundColor: Colors.teal,
  ),
  EmergencyType(
    name: 'Animal attack',
    iconPath: AssetsData.animalAttack,
    backgroundColor: Colors.green,
  ),
  EmergencyType(
    name: 'Gun',
    iconPath: AssetsData.gun,
    backgroundColor: Colors.orange,
  ),
  EmergencyType(
    name: 'Break in',
    iconPath: AssetsData.breakIn,
    backgroundColor: Colors.blue,
  ),
  EmergencyType(
    name: 'Assault/Fight',
    iconPath: AssetsData.assault,
    backgroundColor: Colors.red,
  ),
  EmergencyType(
    name: 'Harassment',
    iconPath: AssetsData.harassment,
    backgroundColor: Colors.cyan,
  ),
  EmergencyType(
    name: 'Earthquake',
    iconPath: AssetsData.earthquake,
    backgroundColor: Colors.brown,
  ),
  EmergencyType(
    name: 'Hazard',
    iconPath: AssetsData.hazard,
    backgroundColor: Colors.amber,
  ),
  EmergencyType(
    name: 'Missing person',
    iconPath: AssetsData.missingPerson,
    backgroundColor: Colors.deepPurple,
  ),
  EmergencyType(
    name: 'Robbery/Theft',
    iconPath: AssetsData.robbery,
    backgroundColor: Colors.black54,
  ),
  EmergencyType(
    name: 'Weapon',
    iconPath: AssetsData.weapon,
    backgroundColor: Colors.purple,
  ),
  EmergencyType(
    name: 'Weather',
    iconPath: AssetsData.weather,
    backgroundColor: Colors.indigo,
  ),
  EmergencyType(
    name: 'Wildfire',
    iconPath: AssetsData.wildfire,
    backgroundColor: Colors.lightGreen,
  ),
  EmergencyType(
    name: 'Custom title',
    iconPath: AssetsData.custom,
    backgroundColor: Colors.grey,
  ),
];
