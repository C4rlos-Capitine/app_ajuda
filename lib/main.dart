import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LocationForm(),
    );
  }
}

class LocationForm extends StatefulWidget {
  @override
  _LocationFormState createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  Position? _currentPosition;

  Future<void> _getCurrentLocation() async {
    try{
      bool serviceEnabled;
      LocationPermission permission;

      // Verifica se o serviço de localização está habilitado
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // O serviço de localização não está habilitado, retorne um erro.
        return Future.error('O serviço de localização está desativado.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return Future.error('Permissão de localização negada.');
        }
      }

    // Obtém a posição atual
    _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    }catch(e){
      print(e);
    }

  }

  Future<void> _sendData() async {
    try{
      print("Hi");
      if (_currentPosition != null) {
        final String email = _emailController.text;
        final String message = _messageController.text;
        final double latitude = _currentPosition!.latitude;
        final double longitude = _currentPosition!.longitude;


         var url = Uri.http('192.168.10.135:5141', '/api/PedidoAjuda');

    // Enviar a requisição POST com o corpo JSON
    var response = await http
        .post(url,
            headers: {'Content-Type': 'application/json'},           body: jsonEncode({
            'email': email,
            'message': message,
            'latitude': latitude,
            'longitude': longitude,
          }),)
        .timeout(Duration(seconds: 10));


        if (response.statusCode == 200) {
          // Sucesso
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dados enviados com sucesso!')));
        } else {
          // Erro
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao enviar dados.')));
        }
      }
    }catch(e){
      print(e);
    }
    await _getCurrentLocation();


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quidgest"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Color.fromARGB(255, 248, 245, 245),
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 30),
            child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: InputBorder.none,
                label: Text("Email"),
                icon: Icon(Icons.mail_outline, color: Colors.green[650]),
                hintText: "Email",
                labelStyle: TextStyle(color: Colors.green[650]),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(20),
            child: TextFormField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text("Mensagem:"),
                icon: Icon(Icons.message, color: Colors.green[650]),
                hintText: "Escreva a Mensagem",
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: (){
                    _sendData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    fixedSize: Size(300, 50),
                  ),
                  child: Text(
                    "Enviar localização",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
