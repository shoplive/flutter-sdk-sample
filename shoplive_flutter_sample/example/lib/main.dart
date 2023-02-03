import 'dart:convert';
import 'dart:developer' as Log;
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shoplive_player/shoplive_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopLive test',
      routes: {
        ShopLiveTestPage.routeName: (context) => const ShopLiveTestPage(),
      },
      initialRoute: ShopLiveTestPage.routeName,
    );
  }
}

class ShopLiveTestPage extends StatefulWidget {
  static const routeName = '/';

  const ShopLiveTestPage({Key? key}) : super(key: key);

  @override
  State<ShopLiveTestPage> createState() => _ShopLiveTestPageState();
}

class _ShopLiveTestPageState extends State<ShopLiveTestPage> {
  final CompositeSubscription _compositeSubscription = CompositeSubscription();

  final String _accessKey = "";
  final String _campaignKey = "";
  late final _shopLivePlayerPlugin = ShopLivePlayer();
  late final _accessKeyController =
      TextEditingController(text: _accessKey); // For testing AccessKey
  late final _campaignKeyController =
      TextEditingController(text: _campaignKey); // For testing CampaignKey
  late final _shareSchemeUrlController =
      TextEditingController(text: "http://google.com");

  @override
  void initState() {
    super.initState();
    initListener();

    _shopLivePlayerPlugin.setEnterPipModeOnBackPressed(isEnterPipMode: true);
    _shopLivePlayerPlugin.setMuteWhenPlayStart(isMute: false);
    _shopLivePlayerPlugin.setUser(
        userName: "TestUser",
        userId: "userId",
        userScore: 0,
        gender: ShopLiveGender.neutral,
        age: 20,
        parameters: {"key": "value"});
  }

  void initListener() {
    _shopLivePlayerPlugin.handleNavigation.listen((data) {
      _showToast("handleNavigation : ${data.url}");
    }).addTo(_compositeSubscription);

    _shopLivePlayerPlugin.handleDownloadCoupon.listen((data) {
      _showToast("handleDownloadCoupon : ${data.couponId}");
    }).addTo(_compositeSubscription);

    _shopLivePlayerPlugin.changeCampaignStatus.listen((data) {
      _showToast("changeCampaignStatus : ${data.campaignStatus}");
    }).addTo(_compositeSubscription);

    _shopLivePlayerPlugin.campaignInfo.listen((data) {
      _showToast(
          "campaignInfo : ${const JsonEncoder().convert(data.campaignInfo)}");
    }).addTo(_compositeSubscription);

    _shopLivePlayerPlugin.handleCustomAction.listen((data) {
      _showToast(
          "handleCustomAction : ${data.id}, ${data.type}, ${data.payload}");
    }).addTo(_compositeSubscription);

    _shopLivePlayerPlugin.changedPlayerStatus.listen((data) {
      _showToast("changedPlayerStatus: ${data.isPipMode}, ${data.status}");
    }).addTo(_compositeSubscription);

    _shopLivePlayerPlugin.userInfo.listen((data) {
      _showToast("userInfo : ${const JsonEncoder().convert(data.userInfo)}");
    }).addTo(_compositeSubscription);

    _shopLivePlayerPlugin.error.listen((data) {
      _showToast("error : ${data.code}, ${data.message}");
    }).addTo(_compositeSubscription);

    _shopLivePlayerPlugin.receivedCommand.listen((data) {
      _showToast(
          "receivedCommand : ${data.command}, ${const JsonEncoder().convert(data.data)}");
    }).addTo(_compositeSubscription);

    _shopLivePlayerPlugin.log.listen((data) {
      _showToast(
          "Shoplive Log : ${data.name}, ${data.feature}, ${data.campaignKey}, ${const JsonEncoder().convert(data.parameter)}");
    }).addTo(_compositeSubscription);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Shoplive flutter example app'),
        ),
        body: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                child: TextField(
                  controller: _accessKeyController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Access key',
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(20),
                child: TextField(
                  controller: _campaignKeyController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Campaign key',
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(20),
                child: TextField(
                  controller: _shareSchemeUrlController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Share scheme url',
                  ),
                ),
              ),
              TextButton(
                  onPressed: () {
                    if (_accessKeyController.text.isEmpty) {
                      _showToast("Required to accessKey");
                      return;
                    }
                    if (_campaignKeyController.text.isEmpty) {
                      _showToast("Required to campaignKey");
                      return;
                    }

                    _shopLivePlayerPlugin.setShareScheme(
                        shareSchemeUrl:
                            _shareSchemeUrlController.text.isNotEmpty
                                ? _shareSchemeUrlController.text
                                : "http://google.com");
                    _shopLivePlayerPlugin.setAccessKey(
                        accessKey: _accessKeyController.text);
                    _shopLivePlayerPlugin.play(
                        campaignKey: _campaignKeyController.text);
                  },
                  child: const Text('PLAY')),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _accessKeyController.dispose();
    _campaignKeyController.dispose();
    _shareSchemeUrlController.dispose();
    _compositeSubscription.dispose();
    super.dispose();
  }

  void _showToast(String text) {
    Log.log(text);

    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black.withOpacity(0.7),
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}
