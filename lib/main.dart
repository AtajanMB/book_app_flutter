import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  runApp(MaterialApp(
    title: 'Syncfusion PDF Viewer Demo',
    theme: ThemeData(
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      fontFamily: "OpenSans",
      primaryColor: Colors.green,
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          // toolbarHeight: 80,
          // This will be applied to the "back" icon
          iconTheme: IconThemeData(color: Colors.black54),
          // This will be applied to the action icon buttons that locates on the right side
          actionsIconTheme: IconThemeData(color: Colors.black54),
          centerTitle: false,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.white)),
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.black54),
    ),
    home: const HomePage(),
  ));
}

/// Represents Homepage for Navigation
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  late PdfViewerController _pdfViewerController;
  late PdfTextSearchResult _searchResult;
  TextEditingController searchTextController = TextEditingController();
  bool isSearchVisible = false;
  final focus = FocusNode();

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    _searchResult = PdfTextSearchResult();
    super.initState();
  }

  OverlayEntry? _overlayEntry;
  void _showContextMenu(
      BuildContext context, PdfTextSelectionChangedDetails details) {
    final OverlayState _overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: details.globalSelectedRegion?.center.dy,
        left: details.globalSelectedRegion?.bottomLeft.dx,
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
              child: const Text('Göçür', style: TextStyle(fontSize: 17)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: details.selectedText));
                _pdfViewerController.clearSelection();
              },
            ),
          ],
        ),
      ),
    );
    if (_overlayEntry != null) {
      _overlayState.insert(_overlayEntry!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            isSearchVisible ? searchView() : const Text("Halallyk kyssalary"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              if (isSearchVisible) {
                _searchResult = _pdfViewerController.searchText(
                  searchTextController.text,
                  searchOption: TextSearchOption.caseSensitive,
                );
                _searchResult.addListener(() {
                  if (_searchResult.hasResult
                      // && _searchResult.isSearchCompleted
                      ) {
                    setState(() {});
                    print(
                        '============================================> ${_searchResult.totalInstanceCount}');
                  }
                });
              } else {
                isSearchVisible = true;
                setState(() {});
              }
            },
          ),
          Visibility(
            visible: isSearchVisible,
            child: IconButton(
              icon: const Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  isSearchVisible = false;
                  _searchResult.clear();

                  searchTextController.clear();
                });
              },
            ),
          ),
          Visibility(
            visible: _searchResult.hasResult,
            child: IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_up,
                color: Colors.white,
              ),
              onPressed: () {
                _searchResult.previousInstance();
              },
            ),
          ),
          Visibility(
            visible: _searchResult.hasResult,
            child: IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
              onPressed: () {
                _searchResult.nextInstance();
              },
            ),
          ),
        ],
      ),
      body: SfPdfViewer.asset(
        'assets/halallyk_kyssalary.pdf',
        key: _pdfViewerKey,
        onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
          if (details.selectedText == null && _overlayEntry != null) {
            _overlayEntry?.remove();
            _overlayEntry = null;
          } else if (details.selectedText != null && _overlayEntry == null) {
            _showContextMenu(context, details);
          }
        },
        controller: _pdfViewerController,
      ),
    );
  }

  SizedBox buildSearchWidget(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 50,
      child: TextField(
        // controller: searchTextController,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.text,
        // inputFormatters: <TextInputFormatter>[
        //   FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        //   FilteringTextInputFormatter.digitsOnly
        // ],
        // onSaved: (newValue) => oldPass = newValue,
        // validator: (value) {
        //   return MyValidator.pincode(value);
        // },
        decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: const BorderSide(color: Colors.amber, width: 2.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: const BorderSide(color: Colors.blue, width: 2.5),
            ),
            labelText: 'Gözleg sözi',
            prefixIcon: const InkWell(
              child: Icon(Icons.search),
            )),
      ),
    );
  }

  Widget searchView() {
    return Container(
      alignment: Alignment.centerLeft,
      height: 50,
      color: Colors.blue,
      child: TextField(
        controller: searchTextController,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.text,
        autofocus: isSearchVisible,
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        focusNode: focus,
        decoration: const InputDecoration(
            border: InputBorder.none,
            fillColor: Colors.green,
            filled: true,
            hintText: 'Gözleg...',
            labelStyle: TextStyle(color: Colors.white),
            hintStyle: TextStyle(color: Colors.white60)),
      ),
    );
  }
}
