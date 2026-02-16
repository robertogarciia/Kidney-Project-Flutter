import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoCard extends StatelessWidget {
  final String infoUrl;
  final String infoTitle;
  final String infoDescription;
  final bool isVisto;
  final Function onMarkAsVisto;

  const InfoCard({
    Key? key,
    required this.infoUrl,
    required this.infoTitle,
    required this.infoDescription,
    required this.isVisto,
    required this.onMarkAsVisto,
  }) : super(key: key);

  void _launchURL(BuildContext context) async {
    final Uri url = Uri.parse(infoUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      color: Color(0xFFFFBA00),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              infoTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Descripció:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              infoDescription,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => _launchURL(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: Text("Obrir enllaç"),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isVisto ? null : () => onMarkAsVisto(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isVisto ? Colors.grey : Colors.white,
                ),
                child: Text(isVisto ? 'Vist' : 'Marcar com a vist'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
