import 'package:flutter/material.dart';
import 'package:store/common/styles.dart';
import 'package:store/ui/popup/dialog.dart';
import 'package:store/ui/widgets/custom_button.dart';

class Confirm extends StatelessWidget {
  final String message;
  final String messageDialog;
  final String createPage;
  final String imageDialog;
  final bool isBack;
  final bool isGo;
  final bool isShowDialog;
  final bool isRedirect;
  final void Function(bool?) onConfirmation;
  final dynamic argument;

  const Confirm({
    super.key,
    required this.message,
    this.messageDialog = '',
    required this.createPage,
    this.imageDialog = '',
    this.isBack = true,
    this.isGo = false,
    this.isShowDialog = false,
    this.isRedirect = false,
    this.argument = 0,
    required this.onConfirmation,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
          dialogBackgroundColor: primaryColor, // Set your desired color here
        ),
        child: contentBox(context));
  }

  contentBox(context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      content: SizedBox(
        width: 260,
        height: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.0)),
              child: Text(
                message,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            const SizedBox(
              height: 17,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButtonTheme(
                    data: CustomButtonStyle(
                        color: Colors.white,
                        horizontal: MediaQuery.of(context).size.width * 0.12,
                        vertical: 8.0),
                    child: TextButton(
                      onPressed: () {
                        if (isBack) {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        }
                        if (isShowDialog) {
                          Navigator.of(context).pop();
                          showDialog(
                              context: context,
                              builder: (context) => MyDialog(
                                    message: messageDialog,
                                    image: imageDialog,
                                    createPage: createPage,
                                    isGo: isGo,
                                    isRedirect: isRedirect,
                                    type: 1,
                                    arguments: argument,
                                  ));
                        } else if (isGo) {
                          if (argument == 0) {
                            Navigator.pushReplacementNamed(
                              context,
                              createPage,
                            );
                          } else {
                            Navigator.pushReplacementNamed(context, createPage,
                                arguments: argument);
                          }
                        } else {
                          Navigator.of(context).pop();
                        }

                        onConfirmation(true);
                      },
                      child: const Text(
                        'Ya',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    )),
                const SizedBox(
                  width: 13,
                ),
                TextButtonTheme(
                    data: CustomButtonStyle(
                        color: Colors.white,
                        horizontal: MediaQuery.of(context).size.width * 0.1,
                        vertical: 8.0),
                    child: TextButton(
                      onPressed: () {
                        onConfirmation(false);
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Tidak',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
