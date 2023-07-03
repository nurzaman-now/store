import 'package:flutter/material.dart';

class ShowProfile extends StatelessWidget {
  final bool imageNetwork;
  final String image;

  const ShowProfile({
    Key? key,
    this.imageNetwork = false,
    this.image = 'assets/images/avatar.png',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(18)),
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.5,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: imageNetwork ? Image.network(image) : Image.asset(image),
        ));
  }
}
