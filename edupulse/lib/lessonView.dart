import 'package:edupulse/storageController.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as m;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// === LaTeX support ===
const _latexTag = 'latex';

class LatexSyntax extends m.InlineSyntax {
  LatexSyntax() : super(r'(\\\[[\s\S]+?\\\])|(\$\$[\s\S]+?\$\$)|(\$.+?\$)');

  @override
  bool onMatch(m.InlineParser parser, Match match) {
    final matchText = match.input.substring(match.start, match.end);
    String content = '';
    bool isInline = true;

    if (matchText.startsWith(r'\[') && matchText.endsWith(r'\]') && matchText.length > 4) {
      content = matchText.substring(2, matchText.length - 2);
      isInline = false;
    }

    final el = m.Element.text(_latexTag, matchText);
    el.attributes['content'] = content;
    el.attributes['isInline'] = isInline ? 'true' : 'false';
    parser.addNode(el);
    return true;
  }
}

class LatexNode extends SpanNode {
  final Map<String, String> attributes;
  final String textContent;
  final MarkdownConfig config;

  LatexNode(this.attributes, this.textContent, this.config);

  @override
  InlineSpan build() {
    final content = attributes['content'] ?? '';
    final isInline = attributes['isInline'] == 'true';
    final style = parentStyle ?? config.p.textStyle;

    if (content.isEmpty) {
      return TextSpan(text: textContent, style: style);
    }

    final latex = Math.tex(content, textStyle: style);

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: isInline
          ? latex
          : Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: Center(child: latex),
            ),
    );
  }
}

class LocalImageSpanNode extends SpanNode {
  final Map<String, String> attributes;
  final Future<String> folderPathFuture;
  final MarkdownConfig config;

  LocalImageSpanNode(this.attributes, this.folderPathFuture, this.config);

  @override
  InlineSpan build() {
    final src = attributes['src'] ?? '';
    final alt = attributes['alt'] ?? 'Image not found';
    final style = parentStyle ?? config.p.textStyle;

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: FutureBuilder<String>(
        future: folderPathFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Text(alt, style: style);
          }
          final folderPath = snapshot.data!;
          final imagePath = '$folderPath/$src';
          return Image.file(
            File(imagePath),
            errorBuilder: (context, error, stackTrace) => Text(alt, style: style),
          );
        },
      ),
    );
  }
}



// === LessonView ===
class LessonView extends StatefulWidget {
  const LessonView({Key? key, required this.folderName}) : super(key: key);
  final String folderName;

  @override
  State<LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends State<LessonView> {
  final StorageController storageController = StorageController();
  late Future<String> _mdContentFuture;
  late Future<String> _localLessonFolderPath;


  @override
  void initState() {
    super.initState();
    _mdContentFuture = storageController.getMdContent(widget.folderName);
    _localLessonFolderPath = storageController.getImgContent(widget.folderName);
  }

  @override
  Widget build(BuildContext context) {
    // hook LaTeX into markdown_widget
    final latexGenerator = SpanNodeGeneratorWithTag(
      tag: _latexTag,
      generator: (e, config, visitor) => LatexNode(e.attributes, e.textContent, config),
    );

    final imageGenerator = SpanNodeGeneratorWithTag(
      tag: 'img',
      generator: (e, config, visitor) =>
          LocalImageSpanNode(e.attributes, _localLessonFolderPath, config),
    );

    final generator = MarkdownGenerator(
      generators: [latexGenerator, imageGenerator],     // <-- put custom generators here
      inlineSyntaxList: [LatexSyntax()],// <-- and custom inline syntaxes here
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.folderName)),
      body: FutureBuilder<String>(
        future: _mdContentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data ?? '';
          if (data.isEmpty) {
            return const Center(child: Text('No content available'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: MarkdownWidget(
              data: data,
              markdownGenerator: generator, 
            ),
          );
        },
      ),
    );
  }
}
