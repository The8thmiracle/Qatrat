import 'package:customer/Helper/Session.dart';
import 'package:customer/cubits/downloadFileCubit.dart';
import 'package:customer/ui/styles/DesignConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';

class DownloadFileDialog extends StatefulWidget {
  final String fileUrl;
  final String fileName;
  final String fileExtension;
  final bool storeInExternalStorage;
  const DownloadFileDialog(
      {super.key,
      required this.fileExtension,
      required this.fileName,
      required this.fileUrl,
      required this.storeInExternalStorage,});
  @override
  State<DownloadFileDialog> createState() => _DownloadFileDialogState();
}

class _DownloadFileDialogState extends State<DownloadFileDialog> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      context.read<DownloadFileCubit>().downloadFile(
          fileUrl: widget.fileUrl,
          fileName: widget.fileName,
          fileExtension: widget.fileExtension,
          storeInExternalStorage: widget.storeInExternalStorage,);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          if (context.read<DownloadFileCubit>().state
              is! DownloadFileInProgress) {
            if (didPop) {
              return;
            }
            Navigator.of(context).pop();
          }
        }
      },
      child: BlocConsumer<DownloadFileCubit, DownloadFileState>(
        listener: (context, state) {
          if (state is DownloadFileFailure) {
            setSnackbar(state.errorMessage, context);
            Navigator.of(context).pop();
          } else if (state is DownloadFileSuccess) {
            Navigator.of(context).pop();
            OpenFilex.open(state.downloadedFileUrl);
          }
        },
        builder: (context, state) {
          Widget content = Text('${getTranslated(context, 'PROGRESS')} : -');
          if (state is DownloadFileInProgress) {
            content = Text(
                '${getTranslated(context, 'PROGRESS')} : ${state.downloadPercentage.toStringAsFixed(2)}',);
          } else if (state is DownloadFileSuccess) {
            content = Text(getTranslated(context, 'FILE_DOWNLOAD_SUCCESS')!);
          }
          return AlertDialog(
              title: Text(getTranslated(context, 'FILE_DOWNLOAD_PROGRESS')!),
              content: content,);
        },
      ),
    );
  }
}
