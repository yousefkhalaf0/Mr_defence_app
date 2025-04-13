import 'package:flutter/material.dart';

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
    iconPath: 'assets/icons/fire.svg',
    backgroundColor: Colors.redAccent,
  ),
  EmergencyType(
    name: 'Animal attack',
    iconPath: 'assets/icons/animal.svg',
    backgroundColor: Colors.green,
  ),
  EmergencyType(
    name: 'Gun',
    iconPath: 'assets/icons/gun.svg',
    backgroundColor: Colors.orange,
  ),
  EmergencyType(
    name: 'Collision',
    iconPath: 'assets/icons/car.svg',
    backgroundColor: Colors.purple,
  ),
  EmergencyType(
    name: 'Missing pet',
    iconPath: 'assets/icons/paw.svg',
    backgroundColor: Colors.teal,
  ),
];
final List<EmergencyType> theWholeEmergencies = [
  EmergencyType(
    name: 'Fire',
    iconPath: 'assets/icons/fire.svg',
    backgroundColor: Colors.redAccent,
  ),
  EmergencyType(
    name: 'Collision',
    iconPath: 'assets/icons/car.svg',
    backgroundColor: Colors.blue,
  ),
  EmergencyType(
    name: 'Missing pet',
    iconPath: 'assets/icons/paw.svg',
    backgroundColor: Colors.teal,
  ),
  EmergencyType(
    name: 'Animal attack',
    iconPath: 'assets/icons/animal.svg',
    backgroundColor: Colors.green,
  ),
  EmergencyType(
    name: 'Gun',
    iconPath: 'assets/icons/gun.svg',
    backgroundColor: Colors.orange,
  ),
  EmergencyType(
    name: 'Break in',
    iconPath: 'assets/icons/breakin.svg',
    backgroundColor: Colors.blue,
  ),
  EmergencyType(
    name: 'Assault/Fight',
    iconPath: 'assets/icons/fight.svg',
    backgroundColor: Colors.red,
  ),
  EmergencyType(
    name: 'Harassment',
    iconPath: 'assets/icons/harassment.svg',
    backgroundColor: Colors.cyan,
  ),
  EmergencyType(
    name: 'Earthquake',
    iconPath: 'assets/icons/earthquake.svg',
    backgroundColor: Colors.brown,
  ),
  EmergencyType(
    name: 'Hazard',
    iconPath: 'assets/icons/hazard.svg',
    backgroundColor: Colors.amber,
  ),
  EmergencyType(
    name: 'Missing person',
    iconPath: 'assets/icons/person.svg',
    backgroundColor: Colors.deepPurple,
  ),
  EmergencyType(
    name: 'Robbery/Theft',
    iconPath: 'assets/icons/robbery.svg',
    backgroundColor: Colors.black54,
  ),
  EmergencyType(
    name: 'Weapon',
    iconPath: 'assets/icons/weapon.svg',
    backgroundColor: Colors.purple,
  ),
  EmergencyType(
    name: 'Weather',
    iconPath: 'assets/icons/weather.svg',
    backgroundColor: Colors.indigo,
  ),
  EmergencyType(
    name: 'Wildfire',
    iconPath: 'assets/icons/wildfire.svg',
    backgroundColor: Colors.lightGreen,
  ),
  EmergencyType(
    name: 'Custom title',
    iconPath: 'assets/icons/custom.svg',
    backgroundColor: Colors.grey,
  ),
];
