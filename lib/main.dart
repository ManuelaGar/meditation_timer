import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'background.dart';
import 'package:vibration/vibration.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromRGBO(109, 234, 255, 1),
        accentColor: Color.fromRGBO(72, 74, 126, 1),
        brightness: Brightness.dark,
      ),
      title: 'Flutter Timer',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  AnimationController controller;
  Duration duration = Duration(seconds: 0);
  bool isPaused = false;
  bool isStopped = true;
  bool isSetTimerVisible = true;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: duration,
    );
  }

  String timerString() {
    duration = controller.duration * controller.value;

    String setTime =
        '${controller.duration.inMinutes}:${(controller.duration.inSeconds % 60).toString().padLeft(2, '0')}';
    String timer = setTime;

    if (duration.inMinutes < 10) {
      timer =
          '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    } else if (duration.inMinutes >= 10) {
      timer =
          '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }

    return controller.value == 0 ? setTime : timer;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Timer",
          style: TextStyle(fontSize: 30.0, color: Color(0xFF1D1E33)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          Background(),
          AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Visibility(
                        visible: isSetTimerVisible,
                        child: SizedBox(
                          height:
                              MediaQuery.of(context).copyWith().size.height / 4,
                          child: CupertinoTimerPicker(
                            mode: CupertinoTimerPickerMode.hms,
                            onTimerDurationChanged: (Duration time) {
                              setState(() {
                                controller = AnimationController(
                                  vsync: this,
                                  duration: time,
                                );
                              });
                              controller
                                  .addStatusListener((AnimationStatus status) {
                                if (status == AnimationStatus.dismissed) {
                                  setState(() {
                                    isStopped = true;
                                    isSetTimerVisible = true;
                                  });
                                  //TODO: play alarm when finished
                                  // in android manifest
                                  // <uses-permission android:name="android.permission.VIBRATE"/>
                                  //HapticFeedback.heavyImpact(); // Works for ios
                                  /*Vibration.vibrate(
                                      pattern: [500, 1000, 500, 2000]);*/

                                  for (int i = 0; i < 3; i++) {
                                    print('hola');
                                    HapticFeedback.vibrate();
                                    sleep(
                                      Duration(milliseconds: 1000),
                                    );
                                  }
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      Visibility(
                        visible: !isSetTimerVisible,
                        child: SizedBox(
                          height:
                              MediaQuery.of(context).copyWith().size.height / 4,
                          child: Center(
                            child: AnimatedBuilder(
                                animation: controller,
                                builder: (BuildContext context, Widget child) {
                                  return Text(
                                    timerString(),
                                    style: themeData.textTheme.headline1
                                        .copyWith(
                                            fontSize: 70,
                                            fontWeight: FontWeight.w200),
                                  );
                                }),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          margin: EdgeInsets.all(20.0),
                          child: isStopped
                              ? FloatingActionButton(
                                  child: AnimatedBuilder(
                                    animation: controller,
                                    builder:
                                        (BuildContext context, Widget child) {
                                      return Icon(Icons.play_arrow);
                                    },
                                  ),
                                  onPressed: () {
                                    controller.reverse(
                                        from: controller.value == 0.0
                                            ? 1.0
                                            : controller.value);
                                    setState(() {
                                      isStopped = false;
                                      isSetTimerVisible = false;
                                    });
                                  },
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    FloatingActionButton(
                                      child: AnimatedBuilder(
                                        animation: controller,
                                        builder: (BuildContext context,
                                            Widget child) {
                                          return Icon(Icons.replay);
                                        },
                                      ),
                                      onPressed: () {
                                        controller.value = 0.0;
                                        setState(() {
                                          isStopped = true;
                                          isSetTimerVisible = true;
                                        });
                                      },
                                    ),
                                    FloatingActionButton(
                                      child: AnimatedBuilder(
                                        animation: controller,
                                        builder: (BuildContext context,
                                            Widget child) {
                                          return Icon(isPaused
                                              ? Icons.play_arrow
                                              : Icons.pause);
                                        },
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isPaused = !isPaused;
                                        });
                                        if (isPaused)
                                          controller.stop();
                                        else {
                                          controller.reverse(
                                              from: controller.value == 0.0
                                                  ? 1.0
                                                  : controller.value);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                        ),
                      )
                    ],
                  ),
                );
              }),
        ],
      ),
    );
  }
}
