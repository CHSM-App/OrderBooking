import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PDFViewerPageFromUrl extends StatefulWidget {
  final String url;
  final String? title;

  const PDFViewerPageFromUrl({super.key, required this.url, this.title});

  @override
  State<PDFViewerPageFromUrl> createState() => _PDFViewerPageFromUrlState();
}

class _PDFViewerPageFromUrlState extends State<PDFViewerPageFromUrl> {
  bool _loading = true;
  String? _localPath;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _preparePdf();
  }

  Future<void> _preparePdf() async {
    try {
      final uri = Uri.tryParse(widget.url.trim());
      if (uri == null) {
        throw Exception('Invalid PDF URL');
      }

      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Unable to fetch PDF (${response.statusCode})');
      }

      final bytes = response.bodyBytes;
      if (!_looksLikePdf(bytes)) {
        throw Exception('Server response is not a valid PDF');
      }

      final dir = await getTemporaryDirectory();
      final fileName = _safeFileNameFromUri(uri);
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      if (!mounted) return;
      setState(() {
        _localPath = file.path;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'PDF Preview')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _PdfErrorView(message: _errorMessage!)
              : PDFView(
                  filePath: _localPath!,
                  onError: (error) {
                    if (!mounted) return;
                    setState(() {
                      _errorMessage = error.toString();
                    });
                  },
                  onPageError: (page, error) {
                    if (!mounted) return;
                    setState(() {
                      _errorMessage = 'Failed to render page $page: $error';
                    });
                  },
                ),
    );
  }
}

class PDFViewerPageFromFile extends StatefulWidget {
  final String filePath;
  final String? title;

  const PDFViewerPageFromFile({
    super.key,
    required this.filePath,
    this.title,
  });

  @override
  State<PDFViewerPageFromFile> createState() => _PDFViewerPageFromFileState();
}

class _PDFViewerPageFromFileState extends State<PDFViewerPageFromFile> {
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final file = File(widget.filePath);

    if (!file.existsSync()) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title ?? 'PDF Preview')),
        body: const _PdfErrorView(message: 'PDF file not found'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'PDF Preview')),
      body: FutureBuilder<bool>(
        future: _isValidPdfFile(file),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data != true) {
            return const _PdfErrorView(message: 'Selected file is not a valid PDF');
          }

          if (_errorMessage != null) {
            return _PdfErrorView(message: _errorMessage!);
          }

          return PDFView(
            filePath: widget.filePath,
            onError: (error) {
              if (!mounted) return;
              setState(() {
                _errorMessage = error.toString();
              });
            },
            onPageError: (page, error) {
              if (!mounted) return;
              setState(() {
                _errorMessage = 'Failed to render page $page: $error';
              });
            },
          );
        },
      ),
    );
  }
}

class _PdfErrorView extends StatelessWidget {
  final String message;

  const _PdfErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}

String _safeFileNameFromUri(Uri uri) {
  final name =
      uri.pathSegments.isNotEmpty && uri.pathSegments.last.isNotEmpty
          ? uri.pathSegments.last
          : 'document.pdf';
  return name.toLowerCase().endsWith('.pdf') ? name : '$name.pdf';
}

bool _looksLikePdf(List<int> bytes) {
  if (bytes.length < 4) return false;
  return bytes[0] == 0x25 && // %
      bytes[1] == 0x50 && // P
      bytes[2] == 0x44 && // D
      bytes[3] == 0x46; // F
}

Future<bool> _isValidPdfFile(File file) async {
  try {
    final stream = file.openRead(0, 4);
    final header = await stream.expand((chunk) => chunk).take(4).toList();
    return _looksLikePdf(header);
  } catch (_) {
    return false;
  }
}
