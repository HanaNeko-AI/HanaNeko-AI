import 'package:flutter/material.dart';

class FeedbackCard extends StatelessWidget {
  final String userTranslation;
  final String correctTranslation;
  final String romaji;
  final List<dynamic> alternative;
  final List<dynamic> alternativeRomaji;
  final List<TextSpan> feedbackSpans;
  final VoidCallback onExplainWrongPart;
  final bool isCorrectTranslationExpanded;
  final VoidCallback onToggleCorrectTranslation;

  const FeedbackCard({
    super.key,
    required this.userTranslation,
    required this.correctTranslation,
    required this.romaji,
    required this.alternative,
    required this.alternativeRomaji,
    required this.feedbackSpans,
    required this.onExplainWrongPart,
    required this.isCorrectTranslationExpanded,
    required this.onToggleCorrectTranslation,
  });

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 16, height: 1.5);
    const labelStyle =
        TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.5);
    const sectionSpacing = 16.0;
    const itemSpacing = 8.0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection('Your Translation', userTranslation),
                      const SizedBox(height: sectionSpacing),
                      _buildExpandableSection(
                        'Correct Translation',
                        correctTranslation,
                        isCorrectTranslationExpanded,
                        onToggleCorrectTranslation,
                        expandedContent: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: itemSpacing),
                            const Text('Alternatives:', style: labelStyle),
                            const SizedBox(height: itemSpacing / 2),
                            ...alternative.asMap().entries.map((entry) {
                              final index = entry.key;
                              final alt = entry.value;
                              final altRomaji = alternativeRomaji[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: itemSpacing),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(alt, style: textStyle),
                                    const SizedBox(height: 4),
                                    Text(
                                      altRomaji,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: sectionSpacing),
                      _buildSection('Feedback', null,
                          content: Text.rich(
                            TextSpan(
                              style: textStyle,
                              children: feedbackSpans,
                            ),
                          )),
                      const Spacer(),
                      const SizedBox(height: sectionSpacing),
                      OutlinedButton(
                        onPressed: onExplainWrongPart,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 36),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Explanation', style: textStyle),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String label, String? text, {Widget? content}) {
    const textStyle = TextStyle(fontSize: 16, height: 1.5);
    const labelStyle =
        TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.5);
    const itemSpacing = 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: itemSpacing),
        if (text != null) Text(text, style: textStyle),
        if (content != null) content,
      ],
    );
  }

  Widget _buildExpandableSection(
    String label,
    String text,
    bool isExpanded,
    VoidCallback onToggle, {
    Widget? expandedContent,
  }) {
    const textStyle = TextStyle(fontSize: 16, height: 1.5);
    const labelStyle =
        TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.5);
    const itemSpacing = 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Row(
            children: [
              Text(label, style: labelStyle),
              const Spacer(),
              Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            ],
          ),
        ),
        const SizedBox(height: itemSpacing),
        Text(text, style: textStyle),
        // Always show the romaji under the correct translation
        Text(
          romaji,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black.withOpacity(0.6),
          ),
        ),

        if (isExpanded && expandedContent != null)
          Padding(
            padding: const EdgeInsets.only(top: itemSpacing),
            child: expandedContent,
          ),
      ],
    );
  }
}
