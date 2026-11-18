// 3.0 "API gaps closed before release": the page header, pagination and tabs
// fit the width they are given; the scaffold can be reached; the sidenav
// header takes a widget; buttons, the grid and the fields got the API they
// lacked; and a few small visual fixes.
import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _widths = <double>[320, 390, 768, 1280];
const _gutter = AerosSpacing.s4;

void _setView(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// [child] at the top of a page [width] wide, inside the page gutter.
Future<void> _pumpPage(
  WidgetTester tester,
  Widget child, {
  required double width,
  AerosDensity density = AerosDensity.touch,
  TextDirection direction = TextDirection.ltr,
  bool dark = false,
}) async {
  _setView(tester, Size(width, 900));
  await tester.pumpWidget(MaterialApp(
    theme: dark ? AerosTheme.dark() : AerosTheme.light(),
    builder: (context, app) => AerosDensityScope(density: density, child: app!),
    home: Directionality(
      textDirection: direction,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(_gutter),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [child]),
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

List<AerosNavItem> _navItems({VoidCallback? onTap}) => [
      AerosNavItem(label: 'Home', icon: Icons.home_outlined, onTap: onTap ?? () {}),
      AerosNavItem(label: 'Orders', icon: Icons.receipt_long_outlined, onTap: onTap ?? () {}, selected: true),
    ];

void main() {
  // ───────────────────────────────────────────────────────────── 1
  group('AerosPageHeader fits its width', () {
    const longTitle = 'Quarterly reconciliation of outstanding purchase orders and supplier credit notes';
    const longSubtitle = 'Everything raised between April and June that has not been matched to an invoice yet, '
        'grouped by supplier and sorted by the amount still open.';

    List<Widget> actions(int count) => [
          if (count > 0) AerosButton.secondary(label: 'Export', leading: const Icon(Icons.download), onPressed: () {}),
          if (count > 1) AerosButton(label: 'New order', leading: const Icon(Icons.add), onPressed: () {}),
          if (count > 2) AerosButton.ghost(label: 'Archive selected', onPressed: () {}),
        ];

    for (final density in AerosDensity.values) {
      testWidgets('no overflow from 320 up, 0–3 actions, short and long titles · ${density.name}', (tester) async {
        for (final width in _widths) {
          for (final long in [false, true]) {
            for (var count = 0; count <= 3; count++) {
              await _pumpPage(
                tester,
                AerosPageHeader(
                  title: long ? longTitle : 'Orders',
                  subtitle: long ? longSubtitle : '128 orders in the last 30 days',
                  breadcrumbs: const [AerosBreadcrumbItem('Patterns'), AerosBreadcrumbItem('Orders list')],
                  leading: const AerosAvatar(initials: 'BM'),
                  actions: actions(count),
                  padding: EdgeInsets.zero,
                ),
                width: width,
                density: density,
              );
              final reason = 'width $width, $count actions, ${long ? 'long' : 'short'} title';
              expect(tester.takeException(), isNull, reason: reason);
              final header = tester.getRect(find.byType(AerosPageHeader));
              expect(header.width, width - _gutter * 2, reason: reason);
              for (final button in find.byType(AerosButton).evaluate()) {
                final rect = tester.getRect(find.byWidget(button.widget));
                expect(rect.left, greaterThanOrEqualTo(header.left), reason: reason);
                expect(rect.right, lessThanOrEqualTo(header.right), reason: reason);
              }
            }
          }
        }
      });
    }

    testWidgets('on a phone the actions sit under the title, from the leading edge', (tester) async {
      for (final width in [320.0, 390.0]) {
        await _pumpPage(
          tester,
          AerosPageHeader(
            title: 'Orders',
            subtitle: '128 orders in the last 30 days',
            actions: actions(2),
            padding: EdgeInsets.zero,
          ),
          width: width,
        );
        final header = tester.getRect(find.byType(AerosPageHeader));
        final subtitle = tester.getRect(find.text('128 orders in the last 30 days'));
        final export = tester.getRect(find.widgetWithText(AerosButton, 'Export'));
        final create = tester.getRect(find.widgetWithText(AerosButton, 'New order'));
        expect(export.top, greaterThanOrEqualTo(subtitle.bottom));
        expect(export.left, header.left);
        if (width == 390) {
          // Both still on one line, a spacing step apart.
          expect(create.top, export.top);
          expect(create.left, export.right + AerosSpacing.s2);
        } else {
          // Too wide for one line (the test font is wide): the second wraps under the first.
          expect(create.top, greaterThanOrEqualTo(export.bottom));
          expect(create.left, export.left);
        }
      }
    });

    testWidgets('where there is room the actions sit beside the title, at the end, centred on it', (tester) async {
      for (final width in [768.0, 1280.0]) {
        await _pumpPage(
          tester,
          AerosPageHeader(title: 'Orders', subtitle: 'In the last 30 days', actions: actions(2), padding: EdgeInsets.zero),
          width: width,
          density: AerosDensity.pointer,
        );
        final header = tester.getRect(find.byType(AerosPageHeader));
        final create = tester.getRect(find.widgetWithText(AerosButton, 'New order'));
        expect(create.right, header.right);
        expect(create.center.dy, moreOrLessEquals(header.center.dy, epsilon: 0.5));
        expect(header.height, AerosSizeTokens.pointer.header);
      }
    });

    testWidgets('three actions that do not fit on a phone wrap onto a second line', (tester) async {
      await _pumpPage(
        tester,
        AerosPageHeader(title: 'Orders', actions: actions(3), padding: EdgeInsets.zero),
        width: 320,
      );
      final export = tester.getRect(find.widgetWithText(AerosButton, 'Export'));
      final archive = tester.getRect(find.widgetWithText(AerosButton, 'Archive selected'));
      expect(archive.top, greaterThan(export.bottom));
      expect(archive.left, export.left);
    });

    testWidgets('a long title beside its actions keeps a readable measure and is cut after two lines',
        (tester) async {
      await _pumpPage(
        tester,
        AerosPageHeader(title: longTitle, actions: actions(2), padding: EdgeInsets.zero),
        width: 768,
        density: AerosDensity.pointer,
      );
      final header = tester.getRect(find.byType(AerosPageHeader));
      final title = tester.getRect(find.text(longTitle));
      final export = tester.getRect(find.widgetWithText(AerosButton, 'Export'));
      // Beside, not above.
      expect(export.center.dy, moreOrLessEquals(header.center.dy, epsilon: 0.5));
      expect(title.right, lessThanOrEqualTo(export.left - AerosSpacing.s4));
      expect(title.width, greaterThanOrEqualTo(AerosMetricTokens.layoutSidebar));
      final style = AerosTypography.h2();
      expect(title.height, moreOrLessEquals(style.fontSize! * style.height! * 2, epsilon: 1));
    });

    testWidgets('right-to-left mirrors it: title at the right, actions at the left', (tester) async {
      await _pumpPage(
        tester,
        AerosPageHeader(title: 'Orders', actions: actions(1), padding: EdgeInsets.zero),
        width: 1280,
        direction: TextDirection.rtl,
      );
      final header = tester.getRect(find.byType(AerosPageHeader));
      expect(tester.getRect(find.text('Orders')).right, header.right);
      expect(tester.getRect(find.widgetWithText(AerosButton, 'Export')).left, header.left);
    });

    testWidgets('the breadcrumb keeps a spacing step above the title block', (tester) async {
      // Title + subtitle fill the pointer header band, so nothing else separates them.
      await _pumpPage(
        tester,
        const AerosPageHeader(
          title: 'Order #4821',
          subtitle: 'Placed 12 Nov 2026',
          breadcrumbs: [AerosBreadcrumbItem('Orders'), AerosBreadcrumbItem('#4821')],
          padding: EdgeInsets.zero,
        ),
        width: 768,
        density: AerosDensity.pointer,
      );
      final crumbs = tester.getRect(find.byType(AerosBreadcrumb));
      final title = tester.getRect(find.text('Order #4821'));
      expect(title.top - crumbs.bottom, greaterThanOrEqualTo(AerosSpacing.s1_5));
    });

    testWidgets('it can be measured intrinsically', (tester) async {
      await _pumpPage(
        tester,
        IntrinsicHeight(child: AerosPageHeader(title: 'Orders', actions: actions(2), padding: EdgeInsets.zero)),
        width: 390,
      );
      expect(tester.takeException(), isNull);
    });
  });

  // ───────────────────────────────────────────────────────────── 2
  group('AerosPagination numbered fits its width', () {
    Widget pagination({int page = 6, int total = 12, int max = 5}) => Align(
          alignment: AlignmentDirectional.centerStart,
          child: AerosPagination(
            page: page,
            totalPages: total,
            maxVisiblePages: max,
            variant: AerosPaginationVariant.numbered,
            onChanged: (_) {},
          ),
        );

    List<String> numbers(WidgetTester tester) => [
          for (final text in tester.widgetList<Text>(
            find.descendant(of: find.byType(AerosPagination), matching: find.byType(Text)),
          ))
            text.data!,
        ];

    for (final density in AerosDensity.values) {
      testWidgets('no overflow from 320 up; first, last and current always stay · ${density.name}', (tester) async {
        for (final width in _widths) {
          for (final page in [1, 6, 12]) {
            await _pumpPage(tester, pagination(page: page), width: width, density: density);
            final reason = 'width $width, page $page';
            expect(tester.takeException(), isNull, reason: reason);
            expect(
              tester.getSize(find.byType(AerosPagination)).width,
              lessThanOrEqualTo(width - _gutter * 2),
              reason: reason,
            );
            // Touch at 320 has no room for first … current … last around a middle page
            // (300 of 288): the compact form.
            if (density == AerosDensity.touch && width == 320 && page == 6) {
              expect(numbers(tester), ['$page / 12'], reason: reason);
            } else {
              expect(numbers(tester).toSet(), containsAll({'1', '12', '$page'}), reason: reason);
            }
          }
        }
      });
    }

    testWidgets('the window shrinks with the width and never exceeds maxVisiblePages', (tester) async {
      await _pumpPage(tester, pagination(), width: 1280);
      expect(numbers(tester), ['1', '…', '4', '5', '6', '7', '8', '…', '12']);

      // 390 at touch: arrows are 48 wide, numbers 36 — three in the window do not fit, one does.
      await _pumpPage(tester, pagination(), width: 390);
      expect(numbers(tester), ['1', '…', '6', '…', '12']);

      await _pumpPage(tester, pagination(), width: 390, density: AerosDensity.pointer);
      expect(numbers(tester), ['1', '…', '5', '6', '7', '…', '12']);

      await _pumpPage(tester, pagination(max: 3), width: 1280);
      expect(numbers(tester), ['1', '…', '5', '6', '7', '…', '12']);

      await _pumpPage(tester, pagination(max: 7), width: 1280);
      expect(numbers(tester), ['1', '…', '3', '4', '5', '6', '7', '8', '9', '…', '12']);
    });

    testWidgets('it falls back to the compact form when not even first … current … last fits', (tester) async {
      await _pumpPage(tester, Align(alignment: Alignment.centerLeft, child: SizedBox(width: 200, child: pagination())), width: 390);
      expect(tester.takeException(), isNull);
      expect(numbers(tester), ['6 / 12']);
      expect(find.bySemanticsLabel('Previous page'), findsOneWidget);
      expect(find.bySemanticsLabel('Next page'), findsOneWidget);
    });

    testWidgets('a short list is shown whole where it fits, and compact where it cannot be', (tester) async {
      Widget boxed(double width) => Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(width: width, child: pagination(page: 3, total: 5)),
          );
      // Pointer: arrows and numbers are 28 wide, 4 apart — five numbers need 220.
      await _pumpPage(tester, boxed(220), width: 390, density: AerosDensity.pointer);
      expect(numbers(tester), ['1', '2', '3', '4', '5']);
      await _pumpPage(tester, boxed(219), width: 390, density: AerosDensity.pointer);
      expect(tester.takeException(), isNull);
      expect(numbers(tester), ['3 / 5']);
    });

    testWidgets('given unlimited width (a plain child of a Row) it shows the full window', (tester) async {
      await _pumpPage(
        tester,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            AerosPagination(
              page: 6,
              totalPages: 12,
              variant: AerosPaginationVariant.numbered,
              onChanged: (_) {},
            ),
          ]),
        ),
        width: 320,
      );
      expect(tester.takeException(), isNull);
      expect(numbers(tester), ['1', '…', '4', '5', '6', '7', '8', '…', '12']);
    });

    testWidgets('a shrunk row still pages', (tester) async {
      var page = 6;
      await _pumpPage(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Align(
            alignment: AlignmentDirectional.centerStart,
            child: AerosPagination(
              page: page,
              totalPages: 12,
              variant: AerosPaginationVariant.numbered,
              onChanged: (p) => setState(() => page = p),
            ),
          ),
        ),
        width: 390,
      );
      await tester.tap(find.text('12'));
      await tester.pump();
      expect(page, 12);
      await tester.tap(find.bySemanticsLabel('Previous page'));
      await tester.pump();
      expect(page, 11);
    });
  });

  // ───────────────────────────────────────────────────────────── 3
  group('AerosTabs', () {
    const four = ['Details', 'Line items', 'Invoices', 'Activity'];
    const many = ['Overview', 'Details', 'Line items', 'Invoices', 'Shipments', 'Returns', 'Activity', 'Settings'];

    Rect baseline(WidgetTester tester) {
      const a = AerosAliasColors.light;
      final element = find
          .descendant(of: find.byType(AerosTabs), matching: find.byType(ColoredBox))
          .evaluate()
          .firstWhere((e) => (e.widget as ColoredBox).color == a.borderDefault);
      return tester.getRect(find.byWidget(element.widget));
    }

    for (final density in AerosDensity.values) {
      for (final variant in AerosTabVariant.values) {
        testWidgets('${variant.name}: no overflow from 320 up · ${density.name}', (tester) async {
          for (final width in _widths) {
            for (final tabs in [four, many]) {
              await _pumpPage(
                tester,
                AerosTabs(tabs: tabs, selectedIndex: tabs.length - 1, variant: variant, onChanged: (_) {}),
                width: width,
                density: density,
              );
              final reason = 'width $width, ${tabs.length} tabs';
              expect(tester.takeException(), isNull, reason: reason);
              expect(
                tester.getSize(find.byType(AerosTabs)).width,
                lessThanOrEqualTo(width - _gutter * 2),
                reason: reason,
              );
            }
          }
        });
      }
    }

    testWidgets('underline: the strip and its baseline fill the width, scrolling or not', (tester) async {
      for (final tabs in [four, many]) {
        await _pumpPage(tester, AerosTabs(tabs: tabs, selectedIndex: 0, onChanged: (_) {}), width: 320);
        final strip = tester.getRect(find.byType(AerosTabs));
        expect(strip.width, 320 - _gutter * 2);
        expect(baseline(tester).width, strip.width);
        expect(baseline(tester).bottom, strip.bottom);
        expect(strip.height, AerosSizeTokens.touch.row);
      }
    });

    testWidgets('underline: where the width is unbounded the strip hugs its tabs', (tester) async {
      await _pumpPage(
        tester,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: AerosTabs(tabs: four, selectedIndex: 0, onChanged: (_) {}),
        ),
        width: 1280,
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(AerosTabs)).width, lessThan(600));
    });

    testWidgets('underline: the active tab is in view on first build and after the selection changes',
        (tester) async {
      var selected = many.length - 1;
      late StateSetter rebuild;
      await _pumpPage(
        tester,
        StatefulBuilder(builder: (context, setState) {
          rebuild = setState;
          return AerosTabs(tabs: many, selectedIndex: selected, onChanged: (i) => setState(() => selected = i));
        }),
        width: 320,
      );
      bool inView(String tab) {
        final strip = tester.getRect(find.byType(AerosTabs));
        final rect = tester.getRect(find.text(tab));
        return rect.left >= strip.left && rect.right <= strip.right;
      }

      expect(inView('Settings'), isTrue);
      expect(inView('Overview'), isFalse);

      rebuild(() => selected = 0);
      await tester.pumpAndSettle();
      expect(inView('Overview'), isTrue);
      expect(inView('Settings'), isFalse);

      rebuild(() => selected = 4);
      await tester.pumpAndSettle();
      expect(inView('Shipments'), isTrue);
    });

    testWidgets('underline: tabs that do not fit can be dragged sideways; a clipped edge fades', (tester) async {
      await _pumpPage(tester, AerosTabs(tabs: many, selectedIndex: 0, onChanged: (_) {}), width: 320);
      expect(find.descendant(of: find.byType(AerosTabs), matching: find.byType(ShaderMask)), findsOneWidget);
      final before = tester.getRect(find.text('Details')).left;
      await tester.drag(find.byType(AerosTabs), const Offset(-120, 0));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.text('Details')).left, lessThan(before));

      // Tabs that fit: nothing scrolls, nothing fades.
      await _pumpPage(tester, AerosTabs(tabs: four, selectedIndex: 0, onChanged: (_) {}), width: 1280);
      expect(find.descendant(of: find.byType(AerosTabs), matching: find.byType(ShaderMask)), findsNothing);
    });

    testWidgets('pill: segments that fit keep their own width and the track hugs them', (tester) async {
      await _pumpPage(
        tester,
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AerosTabs(
            tabs: const ['Day', 'Week', 'Month'],
            selectedIndex: 1,
            variant: AerosTabVariant.pill,
            onChanged: (_) {},
          ),
        ),
        width: 390,
      );
      expect(tester.getSize(find.byType(AerosTabs)).width, lessThan(300));
    });

    testWidgets('pill: segments that do not fit share the width equally and truncate', (tester) async {
      await _pumpPage(
        tester,
        AerosTabs(tabs: many, selectedIndex: 2, variant: AerosTabVariant.pill, onChanged: (_) {}),
        width: 320,
      );
      expect(tester.takeException(), isNull);
      final track = tester.getRect(find.byType(AerosTabs));
      expect(track.width, 320 - _gutter * 2);
      final widths = [
        for (final e in find.descendant(of: find.byType(AerosTabs), matching: find.byType(AerosPressable)).evaluate())
          tester.getSize(find.byWidget(e.widget)).width,
      ];
      expect(widths, hasLength(many.length));
      for (final width in widths) {
        expect(width, moreOrLessEquals(widths.first, epsilon: 0.01));
      }
      final total = widths.reduce((a, b) => a + b) + AerosSpacing.s0_5 * (many.length - 1);
      expect(total, lessThanOrEqualTo(track.width));
      expect(tester.widget<Text>(find.text('Line items')).overflow, TextOverflow.ellipsis);
    });

    for (final variant in AerosTabVariant.values) {
      testWidgets('${variant.name}: arrow keys move the focus with the selection (roving focus)', (tester) async {
        var selected = 0;
        await _pumpPage(
          tester,
          StatefulBuilder(
            builder: (context, setState) => AerosTabs(
              tabs: four,
              selectedIndex: selected,
              variant: variant,
              onChanged: (i) => setState(() => selected = i),
            ),
          ),
          width: 768,
          density: AerosDensity.pointer,
        );
        bool ringOn(String tab) => tester
            .widget<AerosFocusRing>(find.ancestor(of: find.text(tab), matching: find.byType(AerosFocusRing)).first)
            .focused;
        List<String> ringed() => [
              for (final tab in four)
                if (ringOn(tab)) tab,
            ];

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(ringed(), ['Details']);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        expect(selected, 1);
        expect(ringed(), ['Line items']);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        expect(selected, 2);
        expect(ringed(), ['Invoices']);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pump();
        expect(selected, 1);
        expect(ringed(), ['Line items']);

        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pump();
        expect(selected, 3);
        expect(ringed(), ['Activity']);

        // At the end: the selection stays, and so does the focus.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        expect(selected, 3);
        expect(ringed(), ['Activity']);

        await tester.sendKeyEvent(LogicalKeyboardKey.home);
        await tester.pump();
        expect(selected, 0);
        expect(ringed(), ['Details']);

        // Enter on the focused tab still activates it.
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(selected, 0);
      });
    }

    testWidgets('roving focus scrolls the newly selected tab into view', (tester) async {
      var selected = 0;
      await _pumpPage(
        tester,
        StatefulBuilder(
          builder: (context, setState) => AerosTabs(
            tabs: many,
            selectedIndex: selected,
            onChanged: (i) => setState(() => selected = i),
          ),
        ),
        width: 320,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(selected, many.length - 1);
      final strip = tester.getRect(find.byType(AerosTabs));
      final last = tester.getRect(find.text('Settings'));
      expect(last.right, lessThanOrEqualTo(strip.right));
      expect(last.left, greaterThanOrEqualTo(strip.left));
    });

    testWidgets('the number of tabs can change', (tester) async {
      var tabs = four;
      late StateSetter rebuild;
      await _pumpPage(
        tester,
        StatefulBuilder(builder: (context, setState) {
          rebuild = setState;
          return AerosTabs(tabs: tabs, selectedIndex: 0, onChanged: (_) {});
        }),
        width: 390,
      );
      rebuild(() => tabs = many);
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
      rebuild(() => tabs = const ['One', 'Two']);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Two'), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────────────────── 4
  group('AerosScaffold scope and the automatic top bar button', () {
    Future<AerosScaffoldState Function()> pumpShell(
      WidgetTester tester, {
      required Size size,
      AerosDensity density = AerosDensity.touch,
      AerosTopnav topnav = const AerosTopnav(title: 'Orders'),
      bool withSidenav = true,
      bool collapsed = false,
      ValueChanged<bool>? onRailCollapsedChanged,
      GlobalKey<AerosScaffoldState>? shellKey,
      VoidCallback? onNavTap,
    }) async {
      _setView(tester, size);
      late BuildContext body;
      await tester.pumpWidget(MaterialApp(
        theme: AerosTheme.light(),
        home: AerosDensityScope(
          density: density,
          child: AerosScaffold(
            key: shellKey,
            topnav: topnav,
            onRailCollapsedChanged: onRailCollapsedChanged,
            sidenav: withSidenav ? AerosSidenav(collapsed: collapsed, items: _navItems(onTap: onNavTap)) : null,
            body: Builder(builder: (context) {
              body = context;
              final shell = AerosScaffold.of(context);
              return Text('inline ${shell.isSidenavInline} · open ${shell.isDrawerOpen} · rail ${shell.isRailCollapsed}');
            }),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      return () => AerosScaffold.of(body);
    }

    const phone = Size(390, 844);
    const desktop = Size(1280, 800);

    testWidgets('phone: the sidenav is in a drawer and the bar shows a named menu button', (tester) async {
      final handle = tester.ensureSemantics();
      final shell = await pumpShell(tester, size: phone);
      expect(shell().hasSidenav, isTrue);
      expect(shell().isSidenavInline, isFalse);
      expect(shell().isSidenavInDrawer, isTrue);
      expect(shell().isDrawerOpen, isFalse);
      expect(shell().isRailCollapsed, isFalse);
      expect(find.text('inline false · open false · rail false'), findsOneWidget);

      final menu = find.bySemanticsLabel('Open navigation');
      expect(menu, findsOneWidget);
      expect(
        tester.getSemantics(menu),
        // ignore: deprecated_member_use
        containsSemantics(isButton: true, isEnabled: true, hasTapAction: true),
      );
      // Leading: before the title.
      expect(tester.getRect(find.byType(AerosButton)).right, lessThan(tester.getRect(find.text('Orders')).left));
      // At least the minimum target for fingers.
      final target = tester.getSize(find.descendant(of: find.byType(AerosTopnav), matching: find.byType(AerosPressable)));
      expect(target.width, greaterThanOrEqualTo(AerosSizeTokens.touch.minTarget));
      expect(target.height, greaterThanOrEqualTo(AerosSizeTokens.touch.minTarget));
      expect(AerosSizeTokens.touch.minTarget, 48);
      handle.dispose();
    });

    testWidgets('phone: the menu button opens the drawer; dependents hear about it; closeDrawer closes it',
        (tester) async {
      final changes = <bool>[];
      _setView(tester, phone);
      final key = GlobalKey<AerosScaffoldState>();
      await tester.pumpWidget(MaterialApp(
        theme: AerosTheme.light(),
        home: AerosScaffold(
          key: key,
          onDrawerChanged: changes.add,
          topnav: const AerosTopnav(title: 'Orders'),
          sidenav: AerosSidenav(items: _navItems(onTap: () => key.currentState!.closeDrawer())),
          body: Builder(builder: (context) => Text('open ${AerosScaffold.of(context).isDrawerOpen}')),
        ),
      ));
      expect(find.byType(AerosSidenav), findsNothing);

      await tester.tap(find.bySemanticsLabel('Open navigation'));
      await tester.pumpAndSettle();
      expect(find.byType(AerosSidenav), findsOneWidget);
      expect(key.currentState!.isDrawerOpen, isTrue);
      expect(find.text('open true'), findsOneWidget);
      expect(changes, [true]);

      // A nav row that closes the drawer through the scaffold.
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(AerosSidenav), findsNothing);
      expect(key.currentState!.isDrawerOpen, isFalse);
      expect(find.text('open false'), findsOneWidget);
      expect(changes, [true, false]);

      key.currentState!.toggleDrawer();
      await tester.pumpAndSettle();
      expect(key.currentState!.isDrawerOpen, isTrue);
      key.currentState!.toggleDrawer();
      await tester.pumpAndSettle();
      expect(key.currentState!.isDrawerOpen, isFalse);

      key.currentState!.openDrawer();
      await tester.pumpAndSettle();
      expect(find.byType(AerosSidenav), findsOneWidget);
      // Closing a closed drawer, or closing twice, is harmless.
      key.currentState!.closeDrawer();
      key.currentState!.closeDrawer();
      await tester.pumpAndSettle();
      expect(find.byType(AerosSidenav), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('phone: a leading of its own, or the opt-out, leaves no automatic button', (tester) async {
      await pumpShell(
        tester,
        size: phone,
        topnav: const AerosTopnav(title: 'Orders', leading: Icon(Icons.arrow_back)),
      );
      expect(find.bySemanticsLabel('Open navigation'), findsNothing);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      await pumpShell(tester, size: phone, topnav: const AerosTopnav(title: 'Orders', automaticallyImplyLeading: false));
      expect(find.bySemanticsLabel('Open navigation'), findsNothing);
      expect(find.byType(AerosButton), findsNothing);

      await pumpShell(
        tester,
        size: phone,
        topnav: const AerosTopnav(title: 'Orders', openNavigationLabel: 'Menü öffnen'),
      );
      expect(find.bySemanticsLabel('Menü öffnen'), findsOneWidget);
    });

    testWidgets('no sidenav: no button, and nothing to open', (tester) async {
      final shell = await pumpShell(tester, size: phone, withSidenav: false);
      expect(find.byType(AerosButton), findsNothing);
      expect(shell().hasSidenav, isFalse);
      expect(shell().isSidenavInline, isFalse);
      expect(shell().isSidenavInDrawer, isFalse);
      shell().openDrawer();
      shell().toggleRail();
      await tester.pumpAndSettle();
      expect(shell().isDrawerOpen, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('desktop: the sidenav is inline; without a rail callback the bar shows no button', (tester) async {
      final shell = await pumpShell(tester, size: desktop, density: AerosDensity.pointer);
      expect(shell().isSidenavInline, isTrue);
      expect(shell().isSidenavInDrawer, isFalse);
      expect(shell().canToggleRail, isFalse);
      expect(find.byType(Drawer), findsNothing);
      expect(find.descendant(of: find.byType(AerosTopnav), matching: find.byType(AerosButton)), findsNothing);
      // Opening a drawer that does not exist does nothing.
      shell().openDrawer();
      await tester.pumpAndSettle();
      expect(shell().isDrawerOpen, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('desktop: the app owns the rail; the bar toggles it through onRailCollapsedChanged', (tester) async {
      _setView(tester, desktop);
      var collapsed = false;
      final asked = <bool>[];
      final key = GlobalKey<AerosScaffoldState>();
      await tester.pumpWidget(MaterialApp(
        theme: AerosTheme.light(),
        home: StatefulBuilder(
          builder: (context, setState) => AerosScaffold(
            key: key,
            onRailCollapsedChanged: (value) {
              asked.add(value);
              setState(() => collapsed = value);
            },
            topnav: const AerosTopnav(title: 'Orders'),
            sidenav: AerosSidenav(collapsed: collapsed, items: _navItems()),
            body: Builder(builder: (context) => Text('rail ${AerosScaffold.of(context).isRailCollapsed}')),
          ),
        ),
      ));
      expect(key.currentState!.canToggleRail, isTrue);
      expect(find.text('rail false'), findsOneWidget);
      expect(find.bySemanticsLabel('Open navigation'), findsNothing);

      await tester.tap(find.bySemanticsLabel('Collapse sidebar'));
      await tester.pumpAndSettle();
      expect(asked, [true]);
      expect(key.currentState!.isRailCollapsed, isTrue);
      expect(find.text('rail true'), findsOneWidget);
      expect(
        tester.getSize(find.byType(AerosSidenav)).width,
        AerosMetricTokens.layoutSidebarRail - AerosMetricTokens.borderHairline,
      );

      await tester.tap(find.bySemanticsLabel('Expand sidebar'));
      await tester.pumpAndSettle();
      expect(asked, [true, false]);
      expect(find.text('rail false'), findsOneWidget);

      key.currentState!.toggleRail();
      await tester.pumpAndSettle();
      expect(asked, [true, false, true]);
    });

    testWidgets('resizing across the breakpoint swaps the button and tells dependents', (tester) async {
      final shell = await pumpShell(tester, size: phone, onRailCollapsedChanged: (_) {});
      expect(find.bySemanticsLabel('Open navigation'), findsOneWidget);
      shell().openDrawer();
      await tester.pumpAndSettle();
      expect(shell().isDrawerOpen, isTrue);

      tester.view.physicalSize = desktop;
      await tester.pumpAndSettle();
      expect(shell().isSidenavInline, isTrue);
      expect(shell().isDrawerOpen, isFalse);
      expect(find.text('inline true · open false · rail false'), findsOneWidget);
      expect(find.bySemanticsLabel('Open navigation'), findsNothing);
      expect(find.bySemanticsLabel('Collapse sidebar'), findsOneWidget);
    });

    testWidgets('a collapsed sidenav in the drawer is not a rail', (tester) async {
      final shell = await pumpShell(tester, size: phone, collapsed: true);
      expect(shell().isRailCollapsed, isFalse);
    });

    testWidgets('of() throws outside a scaffold; maybeOf() is null; a bar outside one has no button', (tester) async {
      late BuildContext outside;
      await tester.pumpWidget(MaterialApp(
        theme: AerosTheme.light(),
        home: Scaffold(
          body: Column(children: [
            const AerosTopnav(title: 'Orders'),
            Builder(builder: (context) {
              outside = context;
              return const SizedBox();
            }),
          ]),
        ),
      ));
      expect(AerosScaffold.maybeOf(outside), isNull);
      expect(() => AerosScaffold.of(outside), throwsFlutterError);
      expect(find.byType(AerosButton), findsNothing);
    });
  });

  // ───────────────────────────────────────────────────────────── 5
  group('AerosSidenavHeader.custom and AerosSidenavScope', () {
    Widget brand() => Builder(
          builder: (context) => AerosSidenavScope.of(context).collapsed
              ? const AerosSidenavMark(letter: 'a')
              : const AerosWordmark(size: 20),
        );

    Widget rail({required bool collapsed, Widget? header, VoidCallback? onTap, String? semanticLabel}) => MaterialApp(
          theme: AerosTheme.light(),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: collapsed ? AerosMetricTokens.layoutSidebarRail : AerosMetricTokens.layoutSidebar,
                height: 400,
                child: AerosSidenav(
                  collapsed: collapsed,
                  header: header ??
                      AerosSidenavHeader.custom(semanticLabel: semanticLabel, onTap: onTap, child: brand()),
                  items: _navItems(),
                ),
              ),
            ),
          ),
        );

    testWidgets('the custom header holds the wordmark, on the rail\'s leading edge, one header high',
        (tester) async {
      await tester.pumpWidget(rail(collapsed: false));
      expect(find.byType(AerosWordmark), findsOneWidget);
      expect(find.byType(AerosSidenavMark), findsNothing);
      final header = tester.getRect(find.byType(AerosSidenavHeader));
      expect(header.height, AerosSizeTokens.touch.header);
      // 20px in, like every icon in the rail.
      expect(tester.getRect(find.byType(AerosWordmark)).left, AerosSpacing.s3 + AerosSpacing.s2);
      expect(tester.getRect(find.byType(AerosWordmark)).left, tester.getRect(find.byIcon(Icons.home_outlined)).left);
      expect(tester.takeException(), isNull);
    });

    testWidgets('collapsed, the scope says so and the header switches to the mark, centred', (tester) async {
      await tester.pumpWidget(rail(collapsed: true));
      expect(find.byType(AerosWordmark), findsNothing);
      final mark = tester.getRect(find.byType(AerosSidenavMark));
      final header = tester.getRect(find.byType(AerosSidenavHeader));
      expect(mark.center.dx, moreOrLessEquals(header.center.dx, epsilon: 0.5));
      expect(tester.takeException(), isNull);
    });

    testWidgets('the scope follows the rail and reports the density; outside a sidenav it is absent',
        (tester) async {
      final seen = <bool>[];
      Widget probe() => Builder(builder: (context) {
            final scope = AerosSidenavScope.of(context);
            seen.add(scope.collapsed);
            expect(scope.density, AerosSidenavDensity.pointer);
            return const SizedBox();
          });
      await tester.pumpWidget(rail(collapsed: false, header: AerosSidenavHeader.custom(child: probe())));
      await tester.pumpWidget(rail(collapsed: true, header: AerosSidenavHeader.custom(child: probe())));
      expect(seen, [false, true]);

      late BuildContext outside;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          outside = context;
          return const SizedBox();
        }),
      ));
      expect(AerosSidenavScope.maybeOf(outside), isNull);
      expect(() => AerosSidenavScope.of(outside), throwsFlutterError);
    });

    testWidgets('inside the scaffold\'s drawer the scope is never collapsed', (tester) async {
      _setView(tester, const Size(390, 844));
      final key = GlobalKey<AerosScaffoldState>();
      await tester.pumpWidget(MaterialApp(
        theme: AerosTheme.light(),
        home: AerosScaffold(
          key: key,
          sidenav: AerosSidenav(
            collapsed: true,
            header: AerosSidenavHeader.custom(child: brand()),
            items: _navItems(),
          ),
          body: const SizedBox(),
        ),
      ));
      key.currentState!.openDrawer();
      await tester.pumpAndSettle();
      expect(find.byType(AerosWordmark), findsOneWidget);
      expect(find.byType(AerosSidenavMark), findsNothing);
    });

    testWidgets('semantics: a label replaces the child; with onTap the block is one button', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(rail(collapsed: false, semanticLabel: 'Aeros Design System'));
      expect(find.bySemanticsLabel('Aeros Design System'), findsOneWidget);

      var taps = 0;
      await tester.pumpWidget(rail(collapsed: false, semanticLabel: 'Switch workspace', onTap: () => taps++));
      expect(
        tester.getSemantics(find.bySemanticsLabel('Switch workspace')),
        // ignore: deprecated_member_use
        containsSemantics(isButton: true, hasTapAction: true),
      );
      await tester.tap(find.byType(AerosWordmark));
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('the String constructor is unchanged', (tester) async {
      await tester.pumpWidget(rail(
        collapsed: false,
        header: const AerosSidenavHeader(title: 'Boson Machines', subtitle: 'Seller workspace'),
      ));
      expect(find.text('Boson Machines'), findsOneWidget);
      expect(find.text('Seller workspace'), findsOneWidget);
      expect(find.byType(AerosSidenavMark), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────────────────── 6
  group('AerosButton named constructors', () {
    final constructors = <AerosButtonVariant,
        AerosButton Function({
      Key? key,
      required String label,
      required VoidCallback? onPressed,
      AerosControlSize? size,
      Widget? leading,
      Widget? trailing,
      bool loading,
      bool fullWidth,
      String? semanticLabel,
    })>{
      AerosButtonVariant.primary: AerosButton.primary,
      AerosButtonVariant.secondary: AerosButton.secondary,
      AerosButtonVariant.ghost: AerosButton.ghost,
      AerosButtonVariant.danger: AerosButton.danger,
      AerosButtonVariant.dangerSubtle: AerosButton.dangerSubtle,
      AerosButtonVariant.link: AerosButton.link,
    };

    test('there is one per variant', () {
      expect(constructors.keys.toSet(), AerosButtonVariant.values.toSet());
    });

    for (final entry in constructors.entries) {
      testWidgets('.${entry.key.name} takes every option of the default constructor', (tester) async {
        void onPressed() {}
        const key = ValueKey('b');
        const leading = Icon(Icons.add);
        const trailing = Icon(Icons.arrow_forward);
        final button = entry.value(
          key: key,
          label: 'Go',
          onPressed: onPressed,
          size: AerosControlSize.lg,
          leading: leading,
          trailing: trailing,
          loading: true,
          fullWidth: true,
          semanticLabel: 'Go to orders',
        );
        expect(button.key, key);
        expect(button.variant, entry.key);
        expect(button.label, 'Go');
        expect(button.onPressed, onPressed);
        expect(button.size, AerosControlSize.lg);
        expect(button.leading, same(leading));
        expect(button.trailing, same(trailing));
        expect(button.loading, isTrue);
        expect(button.fullWidth, isTrue);
        expect(button.semanticLabel, 'Go to orders');

        // Defaults match the default constructor's.
        final plain = entry.value(label: 'Go', onPressed: onPressed);
        expect((plain.size, plain.leading, plain.trailing, plain.loading, plain.fullWidth, plain.semanticLabel),
            (null, null, null, false, false, null));

        // And it lays out with both icons.
        await tester.pumpWidget(MaterialApp(
          theme: AerosTheme.light(),
          home: Scaffold(
            body: Center(child: entry.value(label: 'Go', onPressed: onPressed, leading: leading, trailing: trailing)),
          ),
        ));
        final label = tester.getRect(find.text('Go'));
        expect(tester.getRect(find.byIcon(Icons.add)).right, lessThanOrEqualTo(label.left));
        expect(tester.getRect(find.byIcon(Icons.arrow_forward)).left, greaterThanOrEqualTo(label.right));
      });
    }

    testWidgets('semanticLabel is announced in place of the visible label, once', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(MaterialApp(
        theme: AerosTheme.light(),
        home: Scaffold(
          body: Center(child: AerosButton(label: 'Delete', semanticLabel: 'Delete order 4821', onPressed: () {})),
        ),
      ));
      expect(find.text('Delete'), findsOneWidget);
      final node = tester.getSemantics(find.byType(AerosButton));
      expect(node.label, 'Delete order 4821');
      // ignore: deprecated_member_use
      expect(node, containsSemantics(isButton: true, hasTapAction: true));

      await tester.pumpWidget(MaterialApp(
        theme: AerosTheme.light(),
        home: Scaffold(
          body: Center(
            child: AerosButton(label: 'Delete', semanticLabel: 'Delete order 4821', loading: true, onPressed: () {}),
          ),
        ),
      ));
      expect(tester.getSemantics(find.byType(AerosButton)).label, 'Delete order 4821, loading');

      // Without one, the visible label is what is read.
      await tester.pumpWidget(MaterialApp(
        theme: AerosTheme.light(),
        home: Scaffold(body: Center(child: AerosButton(label: 'Delete', onPressed: () {}))),
      ));
      expect(tester.getSemantics(find.byType(AerosButton)).label, 'Delete');
      handle.dispose();
    });
  });

  // ───────────────────────────────────────────────────────────── 7
  group('AerosResponsiveGrid.auto', () {
    Widget tile(String key, double height) => SizedBox(key: ValueKey(key), height: height);

    testWidgets('rows are as tall as their tallest tile; tiles keep their own height', (tester) async {
      await _pumpPage(
        tester,
        AerosResponsiveGrid.auto(
          crossAxisCount: const AerosResponsiveValue.all(2),
          children: [tile('a', 40), tile('b', 120), tile('c', 60), tile('d', 30), tile('e', 50)],
        ),
        width: 432,
      );
      Rect rect(String key) => tester.getRect(find.byKey(ValueKey(key)));
      const column = (400 - AerosSpacing.s3) / 2;
      expect(rect('a').size, const Size(column, 40));
      expect(rect('b').size, const Size(column, 120));
      expect(rect('b').left, rect('a').right + AerosSpacing.s3);
      expect(rect('b').top, rect('a').top);
      // The second row starts under the tallest tile of the first.
      expect(rect('c').top, rect('b').bottom + AerosSpacing.s3);
      expect(rect('d').top, rect('c').top);
      // A last row with one tile keeps the column width.
      expect(rect('e').top, rect('c').bottom + AerosSpacing.s3);
      expect(rect('e').width, column);
      expect(tester.getSize(find.byType(AerosResponsiveGrid)).height, 120 + 60 + 50 + AerosSpacing.s3 * 2);
    });

    testWidgets('equalHeights stretches the tiles of a row to the tallest', (tester) async {
      await _pumpPage(
        tester,
        const AerosResponsiveGrid.auto(
          crossAxisCount: AerosResponsiveValue.all(3),
          equalHeights: true,
          children: [
            AerosStatCard(label: 'Orders', value: '128', delta: '12%', deltaDirection: AerosDelta.up),
            AerosStatCard(label: 'Lead time', value: '5.2 days'),
            AerosCard(child: SizedBox(height: 140)),
          ],
        ),
        width: 1280,
      );
      final heights = [
        ...tester.widgetList<AerosStatCard>(find.byType(AerosStatCard)).map((w) => tester.getSize(find.byWidget(w)).height),
        tester.getSize(find.byType(AerosCard)).height,
      ];
      expect(heights.toSet(), hasLength(1));
      expect(heights.first, greaterThanOrEqualTo(140));
    });

    testWidgets('tileMinWidth: as many columns as fit, never more than there are tiles', (tester) async {
      Future<List<double>> lefts(double width, int count) async {
        await _pumpPage(
          tester,
          AerosResponsiveGrid.auto(
            tileMinWidth: 200,
            children: [for (var i = 0; i < count; i++) tile('$i', 40)],
          ),
          width: width,
        );
        expect(tester.takeException(), isNull);
        return {
          for (var i = 0; i < count; i++) tester.getRect(find.byKey(ValueKey('$i'))).left,
        }.toList();
      }

      expect(await lefts(320, 6), hasLength(1));
      expect(await lefts(390, 6), hasLength(1));
      // 736 wide: three 200s and two gaps fit (624), four do not (836).
      expect(await lefts(768, 6), hasLength(3));
      expect(await lefts(1280, 6), hasLength(5));
      // Two tiles on a wide page share it, rather than leaving empty columns.
      expect(await lefts(1280, 2), hasLength(2));
      expect(tester.getSize(find.byKey(const ValueKey('0'))).width, (1280 - _gutter * 2 - AerosSpacing.s3) / 2);
      for (final width in _widths) {
        await lefts(width, 6);
        for (var i = 0; i < 6; i++) {
          expect(tester.getSize(find.byKey(ValueKey('$i'))).width, greaterThanOrEqualTo(200));
        }
      }
    });

    testWidgets('padding and an empty list', (tester) async {
      await _pumpPage(
        tester,
        AerosResponsiveGrid.auto(
          tileMinWidth: 100,
          padding: const EdgeInsets.all(AerosSpacing.s4),
          children: [tile('a', 40)],
        ),
        width: 390,
      );
      expect(tester.getSize(find.byType(AerosResponsiveGrid)).height, 40 + AerosSpacing.s4 * 2);
      await _pumpPage(tester, const AerosResponsiveGrid.auto(tileMinWidth: 100, children: []), width: 390);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the default constructor still forces an aspect ratio (1.0 when not given)', (tester) async {
      await _pumpPage(
        tester,
        AerosResponsiveGrid(
          crossAxisCount: const AerosResponsiveValue.all(2),
          children: [tile('a', 10), tile('b', 10)],
        ),
        width: 432,
      );
      final size = tester.getSize(find.byKey(const ValueKey('a')));
      expect(size.width, size.height);
    });
  });

  // ───────────────────────────────────────────────────────────── 8
  group('field naming: helperText / errorText everywhere', () {
    const items = [
      AerosSelectItem(value: 'kraft', label: 'Kraft'),
      AerosSelectItem(value: 'white', label: 'White board'),
    ];

    testWidgets('AerosSelect shows helperText, and errorText in its place with the danger frame', (tester) async {
      await _pumpPage(
        tester,
        AerosSelect<String>(
          label: 'Material',
          required: true,
          helperText: 'Shown on the quote',
          items: items,
          value: null,
          onChanged: (_) {},
        ),
        width: 390,
      );
      expect(find.text('Shown on the quote'), findsOneWidget);
      expect(tester.widget<AerosFieldFrame>(find.byType(AerosFieldFrame)).hasError, isFalse);

      await _pumpPage(
        tester,
        AerosSelect<String>(
          label: 'Material',
          helperText: 'Shown on the quote',
          errorText: 'Choose a material',
          items: items,
          value: null,
          onChanged: (_) {},
        ),
        width: 390,
      );
      expect(find.text('Shown on the quote'), findsNothing);
      expect(find.text('Choose a material'), findsOneWidget);
      expect(tester.widget<AerosFieldFrame>(find.byType(AerosFieldFrame)).hasError, isTrue);
      expect(
        tester.widget<Text>(find.text('Choose a material')).style!.color,
        AerosSemanticColors.light.dangerText,
      );
      // Under the field.
      expect(
        tester.getRect(find.text('Choose a material')).top,
        greaterThanOrEqualTo(tester.getRect(find.byType(AerosFieldFrame)).bottom),
      );
    });

    testWidgets('AerosSelect: the deprecated helper / error still work; the new names win', (tester) async {
      await _pumpPage(
        tester,
        // ignore: deprecated_member_use_from_same_package
        AerosSelect<String>(helper: 'Old helper', items: items, value: null, onChanged: (_) {}),
        width: 390,
      );
      expect(find.text('Old helper'), findsOneWidget);

      await _pumpPage(
        tester,
        // ignore: deprecated_member_use_from_same_package
        AerosSelect<String>(error: 'Old error', items: items, value: null, onChanged: (_) {}),
        width: 390,
      );
      expect(find.text('Old error'), findsOneWidget);
      expect(tester.widget<AerosFieldFrame>(find.byType(AerosFieldFrame)).hasError, isTrue);

      await _pumpPage(
        tester,
        AerosSelect<String>(
          // ignore: deprecated_member_use_from_same_package
          helper: 'Old helper',
          helperText: 'New helper',
          // ignore: deprecated_member_use_from_same_package
          error: 'Old error',
          errorText: 'New error',
          items: items,
          value: null,
          onChanged: (_) {},
        ),
        width: 390,
      );
      expect(find.text('New error'), findsOneWidget);
      expect(find.text('Old error'), findsNothing);
    });

    Widget dropdown({String? label = 'City', String? helperText, String? errorText, bool required = false}) =>
        AerosDropdownSearch<String>(
          label: label,
          helperText: helperText,
          errorText: errorText,
          required: required,
          hint: 'Select a city',
          items: const ['Ahmedabad', 'Pune'],
          itemAsString: (city) => city,
          onChanged: (_) {},
        );

    testWidgets('AerosDropdownSearch has label, required, helperText and errorText like the other fields',
        (tester) async {
      await _pumpPage(tester, dropdown(helperText: 'Where it ships from', required: true), width: 390);
      expect(find.byType(AerosFormField), findsOneWidget);
      final form = tester.widget<AerosFormField>(find.byType(AerosFormField));
      expect((form.label, form.required, form.helperText, form.errorText), ('City', true, 'Where it ships from', null));
      expect(find.text('Where it ships from'), findsOneWidget);
      expect(tester.widget<AerosFieldFrame>(find.byType(AerosFieldFrame)).hasError, isFalse);

      await _pumpPage(
        tester,
        dropdown(helperText: 'Where it ships from', errorText: 'Choose a city'),
        width: 390,
      );
      expect(find.text('Where it ships from'), findsNothing);
      expect(find.text('Choose a city'), findsOneWidget);
      expect(tester.widget<AerosFieldFrame>(find.byType(AerosFieldFrame)).hasError, isTrue);
      expect(
        tester.getRect(find.text('Choose a city')).top,
        greaterThanOrEqualTo(tester.getRect(find.byType(AerosFieldFrame)).bottom),
      );

      // Helper or error without a label still shows.
      await _pumpPage(tester, dropdown(label: null, errorText: 'Choose a city'), width: 390);
      expect(find.text('Choose a city'), findsOneWidget);
      // Nothing to add: the bare field, as before.
      await _pumpPage(tester, dropdown(label: null), width: 390);
      expect(find.byType(AerosFormField), findsNothing);
    });

    testWidgets('semantics: the trigger is a named button and the message under it is read', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpPage(tester, dropdown(errorText: 'Choose a city'), width: 390);
      expect(
        tester.getSemantics(find.byType(AerosFieldFrame)),
        // ignore: deprecated_member_use
        containsSemantics(isButton: true, hasTapAction: true, isFocusable: true),
      );
      expect(tester.getSemantics(find.byType(AerosFieldFrame)).label, contains('City'));
      expect(find.bySemanticsLabel('Choose a city'), findsOneWidget);

      await _pumpPage(
        tester,
        AerosSelect<String>(
          label: 'Material',
          errorText: 'Choose a material',
          items: items,
          value: 'kraft',
          onChanged: (_) {},
        ),
        width: 390,
      );
      final select = tester.getSemantics(find.byType(AerosFieldFrame));
      // ignore: deprecated_member_use
      expect(select, containsSemantics(isButton: true, hasTapAction: true));
      expect(select.label, allOf(contains('Material'), contains('Kraft')));
      expect(find.bySemanticsLabel('Choose a material'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('AerosEnumChips draws its label and error through AerosFormField, and still hugs its chips',
        (tester) async {
      const options = [
        AerosAttributeOption(id: 'a', label: 'Kraft'),
        AerosAttributeOption(id: 'b', label: 'White'),
      ];
      await _pumpPage(
        tester,
        // Unbounded width: a Row gives its plain children all the room they ask for.
        Row(children: [
          AerosEnumChips(
            label: 'Board',
            required: true,
            errorText: 'Pick one',
            options: options,
            selectedId: null,
            onChanged: (_) {},
          ),
        ]),
        width: 390,
      );
      expect(tester.takeException(), isNull);
      final form = tester.widget<AerosFormField>(find.byType(AerosFormField));
      expect((form.label, form.required, form.errorText, form.expand), ('Board', true, 'Pick one', false));
      expect(find.text('Pick one'), findsOneWidget);
      expect(tester.getSize(find.byType(AerosEnumChips)).width, lessThan(300));
    });

    testWidgets('AerosFormField: expand false hugs its content; the default fills the width', (tester) async {
      await _pumpPage(
        tester,
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AerosFormField(label: 'Board', expand: false, child: SizedBox(width: 120, height: 20)),
          AerosFormField(label: 'Board', child: SizedBox(height: 20)),
        ]),
        width: 390,
      );
      expect(tester.getSize(find.byType(AerosFormField).first).width, 120);
      expect(tester.getSize(find.byType(AerosFormField).last).width, 390 - _gutter * 2);
    });
  });

  // ───────────────────────────────────────────────────────────── 9
  group('AerosAmountFormat', () {
    test('thousands grouping', () {
      expect(AerosAmountFormat.group(0), '0.00');
      expect(AerosAmountFormat.group(999), '999.00');
      expect(AerosAmountFormat.group(1000), '1,000.00');
      expect(AerosAmountFormat.group(6675), '6,675.00');
      expect(AerosAmountFormat.group(1234567.891), '1,234,567.89');
      expect(AerosAmountFormat.group(1234567, fractionDigits: 0), '1,234,567');
      expect(AerosAmountFormat.group(999.999), '1,000.00');
    });

    test('Indian grouping: thousand, lakh, crore', () {
      String indian(num value) => AerosAmountFormat.group(value, grouping: AerosDigitGrouping.indian);
      expect(indian(999), '999.00');
      expect(indian(6675), '6,675.00');
      expect(indian(99999), '99,999.00');
      expect(indian(100000), '1,00,000.00'); // one lakh
      expect(indian(1234567.5), '12,34,567.50');
      expect(indian(10000000), '1,00,00,000.00'); // one crore
      expect(indian(1234567890), '1,23,45,67,890.00');
    });

    test('no grouping', () {
      expect(AerosAmountFormat.group(1234567, grouping: AerosDigitGrouping.none), '1234567.00');
    });

    test('negative and zero', () {
      expect(AerosAmountFormat.group(-1234.5), '−1,234.50');
      expect(AerosAmountFormat.group(-1234.5, minus: '-'), '-1,234.50');
      expect(AerosAmountFormat.group(-0.001), '0.00');
      expect(AerosAmountFormat.group(-0.0), '0.00');
    });

    test('money: the rupee groups the Indian way, everything else in thousands', () {
      expect(AerosAmountFormat.money(6675, currencySymbol: '₹'), '₹6,675.00');
      expect(AerosAmountFormat.money(1234567, currencySymbol: '₹'), '₹12,34,567.00');
      expect(AerosAmountFormat.money(1234567, currencySymbol: 'Rs. '), 'Rs. 12,34,567.00');
      expect(AerosAmountFormat.money(1234567, currencySymbol: 'INR '), 'INR 12,34,567.00');
      expect(AerosAmountFormat.money(1234567, currencySymbol: r'$'), r'$1,234,567.00');
      expect(AerosAmountFormat.money(1234567, currencySymbol: '€'), '€1,234,567.00');
      expect(AerosAmountFormat.money(0, currencySymbol: '₹'), '₹0.00');
      expect(AerosAmountFormat.money(-250000, currencySymbol: '₹'), '−₹2,50,000.00');
      expect(AerosAmountFormat.money(-250000, currencySymbol: r'$'), r'−$250,000.00');
      expect(AerosAmountFormat.money(-0.004, currencySymbol: '₹'), '₹0.00');
      expect(
        AerosAmountFormat.money(1234567, currencySymbol: '₹', grouping: AerosDigitGrouping.thousands),
        '₹1,234,567.00',
      );
      expect(AerosAmountFormat.groupingFor('₹'), AerosDigitGrouping.indian);
      expect(AerosAmountFormat.groupingFor(r'$'), AerosDigitGrouping.thousands);
    });
  });

  group('AerosPriceBreakdown amounts', () {
    AerosPriceBreakdownData data(String symbol) => AerosPriceBreakdownData(
          currencySymbol: symbol,
          discountableSubtotal: 1250000,
          nonDiscountableSubtotal: 0,
          total: 1187500,
          steps: const [
            AerosBreakdownStep(name: 'Base price', kind: 'BASE_PRICE', amount: 6675),
            AerosBreakdownStep(name: 'Volume discount', kind: 'DISCOUNT', amount: -62500),
            AerosBreakdownStep(name: 'Free sample', kind: 'MODIFIER', amount: 0),
          ],
        );

    testWidgets('rupees are grouped the Indian way by default', (tester) async {
      await _pumpPage(tester, AerosPriceBreakdown(data: data('₹'), initiallyExpanded: true), width: 390);
      expect(find.text('₹6,675.00'), findsOneWidget);
      expect(find.text('₹6675.00'), findsNothing);
      expect(find.text('₹12,50,000.00'), findsOneWidget); // subtotal
      expect(find.text('₹11,87,500.00'), findsNWidgets(2)); // header and total row
      expect(find.text('−₹62,500.00'), findsOneWidget);
      expect(find.text('₹0.00'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('other currencies group in thousands', (tester) async {
      await _pumpPage(tester, AerosPriceBreakdown(data: data(r'$'), initiallyExpanded: true), width: 390);
      expect(find.text(r'$1,250,000.00'), findsOneWidget);
      expect(find.text(r'$1,187,500.00'), findsNWidgets(2));
      expect(find.text(r'−$62,500.00'), findsOneWidget);
    });

    testWidgets('formatAmount replaces the default everywhere', (tester) async {
      await _pumpPage(
        tester,
        AerosPriceBreakdown(
          data: data('₹'),
          initiallyExpanded: true,
          formatAmount: (amount) => '${amount.round()} INR',
        ),
        width: 390,
      );
      expect(find.text('6675 INR'), findsOneWidget);
      expect(find.text('1187500 INR'), findsNWidgets(2));
      expect(find.text('-62500 INR'), findsOneWidget);
      expect(find.textContaining('₹'), findsNothing);
    });
  });

  group('small visual fixes', () {
    for (final density in AerosDensity.values) {
      testWidgets('stat cards: the delta line is level across mono and non-mono cards · ${density.name}',
          (tester) async {
        await _pumpPage(
          tester,
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AerosStatCard(label: 'Orders', value: '128', delta: 'plain', deltaDirection: AerosDelta.up),
              ),
              SizedBox(width: 12),
              Expanded(
                child: AerosStatCard(
                  label: 'Revenue',
                  value: '₹ 4,82,000',
                  mono: true,
                  delta: 'mono',
                  deltaDirection: AerosDelta.up,
                ),
              ),
              SizedBox(width: 12),
              Expanded(child: AerosStatCard(label: 'Overdue', value: '3', mono: true)),
            ],
          ),
          width: 768,
          density: density,
        );
        expect(tester.getRect(find.text('mono')).top, tester.getRect(find.text('plain')).top);
        final cards = find.byType(AerosStatCard);
        expect(tester.getSize(cards.at(0)).height, tester.getSize(cards.at(1)).height);
        // The value block is one h1 line high for both faces.
        final h1 = AerosTypography.h1();
        for (final value in ['128', '₹ 4,82,000', '3']) {
          final block = tester.getSize(find.ancestor(of: find.text(value), matching: find.byType(FittedBox)));
          expect(block.height, moreOrLessEquals(h1.fontSize! * h1.height!, epsilon: 0.01));
        }
      });
    }

    testWidgets('variant picker: the first swatch sits on the same leading edge as a row of chips', (tester) async {
      const variants = [
        AerosVariantOption(id: 'ink', label: 'Ink', swatchColor: 0xFF111111, stockQty: 40),
        AerosVariantOption(id: 'sand', label: 'Sand', swatchColor: 0xFFD8C9A8, stockQty: 40),
      ];
      await _pumpPage(
        tester,
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AerosVariantPicker(key: const ValueKey('chips'), variants: variants, selectedVariantId: 'ink', onChanged: (_) {}),
          AerosVariantPicker(
            key: const ValueKey('swatches'),
            variants: variants,
            selectedVariantId: 'ink',
            style: AerosVariantPickerStyle.swatch,
            onChanged: (_) {},
          ),
        ]),
        width: 390,
      );
      final chip = tester.getRect(
        find.descendant(of: find.byKey(const ValueKey('chips')), matching: find.byType(AerosStateFill)).first,
      );
      final swatch = tester.getRect(
        find.descendant(of: find.byKey(const ValueKey('swatches')), matching: find.byType(AnimatedContainer)).first,
      );
      expect(chip.left, _gutter);
      expect(swatch.left, chip.left);
      expect(swatch.size, const Size(AerosSizeTokens.avatarXl, AerosSizeTokens.avatarXl));
      // Its name starts under it.
      final name = tester.getRect(
        find.descendant(of: find.byKey(const ValueKey('swatches')), matching: find.text('Ink')),
      );
      expect(name.left, swatch.left);
    });

    for (final direction in TextDirection.values) {
      testWidgets('repeating rows: the Add button starts on the rows\' leading edge · ${direction.name}',
          (tester) async {
        var adds = 0;
        await _pumpPage(
          tester,
          AerosRepeatingRows<int>(
            items: const [1, 2],
            itemBuilder: (context, i, item) => Text('row $item'),
            onAdd: () => adds++,
            onRemove: (_) {},
            addLabel: 'Add a row',
          ),
          width: 390,
          direction: direction,
        );
        final row = tester.getRect(find.byType(AerosSurface).first);
        final plus = tester.getRect(find.byIcon(Icons.add));
        if (direction == TextDirection.ltr) {
          expect(plus.left, row.left);
        } else {
          expect(plus.right, row.right);
        }
        // Still pressable where it is drawn.
        await tester.tap(find.text('Add a row'));
        expect(adds, 1);
        await tester.tap(find.byIcon(Icons.add));
        expect(adds, 2);
      });
    }
  });
}
