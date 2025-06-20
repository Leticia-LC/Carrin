import 'dart:io';
import 'package:flutter/material.dart';
import '../Controller/Database.dart';
import '../Model/Vehicle.dart';
import 'register_vehicles.dart';

class VehiclesScreen extends StatefulWidget {
  @override
  _VehiclesScreenState createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  /// Método para buscar a lista de veículos do banco de dados
  Future<List<Vehicle>> _fetchVehicles() async {
    return await _dbHelper.getVehicles();
  }
  /// Método para deletar um veículo do banco de dados
  void _deleteVehicle(String plate) async {
    await _dbHelper.deleteVehicle(plate);
    setState(() {});
  }
  /// Método para editar um veículo, navegando para a tela de registro
  /// de veículos
  void _editVehicle(Vehicle vehicle) async {
    bool? updatedVehicle = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterVehiclesScreen(vehicle: vehicle),
      ),
    );
    if (updatedVehicle == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Veículos'),
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: _fetchVehicles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar os veículos'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum veículo cadastrado'));
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final vehicle = snapshot.data![index];
                return GestureDetector(
                  onTap: () => _editVehicle(vehicle),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: vehicle.imagePath != null
                              ? Image.file(
                            File(vehicle.imagePath!),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                              : Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Marca: ${vehicle.brand}',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8.0),
                              Text('Modelo: ${vehicle.model}'),
                              SizedBox(height: 8.0),
                              Text('Placa: ${vehicle.plate}'),
                              SizedBox(height: 8.0),
                              Text(
                                  'Ano de Fabricação: ${vehicle.yearOfManufacture}'),
                              SizedBox(height: 8.0),
                              Text('Custo: ${vehicle.cost}'),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Deseja deletar veículo?'),
                                  content: Text(
                                      'Tem certeza que deseja deletar o veículo de placa ${vehicle.plate}?'),
                                  actions: [
                                    TextButton(
                                      child: Text('Não'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Sim'),
                                      onPressed: () {
                                        _deleteVehicle(vehicle.plate);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? vehicleRegistered = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterVehiclesScreen()),
          );
          if (vehicleRegistered == true) {
            setState(() {});
          }
        },
        backgroundColor: Color(0xFF003060),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
