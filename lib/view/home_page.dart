import 'dart:io';
import 'package:flutter/material.dart';
import 'package:musica/helpers/music_helpers.dart';
import 'package:musica/view/music_page.dart';

enum OrderOptions { ordenarAZ, ordenarZA }

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MusicHelper helper = MusicHelper();
  List<Music> musics = [];

  @override
  void initState() {
    super.initState();
    getAllMusics();
  }

  void getAllMusics() {
    helper.getAllMusic().then((list) {
      setState(() {
        musics = list;
      });
    });
  }

  void openMusicBox() {
    showMusicPage();
  }

  void logout() {
    // Adicione a lógica de logout aqui
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Icon(Icons.music_note),
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
      backgroundColor: Colors.white,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: openMusicBox,
            child: const Icon(Icons.add),
            backgroundColor: Colors.greenAccent,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: musics.length,
        itemBuilder: (context, index) {
          if (index < musics.length) {
            return musicCard(context, index);
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget musicCard(BuildContext context, int index) {
    final music = musics[index];

    return GestureDetector(
      child: Card(
        elevation: 5, // Sombra para dar profundidade
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Cantos arredondados
        ),
        color: Colors.blueGrey[50], // Cor mais suave
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Aumento do padding
          child: Row(
            children: [
              Container(
                width: 70.0,
                height: 70.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: music.img != null
                        ? FileImage(File(music.img!))
                        : const AssetImage("imgs/music_icon.png")
                            as ImageProvider,
                  ),
                ),
              ),
              const SizedBox(width: 15), // Espaço entre imagem e texto
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    music.title ?? "Título desconhecido",
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    music.artist ?? "Artista desconhecido",
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    music.album ?? "Álbum desconhecido",
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    music.genre ?? "Gênero desconhecido",
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        showOptions(context, index);
      },
    );
  }

  void showMusicPage({Music? music}) async {
    final recMusic = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MusicPage(music: music)),
    );

    print("Returned music: $recMusic"); // Log para verificar a música recebida

    if (recMusic != null) {
      if (music != null) {
        await helper.updateMusic(recMusic);
      } else {
        await helper.saveMusic(recMusic);
      }
      getAllMusics(); // Atualiza a lista de músicas
    }
  }
  void showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.purpleAccent),
                  title: const Text("Editar",
                      style: TextStyle(color: Colors.black87)),
                  onTap: () {
                    Navigator.pop(context);
                    showMusicPage(music: musics[index]);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.redAccent),
                  title: const Text("Excluir",
                      style: TextStyle(color: Colors.black87)),
                  onTap: () async {
                    await helper.deleteMusic(musics[index].id!);
                    setState(() {
                      musics.removeAt(index);
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.ordenarAZ:
        musics.sort((a, b) => a.title!.compareTo(b.title!));
        break;
      case OrderOptions.ordenarZA:
        musics.sort((a, b) => b.title!.compareTo(a.title!));
        break;
    }
    setState(() {});
  }
}
