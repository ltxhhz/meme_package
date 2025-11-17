import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meme_package/config.dart';
import 'package:meme_package/utils.dart';
import 'package:oktoast/oktoast.dart';

import 'utils/platform_utils.dart';
import './router/router.dart';

void main() async {
  await Utils.init();
  await Config.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: ScreenUtilInit(
        designSize: PlatformUtils.isMobile ? const Size(360, 690) : const Size(690, 360),
        minTextAdapt: true,
        // splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
              fontFamily: 'SimHei',
              fontFamilyFallback: const [
                'SourceHanSans'
              ],
              textTheme: TextTheme(
                // displayMedium: TextStyle(fontSize: 30.sp),
                // bodySmall: TextStyle(fontSize: 10.sp),
                bodyMedium: TextStyle(fontSize: 12.sp),
                // bodyLarge: TextStyle(fontSize: 20.sp),
              ),
            ),
            onGenerateRoute: onGenerateRoute,
            navigatorObservers: [
              Config.routeObserver,
            ],
            locale: const Locale('zh', 'CN'),
            localizationsDelegates: const [
              GlobalCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('zh', 'CN'),
            ],
          );
        },
        // child: const Home(),
      ),
    );
  }
}
