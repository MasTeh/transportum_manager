abstract class Vehicle {
  final int id;
  final String modelName;
  final int client_id;  
  final String number;
  final bool isOwn;

  const Vehicle(this.id, this.modelName, this.client_id, this.number, this.isOwn);
}
