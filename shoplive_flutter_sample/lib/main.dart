import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class ShopLiveUser {
  String? id;
  String? name;
  int? age;
  String? gender;
  int? userScore;

  ShopLiveUser();

  Map<String, dynamic> toJson() =>
    {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'userScore': userScore,
    };
}

class ShopLiveCampaign {
  String? accessKey;
  String? campaignKey;
  ShopLiveUser? user;
  String? token;

  ShopLiveCampaign();

  Map<String, dynamic> toJson() =>
      {
        'accessKey': accessKey,
        'campaignKey': campaignKey,
        'user': user,
        'token': token
      };
}

enum PipPosition { TopLeft, TopRight, BottomLeft, BottomRight } 

class ShopLiveConfiguration {

  ShopLiveCampaign? campaignInfo;
  String? progressColor;
  String? urlScheme;
  String? pipRatio;                         // (1x1, 1x2, 2x3, 3x4, 9x16)
  bool? keepAspectOnTabletPortrait;         // tablet 전용 옵션
  bool? keepPlayVideoOnHeadphoneUnplugged;
  bool? autoResumeVideoOnCallEnded;
  bool? loadingAnimation;
  bool? chatViewTypeface;
  bool? enterPipModeOnBackPressed;
  String? pipScale;                         // 0.1 ~ 1.0 사이의 값
  String? pipPosition;                       // topLeft, topRight, bottomLeft, bottomRight
  
  ShopLiveConfiguration();

  ShopLiveConfiguration.fromJson(Map<String, dynamic> json)
      : campaignInfo = json['campaignInfo'],
        progressColor = json['progressColor'],
        urlScheme = json['urlScheme'],
        pipRatio = json['pipRatio'],
        pipScale = json['pipScale'],
        pipPosition = json['chatViewTypeface'],
        keepAspectOnTabletPortrait = json['keepAspectOnTabletPortrait'],
        keepPlayVideoOnHeadphoneUnplugged = json['keepPlayVideoOnHeadphoneUnplugged'],
        autoResumeVideoOnCallEnded = json['autoResumeVideoOnCallEnded'],
        loadingAnimation = json['loadingAnimation'],
        chatViewTypeface = json['chatViewTypeface'],
        enterPipModeOnBackPressed = json['enterPipModeOnBackPressed'];
        

  Map<String, dynamic> toJson() =>
    {
      'campaignInfo': campaignInfo,
      'progressColor': progressColor,
      'urlScheme': urlScheme,
      'pipRatio': pipRatio,
      'pipScale': pipScale,
      'pipPosition': pipPosition,
      'keepAspectOnTabletPortrait': keepAspectOnTabletPortrait,
      'keepPlayVideoOnHeadphoneUnplugged': keepPlayVideoOnHeadphoneUnplugged,
      'autoResumeVideoOnCallEnded': autoResumeVideoOnCallEnded,
      'loadingAnimation': loadingAnimation,
      'chatViewTypeface': chatViewTypeface,
      'enterPipModeOnBackPressed': enterPipModeOnBackPressed,
    };
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // shoplive native 통신 채널
  static const liveChannel = MethodChannel('cloud.shoplive.sdk/live');
  static const messageChannel = BasicMessageChannel('cloud.shoplive.sdk/message', StringCodec());

  int radioButtonId = 1;
  String configurationJson = "";

  final TextEditingController accessKeyController = TextEditingController();
  final TextEditingController campaignKeyController = TextEditingController();

  String setting1Json() {
    ShopLiveUser user = ShopLiveUser();
    user.id = 'Emma';
    user.name = 'Watson';
    user.age = 30;
    user.gender = 'f';
    user.userScore = 100;

    ShopLiveCampaign campaign = ShopLiveCampaign();
    campaign.accessKey = accessKeyController.text;
    campaign.campaignKey = campaignKeyController.text;

    // user 또는 token 둘 중에 1개만 사용하기.
    campaign.user = user;
    //campaign.token = "abcdefghijklmnopqrstuvwxyz=";

    ShopLiveConfiguration config = ShopLiveConfiguration();
    config.campaignInfo = campaign;
    config.progressColor = '#FF0000';
    config.urlScheme = 'https://shoplive.cloud';
    config.pipRatio = "2x3";
    config.pipPosition = "bottomLeft";
    config.pipScale = "0.5";
    //config.keepAspectOnTabletPortrait = false
    config.keepPlayVideoOnHeadphoneUnplugged = true;
    config.autoResumeVideoOnCallEnded = true;
    config.loadingAnimation = false;
    config.chatViewTypeface = false;
    config.enterPipModeOnBackPressed = false;

    return jsonEncode(config);
  }

  String setting2Json() {
    ShopLiveUser user = ShopLiveUser();
    user.id = 'Clayton';
    user.name = 'Kershaw';
    user.age = 34;
    user.gender = 'm';
    user.userScore = 50;

    ShopLiveCampaign campaign = ShopLiveCampaign();
    campaign.accessKey = accessKeyController.text;
    campaign.campaignKey = campaignKeyController.text;

    // user 또는 token 둘 중에 1개만 사용하기.
    campaign.user = user;
    //campaign.token = "abcdefghijklmnopqrstuvwxyz=";

    ShopLiveConfiguration config = ShopLiveConfiguration();
    config.campaignInfo = campaign;
    config.progressColor = '#FFFF00';
    config.urlScheme = 'https://www.naver.com';
    //config.pipRatio = "2x3";
    // config.pipPosition = "bottomLeft"
    // config.pipScale = "0.5"
    //config.keepAspectOnTabletPortrait = false
    config.keepPlayVideoOnHeadphoneUnplugged = true;
    config.autoResumeVideoOnCallEnded = true;
    config.loadingAnimation = true;
    config.chatViewTypeface = false;
    config.enterPipModeOnBackPressed = true;

    return jsonEncode(config);
  }

  String setting3Json() {
    ShopLiveUser user = ShopLiveUser();
    user.id = 'Michael';
    user.name = 'Jordan';
    user.age = 59;
    user.gender = 'n';
    user.userScore = 20;

    ShopLiveCampaign campaign = ShopLiveCampaign();
    campaign.accessKey = accessKeyController.text;
    campaign.campaignKey = campaignKeyController.text;

    // user 또는 token 둘 중에 1개만 사용하기.
    campaign.user = user;
    //campaign.token = "abcdefghijklmnopqrstuvwxyz=";

    ShopLiveConfiguration config = ShopLiveConfiguration();
    config.campaignInfo = campaign;
    config.progressColor = '#FF00FF';
    config.urlScheme = 'https://www.daum.net';
    //config.pipRatio = "2x3";
    // config.pipPosition = "bottomLeft"
    // config.pipScale = "0.5"
    //config.keepAspectOnTabletPortrait = false
    config.keepPlayVideoOnHeadphoneUnplugged = true;
    config.autoResumeVideoOnCallEnded = true;
    config.loadingAnimation = true;
    config.chatViewTypeface = true;
    config.enterPipModeOnBackPressed = false;

    return jsonEncode(config);
  }

  void preview() {
    setState(() {
      shopLivePreview();
    });
  }

  void play() {
    setState(() {
      shopLivePlay();
    });
  }

  Future<void> shopLivePreview() async {
    String value;
    try{
      value = await liveChannel.invokeMethod('preview', configurationJson);
    } on PlatformException catch (e) {
      value = '네이티브 코드 실행 에러 : ${e.message}';
    }
    // console log
    print(value);
  }

  Future<void> shopLivePlay() async {
    String value;
    try{
      value = await liveChannel.invokeMethod('play', configurationJson);
    } on PlatformException catch (e) {
      value = '네이티브 코드 실행 에러 : ${e.message}';
    }
    // console log
    print(value);
  }

  Future<String> shopliveCallbackHandler(MethodCall call) async {
    String result = "";
    switch (call.method) {
      case 'DOWNLOAD_COUPON':
        result = '{ "isDownloadSuccess": true, "message": "쿠폰 다운로드 성공!", "popupStatus":"HIDE", "alertType":"TOAST" }';
        break;
      case 'CUSTOM_ACTION':
        result = '{ "isSuccess": false, "message": "커스텀 액션 실패!", "popupStatus":"SHOW", "alertType":"ALERT" }';
        break;
      case 'SHARE':
        result = '{ "message": "공유하기!", "isDefaultShareSheet": true }';
        break;
      default:
        break;
    }
    return result;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    messageChannel.setMessageHandler((String? message) async {
      String result = "";
      if (message != null) {
        final parsedJson = jsonDecode(message);
        switch(parsedJson['command']) {
          case 'NAVIGATION':
            print('NAVIGATION');
            break;
          case 'CHANGE_CAMPAIGN_STATUS':
            print('CHANGE_CAMPAIGN_STATUS');
            break;
          case 'RECEIVED_COMMAND.ON_SUCCESS_JOIN':
            print('RECEIVED_COMMAND.ON_SUCCESS_JOIN');
            break;
        }
        result = 'command:${parsedJson['command']}, value:${parsedJson['value']}';
      }

      // console log
      print('SDK로부터 수신 메시지 = $result');
      return 'Reply from Dart';
    });

    // 초기화
    liveChannel.setMethodCallHandler(shopliveCallbackHandler);

    accessKeyController.text = "";
    campaignKeyController.text = "";

    configurationJson = setting1Json();
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.


    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(10),
              child: TextField(onChanged: (text) {
                      setState(() {
                        switch (radioButtonId) {
                          case 1:
                            configurationJson = setting1Json();
                            break;
                          case 2:
                            configurationJson = setting2Json();
                            break;
                          case 3:
                            configurationJson = setting3Json();
                            break;
                          default:
                            break;
                        }
                      });
                    },
                controller: accessKeyController,
                decoration:
                const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'accessKey',
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: TextField(onChanged: (text) {
                      setState(() {
                        switch (radioButtonId) {
                          case 1:
                            configurationJson = setting1Json();
                            break;
                          case 2:
                            configurationJson = setting2Json();
                            break;
                          case 3:
                            configurationJson = setting3Json();
                            break;
                          default:
                            break;
                        }
                      });
                    },
                controller: campaignKeyController,
                decoration:
                const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'campaignKey',
                ),
              ),
            ),

            /*
            Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(40), // fromHeight use double.infinity as width and 40 is the height
                ),
                onPressed: () {},
                child: const Text("setting 1"),
              )
            ),
            */

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Radio(
                          value: 1, groupValue: radioButtonId, onChanged: (index) {
                            setState(() {
                              radioButtonId = 1;
                              configurationJson = setting1Json();
                            });
                      }),
                      Expanded(
                        child: Text('Setting 1'),
                      )
                    ],
                  ),
                  flex: 1,
                ),
                Expanded(
                  child: Row(
                    children: [
                      Radio(
                          value: 2, groupValue: radioButtonId, onChanged: (index) {
                          setState(() {
                            radioButtonId = 2;
                            configurationJson = setting2Json();
                          });
                      }),
                      Expanded(child: Text('Setting 2'))
                    ],
                  ),
                  flex: 1,
                ),
                Expanded(
                  child: Row(
                    children: [
                      Radio(
                          value: 3, groupValue: radioButtonId, onChanged: (index) {
                            setState(() {
                              radioButtonId = 3;
                              configurationJson = setting3Json();
                            });
                      }),
                      Expanded(child: Text('Setting 3'))
                    ],
                  ),
                  flex: 1,
                ),
              ],
            ),

            Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Text(
                  '$configurationJson',
                  textAlign: TextAlign.left,
                )
            ),

            Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                        height: 40,
                      child: ElevatedButton(
                        child: Text(
                            "Preview".toUpperCase(),
                            style: TextStyle(fontSize: 14)
                        ),
                        style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                    side: BorderSide(color: Colors.red)
                                )
                            )
                        ),
                        onPressed: preview
                      )
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      width: 100,
                      height: 40,
                      child: ElevatedButton(
                        child: Text(
                            "Play".toUpperCase(),
                            style: TextStyle(fontSize: 14)
                        ), style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                    side: BorderSide(color: Colors.red)
                                )
                            )
                        ),
                        onPressed: play
                      )
                    )
                  ]
              ),
            ),
          ],
        ),
      ),
     /*
      floatingActionButton: FloatingActionButton(
        onPressed: play,
        tooltip: 'Increment',
        child: const Icon(Icons.play_circle_outline),
      ), // This trailing comma makes auto-formatting nicer for build methods.
     */

    );
  }
}