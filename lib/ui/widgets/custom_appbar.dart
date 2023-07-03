import 'package:flutter/material.dart';

import '../../common/styles.dart';
import 'custom_text.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String titleActions;
  final bool isActionIcon;
  final List<Widget> actionIcon;
  final Widget bottomItem;
  final bool isBottom;
  final bool isBack;

  const CustomAppbar({
    Key? key,
    this.title = '',
    this.titleActions = '',
    this.isActionIcon = false,
    this.actionIcon = const [],
    this.bottomItem = const SizedBox(),
    this.isBottom = false,
    this.isBack = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: title.isNotEmpty
          ? Container(
              padding: const EdgeInsets.only(left: 16),
              child: CustomText(
                text: title,
                style: const TextStyle(
                    color: primaryColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
            )
          : null,
      leading: isBack
          ? Navigator.of(context).canPop()
              ? GestureDetector(
                  child: SizedBox(
                    height: 36,
                    width: 36,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 8, 0, 8),
                      decoration: BoxDecoration(
                          border: Border.all(color: secondaryColor, width: 1),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                  })
              : null
          : null,
      actions: isActionIcon
          ? actionIcon
          : [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(right: 22),
                child: CustomText(
                  text: titleActions,
                  style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'work sans',
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ],
      bottom: isBottom
          ? PreferredSize(
              preferredSize: const Size.fromHeight(10.0), child: bottomItem)
          : null,
    );
  }

  @override
  Size get preferredSize => isBottom
      ? const Size.fromHeight(kToolbarHeight * 2)
      : const Size.fromHeight(kToolbarHeight);
}
