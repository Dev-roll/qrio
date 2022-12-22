import 'package:flutter/material.dart';

class BottomSnackBar extends SnackBar {
  BottomSnackBar(
    BuildContext context,
    String text, {
    IconData? icon,
    SnackBarAction? bottomSnackbarAction,
    Color? background,
    Color? foreground,
    int? seconds,
  }) : super(
          elevation: 20,
          backgroundColor:
              background ?? Theme.of(context).colorScheme.secondary,
          behavior: SnackBarBehavior.floating,
          clipBehavior: Clip.antiAlias,
          dismissDirection: DismissDirection.down,
          margin: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 32,
          ),
          duration: Duration(seconds: seconds ?? 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon == null)
                const SizedBox(
                  width: 8,
                ),
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                  child: Icon(
                    icon,
                    color: foreground?.withOpacity(0.8) ??
                        Theme.of(context)
                            .colorScheme
                            .onSecondary
                            .withOpacity(0.8),
                  ),
                ),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                      color: foreground ??
                          Theme.of(context).colorScheme.onSecondary,
                      overflow: TextOverflow.fade),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
            ],
          ),
          action: bottomSnackbarAction,
        );
}
