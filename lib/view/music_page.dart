import 'dart:io';
import 'package:flutter/material.dart';
import 'package:musica/helpers/music_helpers.dart';

class MusicPage extends StatefulWidget {
  final Music? music;
  MusicPage({this.music});

  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  late Music _editedMusic;
  bool _userEdited = false;
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _albumController = TextEditingController();
  final _genreController = TextEditingController();
  final _titleFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.music == null) {
      _editedMusic = Music();
    } else {
      _editedMusic = Music.fromMap(widget.music!.toMap());
      _titleController.text = _editedMusic.title ?? '';
      _artistController.text = _editedMusic.artist ?? '';
      _albumController.text = _editedMusic.album ?? '';
      _genreController.text = _editedMusic.genre ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: requestPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            _editedMusic.title ?? "Nova Música",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.greenAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedMusic.title != null &&
                _editedMusic.title!.isNotEmpty &&
                _editedMusic.artist != null &&
                _editedMusic.artist!.isNotEmpty) {
              Navigator.pop(
                  context, _editedMusic); // Salva ou atualiza a música
            } else {
              FocusScope.of(context)
                  .requestFocus(_titleFocus); // Foca no título
            }
          },
          child: const Icon(Icons.save),
          backgroundColor: Colors.greenAccent,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 150.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: (_editedMusic.img != null &&
                              _editedMusic.img!.isNotEmpty)
                          ? FileImage(File(_editedMusic.img!))
                          : const AssetImage("imgs/music_icon.png")
                              as ImageProvider,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              _buildTextField(
                controller: _titleController,
                label: "Título",
                focusNode: _titleFocus,
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedMusic.title = text.isNotEmpty ? text : '';
                  });
                },
              ),
              _buildTextField(
                controller: _artistController,
                label: "Artista",
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedMusic.artist = text.isNotEmpty ? text : '';
                  });
                },
              ),
              _buildTextField(
                controller: _albumController,
                label: "Álbum",
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedMusic.album = text.isNotEmpty ? text : '';
                  });
                },
              ),
              _buildTextField(
                controller: _genreController,
                label: "Gênero",
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedMusic.genre = text.isNotEmpty ? text : '';
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    FocusNode? focusNode,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blueAccent, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.greenAccent, width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Future<bool> requestPop() async {
    if (_userEdited) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Descartar alterações"),
            content: const Text("Ao sair, as alterações serão perdidas"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Sim"),
              ),
            ],
          );
        },
      );
      return false;
    } else {
      return true;
    }
  }
}
