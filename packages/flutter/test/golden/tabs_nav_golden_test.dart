import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

const _tabs = ['Overview', 'Orders', 'Invoices', 'Settings'];

void main() {
  goldenMatrix(
    'tabs_nav',
    size: const Size(760, 880),
    (context) => GoldenColumn(
      width: 720,
      children: [
        GoldenSection(
          'AerosTabs underline',
          child: AerosTabs(tabs: _tabs, selectedIndex: 1, onChanged: (_) {}),
        ),
        GoldenSection(
          'AerosTabs pill',
          child: AerosTabs(tabs: _tabs, selectedIndex: 1, onChanged: (_) {}, variant: AerosTabVariant.pill),
        ),
        GoldenSection(
          'AerosBreadcrumb',
          child: AerosBreadcrumb(
            items: [
              AerosBreadcrumbItem('Catalogue', onTap: () {}),
              AerosBreadcrumbItem('Paper cups', onTap: () {}),
              const AerosBreadcrumbItem('250 ml single wall'),
            ],
          ),
        ),
        const GoldenSection(
          'AerosStepper',
          child: SizedBox(width: 380, child: AerosStepper(currentStep: 2, totalSteps: 5, label: 'Business details')),
        ),
        const GoldenSection(
          'AerosStepper first and last step, no label, custom colour',
          child: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AerosStepper(currentStep: 0, totalSteps: 4, label: 'Start'),
                SizedBox(height: 12),
                AerosStepper(currentStep: 4, totalSteps: 4, label: 'Done'),
                SizedBox(height: 12),
                AerosStepper(currentStep: 1, totalSteps: 3),
                SizedBox(height: 12),
                AerosStepper(currentStep: 2, totalSteps: 3, label: 'Review', color: AerosColors.success),
              ],
            ),
          ),
        ),
        GoldenSection(
          'AerosPagination compact (first, middle, last page)',
          child: GoldenRow(
            children: [
              AerosPagination(page: 1, totalPages: 12, onChanged: (_) {}),
              AerosPagination(page: 4, totalPages: 12, onChanged: (_) {}),
              AerosPagination(page: 12, totalPages: 12, onChanged: (_) {}),
            ],
          ),
        ),
        GoldenSection(
          'AerosPagination numbered (first, middle, last page, few pages)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AerosPagination(page: 1, totalPages: 12, onChanged: (_) {}, variant: AerosPaginationVariant.numbered),
              const SizedBox(height: 12),
              AerosPagination(page: 6, totalPages: 12, onChanged: (_) {}, variant: AerosPaginationVariant.numbered),
              const SizedBox(height: 12),
              AerosPagination(page: 12, totalPages: 12, onChanged: (_) {}, variant: AerosPaginationVariant.numbered),
              const SizedBox(height: 12),
              AerosPagination(page: 2, totalPages: 3, onChanged: (_) {}, variant: AerosPaginationVariant.numbered),
              const SizedBox(height: 12),
              AerosPagination(
                page: 6,
                totalPages: 12,
                onChanged: (_) {},
                variant: AerosPaginationVariant.numbered,
                maxVisiblePages: 7,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  goldenMatrix(
    'tabs_nav_page_header',
    size: const Size(760, 520),
    (context) => GoldenColumn(
      width: 720,
      children: [
        const GoldenSection('AerosPageHeader title only', child: AerosPageHeader(title: 'Orders')),
        const GoldenSection(
          'AerosPageHeader title and subtitle',
          child: AerosPageHeader(title: 'Orders', subtitle: '128 orders in the last 30 days'),
        ),
        GoldenSection(
          'AerosPageHeader breadcrumbs, leading, actions',
          child: AerosPageHeader(
            title: 'Order #4821',
            subtitle: 'Placed 12 Nov 2026 by Boson Machines',
            breadcrumbs: [
              AerosBreadcrumbItem('Orders', onTap: () {}),
              const AerosBreadcrumbItem('#4821'),
            ],
            leading: const Icon(Icons.arrow_back),
            actions: [
              AerosButton.secondary(label: 'Export', onPressed: () {}),
              AerosButton.primary(label: 'Mark shipped', onPressed: () {}),
            ],
          ),
        ),
        GoldenSection(
          'AerosPageHeader title and subtitle widgets, no padding',
          child: AerosPageHeader(
            padding: EdgeInsets.zero,
            titleWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Order #4821', style: AerosTypography.h2(color: context.aerosColors.fgPrimary)),
                const SizedBox(width: 10),
                const AerosBadge(label: 'Paid', tone: AerosBadgeTone.success),
              ],
            ),
            subtitleWidget: const AerosTag(label: 'Wholesale'),
          ),
        ),
      ],
    ),
  );

  // Hover and keyboard focus on a tab and a page button.
  Widget tabs(AerosTabVariant variant) => SizedBox(
        width: 420,
        child: AerosTabs(tabs: _tabs, selectedIndex: 1, onChanged: (_) {}, variant: variant),
      );
  for (final variant in AerosTabVariant.values) {
    goldenMatrix(
      'tabs_nav_tabs_${variant.name}_hovered',
      (context) => tabs(variant),
      size: const Size(460, 90),
      act: (t) => hover(t, find.text('Invoices')),
    );
    goldenMatrix(
      'tabs_nav_tabs_${variant.name}_focused',
      (context) => tabs(variant),
      size: const Size(460, 90),
      act: (t) => focus(t, find.byType(AerosTabs)),
    );
  }
  goldenMatrix(
    'tabs_nav_pagination_hovered',
    (context) => GoldenColumn(
      children: [
        AerosPagination(page: 6, totalPages: 12, onChanged: (_) {}, variant: AerosPaginationVariant.numbered),
      ],
    ),
    size: const Size(460, 90),
    act: (t) => hover(t, find.text('7')),
  );
}
