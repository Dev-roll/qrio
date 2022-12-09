  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return DynamicColorBuilder(
        builder: ((ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      ColorScheme lightColorScheme = (lightDynamic != null)
          ? lightDynamic.harmonized()
          : ColorScheme.fromSeed(seedColor: baseColor);
      ColorScheme darkColorScheme = (darkDynamic != null)
          ? darkDynamic.harmonized()
          : ColorScheme.fromSeed(
              seedColor: baseColor, brightness: Brightness.dark);

      return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'QR I/O',
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ja', 'JP')],
          themeMode: themeMode,
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          darkTheme:
              ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
          home: const Home());
    }));
  }
