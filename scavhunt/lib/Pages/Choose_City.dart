import 'package:flutter/material.dart';
import 'package:namer_app/Pages/drawer.dart';

class ChooseCity extends StatelessWidget {
  const ChooseCity({super.key});

  @override
  Widget build(BuildContext context) {
    // const items = 4;

    final List<String> itemTexts = [
      'Fort Wayne',
      'Indianapolis',
      'Chicago',
      'Cleveland',
      'Cincinnati',
      'Columbus',
      'Detroit',
      'Louisville',
      'Lexington',
      'Milwaukee'
      // Add more items as needed
    ];

    final TextStyle itemTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.deepPurple,
    );

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        cardTheme: CardTheme(color: Colors.blue.shade50),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Choose difficulty level',
            style: TextStyle(color: Colors.white),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          centerTitle: true,
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
        drawer: AppDrawer(),
        body: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(
                  itemTexts.length,
                  (index) => ItemWidget(
                    text: itemTexts[index],
                    textStyle: itemTextStyle,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  final String text;
  final TextStyle textStyle;

  ItemWidget({required this.text, required this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      margin: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            text,
            style: textStyle, // Apply the text style
          ),
        ),
      ),
    );
  }
}
