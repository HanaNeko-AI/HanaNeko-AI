import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'utils.dart';
import 'platform_audio_recorder.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

// Import new components
import 'translation_input.dart';
import 'feedback_card.dart';
import 'sidebar.dart';

class LanguageLearningPage extends StatefulWidget {
  const LanguageLearningPage({super.key});

  @override
  State<LanguageLearningPage> createState() => _LanguageLearningPageState();
}

class _LanguageLearningPageState extends State<LanguageLearningPage> {
  // Default state of the app
  String _sourceLanguage = 'English';
  String _targetLanguage = 'Japanese';
  String _inputMethod = 'Audio';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final GenerativeModel _model;
  late final GenerativeModel _flashModel;

  late final ChatSession _chat;
  late final ChatSession _flashChat;

  final TextEditingController _textController = TextEditingController();
  final PlatformAudioRecorder _audioRecorder = PlatformAudioRecorder();
  bool _isCorrectTranslationExpanded = false;

  String _question = "";
  bool _isEditingQuestion = false;
  final TextEditingController _questionController = TextEditingController();

  String _userTranslation = "";
  String _correctTranslation = "";
  String romaji = "";
  List<dynamic> alternativeRomaji = [];

  List<dynamic> alternative = [];

  String _explanation = "";
  bool _isExplanationReady = false;
  bool _isExplanationGenerating = false;
  Completer<void>? _explanationCompleter;
  List<TextSpan> _feedbackSpans = [];
  bool _showDetails = false;
  bool _isRecording = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _getNextQuestion();
  }

  void _initializeChat() {
    // Generation Config make the output json
    GenerationConfig config = GenerationConfig(
      temperature: 1,
      topP: 0.95,
      topK: 64,
      maxOutputTokens: 8192,
      responseMimeType: 'application/json',
    );
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    // for translation and transcription
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      // generationConfig: config,
    );

    _flashModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      // generationConfig: config,
    );

    _chat = _model.startChat();
    _flashChat = _flashModel.startChat();
  }

  Future<void> _getNextQuestion() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _flashChat.sendMessage(
        Content.text(
          "Generate a simple {$_sourceLanguage} sentence for {$_targetLanguage} translation practice. Respond with just the sentence.",
        ),
      );
      setState(() {
        _question = response.text ?? "Failed to generate question.";
        _questionController.text = _question;
        _userTranslation = "";
        _correctTranslation = "";
        alternative = [];
        _explanation = "";
        _isExplanationReady = false;
        _isExplanationGenerating = false;
        _feedbackSpans = [];
        _showDetails = false;
        _textController.clear();
      });
    } catch (e) {
      handleError(context, 'Failed to generate question. Please try again.', e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _processUserInput({bool isAudio = false}) async {
    setState(() {
      _isLoading = true;
    });
    String userInput = isAudio ? "" : _textController.text;
    try {
      Content content;
      if (isAudio) {
        Uint8List audioBytes = await _audioRecorder.getAudioData();
        content = Content.multi([
          TextPart(
            // User input is in (target), so the transcription is in (target) and the translation of the question to (target)
            "1. Transcribe the provided audio into $_targetLanguage text and report it as `userTranslation`. "
            "2. Translate the question `$_question` into $_targetLanguage and report it as `correctTranslation`. "
            "3. Provide 3 alternative translations as `alternativeTranslations`. "
            "4. Compare `userTranslation` with `correctTranslation` and highlight correct parts in green and incorrect parts in red. Minor informalities are acceptable if the grammar is correct. "
            "5. Provide the romaji reading of this '$_correctTranslation', in the `romaji` key. "
            "6. Provide the romaji reading for each alternative translation in the `alternativeRomaji` key as an array. "
            "7. Format the response as a JSON object with the following keys: "
            "- `userTranslation`, "
            "- `correctTranslation`, "
            "- `alternativeTranslations`, "
            "- `romaji`,"
            "- `alternativeRomaji`, "
            "- `feedbackSpans` (an array of `{text, color}` objects).",
          ),
          DataPart(kIsWeb ? 'audio/webm;codecs=opus' : 'audio/m4a', audioBytes)
        ]);
      } else {
        content = Content.text(
          "1. Translate `$_question` to $_targetLanguage and report it as `correctTranslation`. "
          "2. Compare it with the user's translation: `$userInput`. "
          "3. Provide 3 alternative translations as `alternativeTranslations`. "
          "4. Highlight correct parts in green and incorrect parts in red. Minor informalities are acceptable if the grammar is correct. "
          "5. Provide the romaji reading of the sentence in the `romaji` key. "
          "6. Provide the romaji reading for each alternative translation in the `alternativeRomaji` key as an array. "
          "7. Format the response as a JSON object with the following keys: "
          "- `correctTranslation`, "
          "- `alternativeTranslations`, "
          "- `romaji`,"
          "- `alternativeRomaji`, "
          "- `feedbackSpans` (an array of `{text, color}` objects).",
        );
      }

      final response = await _chat.sendMessage(content);
      final jsonResponse = response.text != null
          ? response.text!.substring(
              response.text!.indexOf('{'), response.text!.lastIndexOf('}') + 1)
          : '{}';
      final Map<String, dynamic> parsedResponse = json.decode(jsonResponse);
      romaji = parsedResponse['romaji'] ?? "";
      alternativeRomaji = parsedResponse['alternativeRomaji'] ?? [];
      setState(() {
        if (isAudio) {
          _userTranslation =
              parsedResponse['userTranslation'] ?? "Failed to transcribe audio";
        } else {
          _userTranslation = userInput;
        }
        _correctTranslation = parsedResponse['correctTranslation'] ?? "";
        alternative = parsedResponse['alternativeTranslations'] ?? [];
        _feedbackSpans = (parsedResponse['feedbackSpans'] as List<dynamic>?)
                ?.map((span) => TextSpan(
                    text: span['text'],
                    style: TextStyle(
                        color: span['color'] == 'green'
                            ? Colors.green
                            : Colors.red)))
                .toList() ??
            [];
        // alternative = parsedResponse['alternativeTranslations'] ?? [];

        _showDetails = true;
        _isExplanationReady = false;
        _isExplanationGenerating = false;
      });
      _generateExplanation();
    } catch (e) {
      handleError(context, 'Failed to process input. Please try again.', e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateExplanation() async {
    if (_isExplanationGenerating) return;

    _isExplanationGenerating = true;
    _explanationCompleter = Completer<void>();

    try {
      final explanationResponse = await _chat.sendMessage(
        Content.text(
          "Explain the incorrect parts of the user's translation: '$_userTranslation' "
          "compared to the correct translation: '$_correctTranslation'."
          "Explanation should be in the source language of the user which is $_sourceLanguage.",
        ),
      );
      if (!_explanationCompleter!.isCompleted) {
        setState(() {
          _explanation =
              explanationResponse.text ?? "No explanation available.";
          _isExplanationReady = true;
          _isExplanationGenerating = false;
        });
        _explanationCompleter!.complete();
      }
    } catch (e) {
      print("Error generating explanation: $e");
      if (!_explanationCompleter!.isCompleted) {
        setState(() {
          _explanation = "Failed to generate explanation.";
          _isExplanationReady = true;
          _isExplanationGenerating = false;
        });
        _explanationCompleter!.complete();
      }
    }
  }

  void _explainWrongPart() {
    if (_isExplanationReady) {
      _showExplanation();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text("Generating Explanation"),
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Please wait..."),
              ],
            ),
          );
        },
      );

      Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        return !_isExplanationReady;
      }).then((_) {
        Navigator.of(context).pop();
        _showExplanation();
      });
    }
  }

  void _showExplanation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Explanation',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Flexible(child: Markdown(data: _explanation)),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleRecording() async {
    try {
      if (_audioRecorder.isRecording) {
        await _stopRecording();
      } else {
        await _startRecording();
      }
    } catch (e) {
      handleError(context, 'Failed to toggle recording. Please try again.', e);
    }
  }

  Future<void> _startRecording() async {
    try {
      await _audioRecorder.startRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      handleError(context, 'Failed to start recording. Please try again.', e);
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stopRecording();
      setState(() {
        _isRecording = false;
      });
      await _processUserInput(isAudio: true);
    } catch (e) {
      handleError(context, 'Failed to stop recording. Please try again.', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'HanaNeko',
          style: GoogleFonts.mochiyPopOne(
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          // Only show the clear button when the user is editing the question
          if (_isEditingQuestion)
            IconButton(
              icon: const Icon(
                Icons.clear,
                color: Colors.redAccent,
              ),
              onPressed: () {
                setState(() {
                  _questionController.clear();
                });
              },
            ),
          IconButton(
            // icon: Icon(Icons.edit),
            icon: Icon(_isEditingQuestion ? Icons.check : Icons.edit),
            onPressed: _toggleEditQuestion,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      endDrawer: Sidebar(
        sourceLanguage: _sourceLanguage,
        targetLanguage: _targetLanguage,
        inputMethod: _inputMethod,
        onSourceLanguageChanged: (String? newValue) {
          setState(() {
            _sourceLanguage = newValue!;
          });
        },
        onTargetLanguageChanged: (String? newValue) {
          setState(() {
            _targetLanguage = newValue!;
          });
        },
        onInputMethodChanged: (String newMethod) {
          setState(() {
            _inputMethod = newMethod;
          });
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildQuestionField(),
              const SizedBox(height: 12),
              if (_inputMethod == 'Text')
                TranslationInput(
                  controller: _textController,
                  onSubmit: () => _processUserInput(),
                )
              else
                Material(
                  color:
                      _isRecording ? Colors.red : Colors.black, // Button color
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _toggleRecording,
                    child: Padding(
                      padding: const EdgeInsets.all(
                          16), // Adjust padding to control button size
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _showDetails
                        ? FeedbackCard(
                            userTranslation: _userTranslation,
                            correctTranslation: _correctTranslation,
                            romaji: romaji,
                            alternative: alternative,
                            alternativeRomaji: alternativeRomaji,
                            feedbackSpans: _feedbackSpans,
                            onExplainWrongPart: _explainWrongPart,
                            isCorrectTranslationExpanded:
                                _isCorrectTranslationExpanded,
                            onToggleCorrectTranslation: () {
                              setState(() {
                                _isCorrectTranslationExpanded =
                                    !_isCorrectTranslationExpanded;
                              });
                            },
                          )
                        : const Center(
                            child:
                                Text('Enter your translation or record audio')),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _getNextQuestion,
                icon: const Icon(
                  Icons.navigate_next,
                  color: Colors.white,
                ),
                label: const Text(
                  'Next Question',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionField() {
    return TextField(
      controller: _questionController,
      readOnly: !_isEditingQuestion,
      maxLines: null,
      decoration: const InputDecoration(
        hintText: " ... ",
        border: InputBorder.none,
      ),
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
      textAlign: TextAlign.center,
      onSubmitted: (_) => _toggleEditQuestion(),
    );
  }

  void _toggleEditQuestion() {
    setState(() {
      if (_isEditingQuestion) {
        _question = _questionController.text;
      }
      _isEditingQuestion = !_isEditingQuestion;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }
}
