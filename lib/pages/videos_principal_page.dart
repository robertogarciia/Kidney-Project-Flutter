import 'package:flutter/material.dart';
import 'package:kidneyproject/pages/sign_in_page.dart';
import 'package:kidneyproject/pages/sign_Up_Choose.dart';
import 'package:kidneyproject/components/video_card.dart';

class Videos extends StatelessWidget {
  const Videos({Key? key}) : super(key: key);

  void iniciS(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignIn()),
    );
  }

  void register(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpChoose()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: const SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              // Text per al títol de la pàgina
              Text(
                'Videos',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Afegim la targeta del vídeo
              VideoCard(videoUrl: 'https://youtu.be/kuNXAJfEm08?si=fTvNPa2g2gt9TvH2', videoTitle: 'Ibai MCY vs RMA'),
              VideoCard(videoUrl: 'https://youtu.be/mQOWHLGuhOQ?si=y8RC3Ts5nDNL-Z5k', videoTitle: 'Pre Match BCN vs PSG'),

            ],
          ),
        ),
      ),
    );
  }
}
