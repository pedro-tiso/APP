import 'package:consulta_nf_mr/services/nf_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normaliza NF com sufixo e zeros', () {
    expect(normalizeNf('001817859-1'), '1817859');
    expect(normalizeNf(1817859.0), '1817859');
  });

  test('prioriza número existente na planilha', () {
    final result = extractBestNf('NF 9999999 valor 1817859', {'1817859'});
    expect(result, '1817859');
  });

  test('normaliza status com acentos e espaços', () {
    expect(normalizeStatus('  Aguardando   Comprovante '), 'AGUARDANDO COMPROVANTE');
  });
}
