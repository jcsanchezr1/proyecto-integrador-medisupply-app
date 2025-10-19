import 'dart:io';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../../providers/create_account_provider.dart';

import '../../utils/texts_util.dart';
import '../../utils/colors_app.dart';
import '../../utils/responsive_app.dart';

import 'poppins_text.dart';

class ButtonFilePicker extends StatefulWidget {

  final String sLabel;
  final List<String> lAllowedExtensions;
  final Future<FilePickerResult?> Function({
    FileType type,
    List<String>? allowedExtensions,
  })? filePickerCallback;

  const ButtonFilePicker(
    {
      super.key,
      required this.sLabel,
      required this.lAllowedExtensions,
      this.filePickerCallback
    } 
  );

  @override
  State<ButtonFilePicker> createState() => _ButtonFilePickerState();

}

class _ButtonFilePickerState extends State<ButtonFilePicker> {

  File? selectedImage;

  @override
  Widget build( BuildContext context ) {

    final createAccountProvider = Provider.of<CreateAccountProvider>(context);

    return SizedBox(
      width: ResponsiveApp.dWidth( 312.0 ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PoppinsText(
                sText: widget.sLabel, 
                dFontSize: ResponsiveApp.dSize( 13.0 ),
                colorText: ColorsApp.textColor
              ),
              SizedBox( height: ResponsiveApp.dHeight( 8.0 ) ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsApp.sucessColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular( 12.0 )
                  )
                ),
                onPressed: () async {
                  final result = widget.filePickerCallback != null
                    ? await widget.filePickerCallback!(
                        type: FileType.custom,
                        allowedExtensions: widget.lAllowedExtensions
                      )
                    : await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: widget.lAllowedExtensions
                      );
                  if ( result != null && result.files.isNotEmpty && result.files.first.path != null ) {
                    setState( () => selectedImage = File( result.files.first.path! ) );
                    createAccountProvider.logoFile = selectedImage!;
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.upload_rounded,
                      color: ColorsApp.secondaryTextColor
                    ),
                    SizedBox( width: ResponsiveApp.dWidth( 8.0 ) ), 
                    Flexible(
                      child: PoppinsText(
                        sText: TextsUtil.of( context )?.getText( 'transversal.upload_button' ) ?? 'Upload',
                         colorText: ColorsApp.secondaryTextColor,
                         dFontSize: ResponsiveApp.dSize( 14.0 ),
                         fontWeight: FontWeight.w500
                      ),
                    )
                  ]
                )
              )
            ]
          ),
        ),
          if (selectedImage?.path != null) Container(
            margin: EdgeInsets.only( left: ResponsiveApp.dWidth( 16.0 ) ),
            clipBehavior: Clip.antiAlias,
            width: ResponsiveApp.dWidth( 64.0 ),
            height: ResponsiveApp.dHeight( 64.0 ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular( 12.0 ),
            ),
            child: Image.file(  
              selectedImage!,
              fit: BoxFit.cover
            )
          ) else SizedBox()
        ]
      )
    );
  }
}