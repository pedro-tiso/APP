enum NfResultType { approved, pending, notFound, unidentified, idle }

class NfResult {
  const NfResult({
    required this.type,
    required this.title,
    required this.message,
  });

  final NfResultType type;
  final String title;
  final String message;

  static const idle = NfResult(
    type: NfResultType.idle,
    title: '',
    message: 'Selecione a planilha para começar.',
  );
}
