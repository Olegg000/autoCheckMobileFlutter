import 'package:autocheck_flutter/src/models/submission.dart';
import 'package:autocheck_flutter/src/screens/submission_details_screen.dart';
import 'package:autocheck_flutter/src/services/app_logger.dart';
import 'package:autocheck_flutter/src/services/backend_repository.dart';
import 'package:autocheck_flutter/src/theme/app_theme.dart';
import 'package:autocheck_flutter/src/widgets/app_chrome.dart';
import 'package:autocheck_flutter/src/widgets/tech_components.dart';
import 'package:autocheck_flutter/src/widgets/tech_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UploadSubmissionScreen extends StatefulWidget {
  const UploadSubmissionScreen({super.key});

  @override
  State<UploadSubmissionScreen> createState() => _UploadSubmissionScreenState();
}

class _UploadSubmissionScreenState extends State<UploadSubmissionScreen> {
  final _repository = BackendRepository.instance;
  final _candidateName = TextEditingController(text: 'Иван Петров');
  final _candidateEmail = TextEditingController(text: 'ivan.petrov@test.ru');
  final _gitUrl = TextEditingController();

  late Future<List<Assignment>> _assignmentsFuture;
  String? _assignmentId;
  PlatformFile? _file;
  SourceType _sourceType = SourceType.zip;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _assignmentsFuture = _repository.assignments();
  }

  @override
  void dispose() {
    _candidateName.dispose();
    _candidateEmail.dispose();
    _gitUrl.dispose();
    super.dispose();
  }

  Future<void> _pickZip() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: const ['zip'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      if (!file.name.toLowerCase().endsWith('.zip')) {
        setState(() => _error = 'Можно загрузить только ZIP-архив');
        return;
      }
      if (file.size > 50 * 1024 * 1024) {
        setState(() => _error = 'ZIP-архив должен быть не больше 50 МБ');
        return;
      }

      setState(() {
        _file = file;
        _error = null;
      });
    } catch (error) {
      AppLogger.error('UploadSubmissionScreen', 'File picker failed', error);
      setState(() => _error = 'Не удалось открыть выбор файла: $error');
    }
  }

  Future<void> _submit() async {
    if (_assignmentId == null || _assignmentId!.isEmpty) {
      setState(() => _error = 'Выберите тестовое задание');
      return;
    }
    if (_candidateName.text.trim().isEmpty ||
        !_candidateEmail.text.contains('@')) {
      setState(() => _error = 'Введите ФИО и корректный email кандидата');
      return;
    }
    if (_sourceType == SourceType.zip && _file == null) {
      setState(() => _error = 'Выберите ZIP-архив решения');
      return;
    }
    if (_sourceType == SourceType.git &&
        !_gitUrl.text.trim().startsWith('http')) {
      setState(() => _error = 'Введите публичный Git URL');
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      AppLogger.info('UploadSubmissionScreen', 'Submission upload started', {
        'assignmentId': _assignmentId,
        'sourceType': _sourceType.name,
      });
      final submission = await _repository.createSubmission(
        assignmentId: _assignmentId!,
        candidateEmail: _candidateEmail.text.trim(),
        candidateFullName: _candidateName.text.trim(),
        file: _sourceType == SourceType.zip ? _file : null,
        gitUrl: _sourceType == SourceType.git ? _gitUrl.text.trim() : null,
      );
      AppLogger.debug('UploadSubmissionScreen', 'Submission upload completed',
          {'submissionId': submission.id});
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => SubmissionDetailsScreen(submissionId: submission.id),
        ),
      );
    } catch (error) {
      AppLogger.error(
          'UploadSubmissionScreen', 'Submission upload failed', error);
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppChrome(
      selected: 'upload',
      onDashboard: () => Navigator.of(context).pop(),
      child: FutureBuilder<List<Assignment>>(
        future: _assignmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return TechPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TechLabel('Assignments error'),
                  const SizedBox(height: 12),
                  Text(
                    snapshot.error.toString().replaceFirst('Exception: ', ''),
                    style:
                        const TextStyle(color: Color(0xFFFF7A3D), height: 1.45),
                  ),
                  const SizedBox(height: 20),
                  TechButton(
                    icon: TechIconType.refresh,
                    label: 'Повторить',
                    onPressed: () => setState(
                        () => _assignmentsFuture = _repository.assignments()),
                    variant: TechButtonVariant.secondary,
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const TechPanel(
              child: SizedBox(
                  height: 220,
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accent, strokeWidth: 1.5))),
            );
          }
          final assignments = snapshot.data!;
          _assignmentId ??= assignments.isEmpty ? null : assignments.first.id;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TechLabel('Sprint-2 / intake terminal'),
              SizedBox(height: 18),
              Text('Загрузка решения',
                  style: Theme.of(context).textTheme.displayLarge),
              SizedBox(height: 20),
              Text(
                  'Отправьте ZIP-архив или Git URL прямо в backend. Проверка попадет в Redis-очередь.',
                  style: TextStyle(color: AppColors.muted)),
              SizedBox(height: 44),
              TechPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TechLabel('Тестовое задание'),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _assignmentId,
                      dropdownColor: AppColors.panel,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.panelDeep,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: AppColors.accent)),
                      ),
                      items: assignments
                          .map((item) => DropdownMenuItem(
                              value: item.id, child: Text(item.title)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _assignmentId = value),
                    ),
                    SizedBox(height: 18),
                    _Field(label: 'ФИО кандидата', controller: _candidateName),
                    SizedBox(height: 18),
                    _Field(
                        label: 'Email кандидата', controller: _candidateEmail),
                    const SizedBox(height: 22),
                    _SourceSwitch(
                        value: _sourceType,
                        onChanged: (value) =>
                            setState(() => _sourceType = value)),
                    const SizedBox(height: 22),
                    if (_sourceType == SourceType.zip)
                      _ZipPicker(file: _file, onPick: _pickZip)
                    else
                      _Field(label: 'Git URL', controller: _gitUrl),
                    if (_error != null) ...[
                      const SizedBox(height: 18),
                      _ErrorPanel(_error!),
                    ],
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.end,
                      children: [
                        TechButton(
                            label: 'Отмена',
                            variant: TechButtonVariant.ghost,
                            onPressed: () => Navigator.of(context).pop(false)),
                        TechButton(
                            icon: TechIconType.upload,
                            label: 'Отправить',
                            loading: _loading,
                            onPressed: _submit),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SourceSwitch extends StatelessWidget {
  const _SourceSwitch({required this.onChanged, required this.value});

  final SourceType value;
  final ValueChanged<SourceType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: SourceType.values.map((item) {
        final active = value == item;
        return Expanded(
          child: InkWell(
            onTap: () => onChanged(item),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: active ? AppColors.accent : AppColors.panelDeep,
                border: Border.all(
                    color: active ? AppColors.accent : AppColors.border),
              ),
              child: Text(
                item == SourceType.zip ? 'ZIP-файл' : 'Git URL',
                textAlign: TextAlign.center,
                style: TechText.label.copyWith(
                    color: active ? AppColors.background : AppColors.muted),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ZipPicker extends StatelessWidget {
  const _ZipPicker({required this.file, required this.onPick});

  final PlatformFile? file;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
            color: AppColors.panelDeep,
            border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            const TechIcon(TechIconType.upload, color: AppColors.accent),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file?.name ?? 'Выбрать ZIP-архив',
                    style: TextStyle(
                      color: file == null ? AppColors.muted : AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (file != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      '${(file!.size / 1024 / 1024).toStringAsFixed(2)} МБ',
                      style:
                          const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TechLabel(label),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.text),
          decoration: const InputDecoration(
            filled: true,
            fillColor: AppColors.panelDeep,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: AppColors.accent)),
          ),
        ),
      ],
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.35))),
      child: Text(text, style: const TextStyle(color: Color(0xFFFF7A3D))),
    );
  }
}
