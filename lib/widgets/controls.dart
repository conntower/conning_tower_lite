import 'dart:io';

import 'package:conning_tower/constants.dart';
import 'package:conning_tower/main.dart';
import 'package:conning_tower/widgets/dailog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../generated/l10n.dart';
import '../helper.dart';
import '../pages/home.dart';

enum ConFunc {
  adjustWindow,
  loadHome,
  httpRedirect,
  bottomUp,
  scrollUp,
  scrollDown,
  goBack,
  goForward,
  refresh,
  clearCookies,
  clearCache,
  doRequest,
  navi2About,
  navi2Tool,
  navi2Settings,
  toolsSheet,
}

class Controls extends StatelessWidget {
  Controls(this._webViewControllerFuture, CookieManager? cookieManager,
      {Key? key, required this.notifyParent, required this.orientation})
      : cookieManager = cookieManager ?? CookieManager(),
        super(key: key);
  final Function() notifyParent;
  final Future<WebViewController> _webViewControllerFuture;
  late final CookieManager cookieManager;
  final Orientation orientation;
  final TextEditingController _urlTextController = TextEditingController(text: customHomeUrl.isNotEmpty ? customHomeUrl : kGoogle);


  final Map funcMap = {
    0: ConFunc.loadHome,
    // 1: ConFunc.httpRedirect,
    // 1: ConFunc.navi2Tool,
    4: ConFunc.toolsSheet,
    // 2: ConFunc.bottomUp,
    1: ConFunc.refresh,
    // 4: ConFunc.scrollUp,
    // 5: ConFunc.scrollDown,
    2: ConFunc.goBack,
    3: ConFunc.goForward,
    // 5: ConFunc.navi2Settings,
    // 6: ConFunc.navi2About,
    // 1: ConFunc.adjustWindow,
    // 8: ConFunc.clearCookies,
    // 9: ConFunc.clearCache
  };

  final Map naviItems = {
    0: 0, //loadHome
    1: 1, //navi2Tool
    2: 5, //navi2Settings
    3: 6, //navi2About
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _webViewControllerFuture,
        builder:
            (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
          final WebViewController? controller = snapshot.data;
          if (orientation == Orientation.portrait) {
            return BottomNavigationBar(
              showSelectedLabels: true,
              // showUnselectedLabels: true,
              currentIndex: naviItems[0],
              unselectedItemColor: CupertinoColors.inactiveGray,
              selectedItemColor: Theme.of(context).primaryColor,
              onTap: ((value) async {
                _onTap(controller!, value, context);
              }),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.home),
                  label: S.of(context).AppHome,
                ),

                BottomNavigationBarItem(
                  icon: const Icon(
                    CupertinoIcons.refresh,
                    color: CupertinoColors.destructiveRed,
                  ),
                  label: S.of(context).AppRefresh,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.back),
                  label: S.of(context).AppBack,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.forward),
                  label: S.of(context).AppForward,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.game_controller),
                  label: S.of(context).ToolsButton,
                ),
                // BottomNavigationBarItem(
                //   icon: const Icon(
                //     CupertinoIcons.settings,
                //   ),
                //   label: S.of(context).SettingsButton,
                // ),
                // BottomNavigationBarItem(
                //   icon: const Icon(
                //     CupertinoIcons.info,
                //   ),
                //   label: S.of(context).AboutButton.replaceAll('\n', ''),
                // ),
              ],
            );
          }
          return NavigationRail(
            labelType: NavigationRailLabelType.all,
            selectedIndex: naviItems[0],
            groupAlignment: 0,
            onDestinationSelected: (int index) async {
              _onTap(controller!, index, context);
            },
            destinations: [
              NavigationRailDestination(
                icon: const Icon(CupertinoIcons.home),
                label: Text(
                  S.of(context).AppHome,
                ),
              ),

              NavigationRailDestination(
                icon: const Icon(
                  CupertinoIcons.refresh,
                  color: CupertinoColors.destructiveRed,
                ),
                label: Text(S.of(context).AppRefresh),
              ),
              NavigationRailDestination(
                icon: const Icon(CupertinoIcons.back),
                label: Text(S.of(context).AppBack),
              ),
              NavigationRailDestination(
                icon: const Icon(CupertinoIcons.forward),
                label: Text(S.of(context).AppForward),
              ),
              NavigationRailDestination(
                icon: const Icon(CupertinoIcons.game_controller),
                label: Text(S.of(context).ToolsButton),
              ),
              // NavigationRailDestination(
              //   icon: const Icon(
              //     CupertinoIcons.settings,
              //   ),
              //   label: Text(S.of(context).SettingsButton),
              // ),
              // NavigationRailDestination(
              //   icon: const Icon(
              //     CupertinoIcons.info,
              //   ),
              //   label: Text(
              //     S.of(context).AboutButton,
              //     textAlign: TextAlign.center,
              //   ),
              // ),
            ],
          );
        });
  }

  void _onTap(WebViewController controller, int value, BuildContext context) {
    HapticFeedback.mediumImpact();
    var func = funcMap[value];
    switch (func) {
      case ConFunc.toolsSheet:
        _showToolActionSheet(context, controller);
        break;
      case ConFunc.navi2About:
        selectedIndex = 3;
        notifyParent();
        break;
      case ConFunc.navi2Tool:
        selectedIndex = 1;
        notifyParent();
        break;
      case ConFunc.navi2Settings:
        selectedIndex = 2;
        notifyParent();
        break;
      case ConFunc.loadHome:
        if (selectedIndex != 0) {
          selectedIndex = 0;
          notifyParent();
        } else {
          _onLoadHome(context, controller);
        }
        break;
      case ConFunc.adjustWindow:
        _onAdjustWindow(controller);
        break;
      case ConFunc.httpRedirect:
        _onHttpRedirect(controller);
        break;
      case ConFunc.bottomUp:
        _onBottomUp();
        break;
      case ConFunc.scrollUp:
        controller.scrollBy(0, -1);
        break;
      case ConFunc.scrollDown:
        controller.scrollBy(0, 1);
        break;
      case ConFunc.goBack:
        _onGoBack(controller);
        break;
      case ConFunc.goForward:
        _onGoForward(controller);
        break;
      case ConFunc.refresh:
        _onRefresh(context, controller);
        break;
      case ConFunc.clearCookies:
        _onClearCookies(context);
        break;
      case ConFunc.clearCache:
        _onClearCache(context, controller);
        break;
    }
  }

  Future _showDialogWithInput(BuildContext context, String title, TextEditingController controller) async {
    return showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: CupertinoTextField(
            controller: controller,
          ),
          actions: [
            CupertinoDialogAction(child: Text(S.current.Cancel),
              onPressed: (){
                Navigator.of(context).pop(false);
              },),
            CupertinoDialogAction(child: const Text("OK"),
              onPressed: (){
                Navigator.of(context).pop(true);
              },),
          ],
        );
      },
    );
  }

  Future _showToolActionSheet(BuildContext context, WebViewController controller) {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text('${packageInfo.appName} ${packageInfo.version}'),
        // message: const Text('Message'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDefaultAction: bottomPadding,
            onPressed: () {
              _onBottomUp();
              Navigator.pop(context);
            },
            child: Text(S.current.AppBottomSafe),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              _onClearCache(context, controller);
              Navigator.pop(context);
            },
            child: Text(S.current.AppClearCache),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              _onClearCookies(context);
              Navigator.pop(context);
            },
            child: Text(S.current.AppClearCookie),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              var value = _urlTextController.value;
              bool flag = await _showDialogWithInput(context, S.current.ToolHomeSetting, _urlTextController);
              if (flag) {
                customHomeUrl = _urlTextController.value.text;
                localStorage.setString('customHomeUrl', customHomeUrl);
              } else {
                _urlTextController.value = value;
              }
              notifyParent();
            },
            child: Text(S.current.ToolHomeSetting),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              lockDeviceOrientation = true;
              localStorage.setBool('lockDeviceOrientation', true);
              if (customDeviceOrientationIndex != 0) {
                customDeviceOrientationIndex = 0;
                localStorage.setInt('customDeviceOrientation', 0);
              } else if (customDeviceOrientationIndex != 1) {
                customDeviceOrientationIndex = 1;
                localStorage.setInt('customDeviceOrientation', 1);
              }
              notifyParent();
              Navigator.pop(context);
            },
            child: Text(S.current.ToolLandscape),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              lockDeviceOrientation = true;
              localStorage.setBool('lockDeviceOrientation', true);
              customDeviceOrientationIndex = 2;
              localStorage.setInt('customDeviceOrientation', 2);
              notifyParent();
              Navigator.pop(context);
            },
            child: Text(S.current.ToolPortrait),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              localStorage.clear();
              Navigator.pop(context);
            },
            child: Text(S.current.SettingsReset),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh(
      BuildContext context, WebViewController controller) async {
    bool? value = await showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(msg: S.current.AppRefresh, isNormal: true);
        });
    if (value ?? false) {
      allowNavi = true;
      await controller.reload();
    }
  }

  Future<void> _onGoBack(WebViewController controller) async {
    allowNavi = true;
    if (await controller.canGoBack()) {
      await controller.goBack();
    }
  }

  Future<void> _onGoForward(WebViewController controller) async {
    allowNavi = true;
    if (await controller.canGoForward()) {
      await controller.goForward();
    }
  }

  void _onBottomUp() {
    if (bottomPadding) {
      bottomPadding = false;
    } else {
      bottomPadding = true;
    }
    notifyParent();
  }

  Future<void> _onHttpRedirect(WebViewController controller) async {
    if (!inKancolleWindow) {
      String? currentUrl = await controller.currentUrl();
      Uri uri = Uri.parse(currentUrl!);
      if (uri.path.startsWith(home.path)) {
        // May be HTTPS or HTTP
        allowNavi = true;
        if (Platform.isIOS) {
          await controller.runJavascript(
              '''window.open("http:"+gadgetInfo.URL,'_blank');''');
        }
        inKancolleWindow = true;
      }
      Fluttertoast.showToast(msg: S.current.KCViewFuncMsgAutoGameRedirect);
      print("HTTP Redirect success");
    } else {
      Fluttertoast.showToast(msg: S.current.KCViewFuncMsgAlreadyGameRedirect);
      print("HTTP Redirect fail");
    }
    print("inKancolleWindow: $inKancolleWindow");
  }

  Future<void> _onAdjustWindow(WebViewController controller) async {
    if (gameLoadCompleted) {
      await autoAdjustWindowV2(controller, force: true);
    } else {
      Fluttertoast.showToast(
          msg: S.current.KCViewFuncMsgNaviGameLoadNotCompleted);
    }
  }

  Future<void> _onLoadHome(
      BuildContext context, WebViewController controller) async {
    bool? value = await showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(msg: S.current.AppHome, isNormal: true);
        });
    if (value ?? false) {
      allowNavi = true;
      String homeUrl = getHomeUrl();
      await controller.loadUrl(homeUrl);
    }
  }

  Future<void> _onClearCookies(BuildContext context) async {
    bool? value = await showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
              msg: S.current.AppClearCookie, isNormal: true);
        });
    if (value ?? false) {
      final bool hadCookies = await cookieManager.clearCookies();
      String message = S.current.AppLeftSideControlsLogoutSuccess;
      if (!hadCookies) {
        message = S.current.AppLeftSideControlsLogoutFailed;
      }
      Fluttertoast.showToast(msg: message);
    }
  }

  Future<void> _onClearCache(
      BuildContext context, WebViewController controller) async {
    bool? value = await showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
              msg: S.current.AppClearCache.replaceAll('\n', ''),
              isNormal: true);
        });
    if (value ?? false) {
      allowNavi = true;
      await controller.clearCache();
      final prefs = await SharedPreferences.getInstance(); //temporarily
      prefs.clear(); //temporarily
      Fluttertoast.showToast(msg: S.current.AppLeftSideControlsClearCache);
    }
  }
}
