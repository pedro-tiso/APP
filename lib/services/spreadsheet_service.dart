import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

import 'nf_utils.dart';

class SpreadsheetData {
  const SpreadsheetData({required this.fileName, required this.records});

  final String fileName;
  final Map<String, String> records;
}

class SpreadsheetService {
  static const _savedFileName = 'planilha_atual.xlsx';
  static const _savedNameFile = 'planilha_nome.txt';

  Future<SpreadsheetData> loadBytes(Uint8List bytes, String originalName) async {
    final data = _decode(bytes, originalName);
    final directory = await getApplicationSupportDirectory();
    await File('${directory.path}/$_savedFileName').writeAsBytes(bytes, flush: true);
    await File('${directory.path}/$_savedNameFile').writeAsString(originalName, flush: true);
    return data;
  }

  Future<SpreadsheetData?> loadSaved() async {
    final directory = await getApplicationSupportDirectory();
    final sheetFile = File('${directory.path}/$_savedFileName');
    if (!await sheetFile.exists()) return null;
    final nameFile = File('${directory.path}/$_savedNameFile');
    final originalName = await nameFile.exists()
        ? (await nameFile.readAsString()).trim()
        : _savedFileName;
    return _decode(await sheetFile.readAsBytes(), originalName);
  }

  Object? _cellValue(CellValue? value) {
    return switch (value) {
      null => null,
      TextCellValue() => value.value.toString(),
      IntCellValue() => value.value,
      DoubleCellValue() => value.value,
      BoolCellValue() => value.value,
      FormulaCellValue() => value.formula,
      DateCellValue() => value.asDateTimeLocal(),
      TimeCellValue() => value.asDuration(),
      DateTimeCellValue() => value.asDateTimeLocal(),
    };
  }

  SpreadsheetData _decode(Uint8List bytes, String originalName) {
    final workbook = Excel.decodeBytes(bytes);
    if (workbook.tables.isEmpty) {
      throw const FormatException('A planilha não contém nenhuma aba.');
    }

    final firstSheetName = workbook.tables.keys.first;
    final sheet = workbook.tables[firstSheetName];
    if (sheet == null || sheet.rows.isEmpty) {
      throw const FormatException('A primeira aba da planilha está vazia.');
    }

    final headers = sheet.rows.first
        .map((cell) => normalizeHeader(_cellValue(cell?.value)))
        .toList(growable: false);

    const nfCandidates = {'NF', 'NFE', 'NOTAFISCAL', 'NUMERONF', 'NUMERONFE'};
    const statusCandidates = {'STATUS', 'SITUACAO', 'STATUSNF', 'STATUSNOTA'};

    final nfIndex = headers.indexWhere(nfCandidates.contains);
    final statusIndex = headers.indexWhere(statusCandidates.contains);

    if (nfIndex < 0) {
      throw const FormatException('A coluna obrigatória "NF" não foi encontrada.');
    }
    if (statusIndex < 0) {
      throw const FormatException('A coluna obrigatória "STATUS" não foi encontrada.');
    }

    final records = <String, String>{};
    for (final row in sheet.rows.skip(1)) {
      final nfValue = nfIndex < row.length ? _cellValue(row[nfIndex]?.value) : null;
      final statusValue = statusIndex < row.length ? _cellValue(row[statusIndex]?.value) : null;
      final nf = normalizeNf(nfValue);
      if (nf.isEmpty) continue;
      final status = statusValue?.toString().trim() ?? '';
      final previous = records[nf] ?? '';
      if (normalizeStatus(status) == 'AGUARDANDO COMPROVANTE') {
        records[nf] = status;
      } else if (!records.containsKey(nf) || previous.isEmpty) {
        records[nf] = status;
      }
    }

    if (records.isEmpty) {
      throw const FormatException('Nenhuma NF válida foi encontrada na planilha.');
    }

    return SpreadsheetData(fileName: originalName, records: records);
  }
}
