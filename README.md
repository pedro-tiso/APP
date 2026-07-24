# Consulta NF M&R — Flutter

Aplicativo Android offline para:

1. selecionar uma planilha `.xlsx` ou `.xlsm`;
2. ler as colunas **NF** e **STATUS**;
3. fotografar somente a região do número da NF;
4. reconhecer o número com OCR local;
5. mostrar:
   - **CANHOTO PENDENTE** quando o status for `Aguardando Comprovante`;
   - **CANHOTO APROVADO** quando a NF existir com outro status;
   - **NF NÃO ENCONTRADA** quando o número não estiver na planilha.

A planilha selecionada fica salva no armazenamento privado do aplicativo e é reaberta automaticamente no próximo uso. Nenhum dado é enviado para servidor.

## Estrutura esperada da planilha

A primeira aba deve possuir uma linha de cabeçalho com as colunas:

- `NF`
- `STATUS`

A coluna `EMISSAO` pode existir, mas não é obrigatória para a consulta.

## Gerar APK sem instalar Flutter no computador corporativo

O projeto já contém um fluxo do GitHub Actions em `.github/workflows/build-apk.yml`.

1. Crie um repositório no GitHub pelo navegador.
2. Envie os arquivos deste projeto para o repositório.
3. Abra **Actions** → **Gerar APK** → **Run workflow**.
4. Aguarde a compilação.
5. Abra a execução concluída e baixe o artefato **ConsultaNF-MR-APK**.
6. Extraia o ZIP baixado e instale `app-release.apk` no celular.

Isso compila o aplicativo nos servidores do GitHub, sem WSL, Android Studio ou troca do sistema operacional no computador da empresa.

## Compilar em um computador pessoal

Com Flutter estável instalado:

```bash
bash scripts/prepare_android.sh
flutter test
flutter build apk --release
```

APK:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Observações

- Android mínimo: 7.0 / API 24.
- OCR: Google ML Kit, processado no aparelho.
- Formatos aceitos: `.xlsx` e `.xlsm`.
- O aplicativo prioriza `Aguardando Comprovante` se a mesma NF aparecer mais de uma vez.
- Números com `-1`, espaços e zeros iniciais são normalizados antes da comparação.
