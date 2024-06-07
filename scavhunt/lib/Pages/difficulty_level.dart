import 'package:flutter/material.dart';
// import 'package:namer_app/Pages/Choose_City.dart';
import 'package:namer_app/Pages/Location_Print.dart';


class DifficultyLevel extends StatelessWidget {
  const DifficultyLevel({super.key});

  @override
  Widget build(BuildContext context) {
    // const items = 4;

    final List<String> itemTexts = [
      'Virtual Hunt',
      'Inter City',
      'Inter State',
      'Inter Country',
      'Inter continent',
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
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                accountName: Text('John Doe'),
                accountEmail: Text('john.doe@example.com'),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage('images/avatar.png'),
                ),
              ),
              ListTile(
                title: const Text('Item 1'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Item 2'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
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
    return GestureDetector(
      onTap: () {
        if (text == 'Inter City') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LocationPrint()),
          );
        } else {
          // Handle other cases or simply do nothing
        }
      },
      child: Container(
        width: double.infinity,
        height: 100,
        margin: const EdgeInsets.only(bottom: 8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              text,
              style: textStyle,
            ),
          ),
        ),
      ),
    );
  }
}

