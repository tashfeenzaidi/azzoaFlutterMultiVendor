import 'package:azzoa_grocery/data/remote/model/term.dart';
import 'package:flutter/material.dart';

class AttributeContent {
  int id;
  String title;
  String attributeSlug;
  String attributeTitle;
  String attributeName;
  Term term;

  AttributeContent({
    @required this.id,
    @required this.title,
    @required this.attributeSlug,
    @required this.attributeTitle,
    @required this.attributeName,
    @required this.term,
  });
}
