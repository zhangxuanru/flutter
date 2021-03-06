// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import '../widgets/semantics_tester.dart';

void main() {
  testWidgets('Radio control test', (WidgetTester tester) async {
    final Key key = new UniqueKey();
    final List<int> log = <int>[];

    await tester.pumpWidget(new Material(
      child: new Center(
        child: new Radio<int>(
          key: key,
          value: 1,
          groupValue: 2,
          onChanged: log.add,
        ),
      ),
    ));

    await tester.tap(find.byKey(key));

    expect(log, equals(<int>[1]));
    log.clear();

    await tester.pumpWidget(new Material(
      child: new Center(
        child: new Radio<int>(
          key: key,
          value: 1,
          groupValue: 1,
          onChanged: log.add,
          activeColor: Colors.green[500],
        ),
      ),
    ));

    await tester.tap(find.byKey(key));

    expect(log, isEmpty);

    await tester.pumpWidget(new Material(
      child: new Center(
        child: new Radio<int>(
          key: key,
          value: 1,
          groupValue: 2,
          onChanged: null,
        ),
      ),
    ));

    await tester.tap(find.byKey(key));

    expect(log, isEmpty);
  });

  testWidgets('Radio size is configurable by ThemeData.materialTapTargetSize', (WidgetTester tester) async {
    final Key key1 = new UniqueKey();
    await tester.pumpWidget(
      new Theme(
        data: new ThemeData(materialTapTargetSize: MaterialTapTargetSize.padded),
        child: new Directionality(
          textDirection: TextDirection.ltr,
          child: new Material(
            child: new Center(
              child: new Radio<bool>(
                key: key1,
                groupValue: true,
                value: true,
                onChanged: (bool newValue) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(key1)), const Size(48.0, 48.0));

    final Key key2 = new UniqueKey();
    await tester.pumpWidget(
      new Theme(
        data: new ThemeData(materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
        child: new Directionality(
          textDirection: TextDirection.ltr,
          child: new Material(
            child: new Center(
              child: new Radio<bool>(
                key: key2,
                groupValue: true,
                value: true,
                onChanged: (bool newValue) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(key2)), const Size(40.0, 40.0));
  });


  testWidgets('Radio semantics', (WidgetTester tester) async {
    final SemanticsTester semantics = new SemanticsTester(tester);

    await tester.pumpWidget(new Material(
      child: new Radio<int>(
        value: 1,
        groupValue: 2,
        onChanged: (int i) { },
      ),
    ));

    expect(semantics, hasSemantics(new TestSemantics.root(
      children: <TestSemantics>[
        new TestSemantics.rootChild(
          id: 1,
          flags: <SemanticsFlag>[
            SemanticsFlag.isInMutuallyExclusiveGroup,
            SemanticsFlag.hasCheckedState,
            SemanticsFlag.hasEnabledState,
            SemanticsFlag.isEnabled,
          ],
          actions: <SemanticsAction>[
            SemanticsAction.tap,
          ],
        ),
      ],
    ), ignoreRect: true, ignoreTransform: true));

    await tester.pumpWidget(new Material(
      child: new Radio<int>(
        value: 2,
        groupValue: 2,
        onChanged: (int i) { },
      ),
    ));

    expect(semantics, hasSemantics(new TestSemantics.root(
      children: <TestSemantics>[
        new TestSemantics.rootChild(
          id: 1,
          flags: <SemanticsFlag>[
            SemanticsFlag.isInMutuallyExclusiveGroup,
            SemanticsFlag.hasCheckedState,
            SemanticsFlag.isChecked,
            SemanticsFlag.hasEnabledState,
            SemanticsFlag.isEnabled,
          ],
          actions: <SemanticsAction>[
            SemanticsAction.tap,
          ],
        ),
      ],
    ), ignoreRect: true, ignoreTransform: true));

    await tester.pumpWidget(const Material(
      child: const Radio<int>(
        value: 1,
        groupValue: 2,
        onChanged: null,
      ),
    ));

    expect(semantics, hasSemantics(new TestSemantics.root(
      children: <TestSemantics>[
        new TestSemantics.rootChild(
          id: 1,
          flags: <SemanticsFlag>[
            SemanticsFlag.isInMutuallyExclusiveGroup,
            SemanticsFlag.hasCheckedState,
            SemanticsFlag.hasEnabledState,
          ],
        ),
      ],
    ), ignoreRect: true, ignoreTransform: true));

    await tester.pumpWidget(const Material(
      child: const Radio<int>(
        value: 2,
        groupValue: 2,
        onChanged: null,
      ),
    ));

    expect(semantics, hasSemantics(new TestSemantics.root(
      children: <TestSemantics>[
        new TestSemantics.rootChild(
          id: 1,
          flags: <SemanticsFlag>[
            SemanticsFlag.isInMutuallyExclusiveGroup,
            SemanticsFlag.hasCheckedState,
            SemanticsFlag.isChecked,
            SemanticsFlag.hasEnabledState,
          ],
        ),
      ],
    ), ignoreRect: true, ignoreTransform: true));

    semantics.dispose();
  });

  testWidgets('has semantic events', (WidgetTester tester) async {
    final SemanticsTester semantics = new SemanticsTester(tester);
    final Key key = new UniqueKey();
    dynamic semanticEvent;
    int radioValue = 2;
    SystemChannels.accessibility.setMockMessageHandler((dynamic message) {
      semanticEvent = message;
    });

    await tester.pumpWidget(new Material(
      child: new Radio<int>(
        key: key,
        value: 1,
        groupValue: radioValue,
        onChanged: (int i) {
          radioValue = i;
        },
      ),
    ));

    await tester.tap(find.byKey(key));
    final RenderObject object = tester.firstRenderObject(find.byKey(key));

    expect(radioValue, 1);
    expect(semanticEvent, <String, dynamic>{
      'type': 'tap',
      'nodeId': object.debugSemantics.id,
      'data': <String, dynamic>{},
    });
    expect(object.debugSemantics.getSemanticsData().hasAction(SemanticsAction.tap), true);

    semantics.dispose();
    SystemChannels.accessibility.setMockMessageHandler(null);
  });
}

