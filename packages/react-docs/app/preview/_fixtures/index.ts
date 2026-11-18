import type { ComponentType } from "react";
import type { FixtureSlug } from "./slugs";

import AccordionFixture from "./accordion";
import AlertFixture from "./alert";
import AlertDialogFixture from "./alert-dialog";
import AvatarFixture from "./avatar";
import BadgeFixture from "./badge";
import BreadcrumbFixture from "./breadcrumb";
import ButtonFixture from "./button";
import CalendarFixture from "./calendar";
import CardFixture from "./card";
import CheckboxFixture from "./checkbox";
import CommandFixture from "./command";
import DialogFixture from "./dialog";
import DotMatrixFixture from "./dot-matrix";
import { DrawerBottomFixture, DrawerLeftFixture, DrawerRightFixture } from "./drawer";
import DropdownMenuFixture from "./dropdown-menu";
import EmptyStateFixture from "./empty-state";
import FoundationsSurfacesFixture from "./foundations-surfaces";
import FoundationsTypeFixture from "./foundations-type";
import InputFixture from "./input";
import LabelFixture from "./label";
import PaginationFixture from "./pagination";
import PopoverFixture from "./popover";
import ProgressFixture from "./progress";
import RadioFixture from "./radio";
import SelectFixture from "./select";
import SelectOpenFixture from "./select-open";
import SeparatorFixture from "./separator";
import SidebarFixture from "./sidebar";
import SkeletonFixture from "./skeleton";
import SpinnerFixture from "./spinner";
import StatCardFixture from "./stat-card";
import SwitchFixture from "./switch";
import TableFixture from "./table";
import TabsFixture from "./tabs";
import TagFixture from "./tag";
import TextareaFixture from "./textarea";
import ToastFixture from "./toast";
import TooltipFixture from "./tooltip";
import AppHeaderFixture from "./app-header";
import AppShellFixture from "./app-shell";
import SidebarRailFixture from "./sidebar-rail";

/**
 * slug → fixture component. `Record<FixtureSlug, …>` makes this exhaustive in
 * both directions: add the slug to `./slugs.ts` and the component here, or
 * `next build` fails. The Playwright specs iterate `FIXTURE_SLUGS`, so a
 * registered fixture is always screenshotted and axe-scanned.
 */
import DataTableFixture from "./data-table";
import ToggleFixture from "./toggle";
import SegmentedControlFixture from "./segmented-control";
import CollapsibleFixture from "./collapsible";
import ScrollAreaFixture from "./scroll-area";
import CountBadgeFixture from "./count-badge";
import FilterChipFixture from "./filter-chip";
import KbdFixture from "./kbd";
import PageHeaderFixture from "./page-header";
import FileUploadFixture from "./file-upload";
import StepperFixture from "./stepper";
import ComboboxFixture from "./combobox";
import ComboboxOpenFixture from "./combobox-open";
import DatePickerFixture from "./date-picker";
import DatePickerOpenFixture from "./date-picker-open";
import NumberInputFixture from "./number-input";
export const FIXTURES: Record<FixtureSlug, ComponentType> = {
  "foundations-type": FoundationsTypeFixture,
  "foundations-surfaces": FoundationsSurfacesFixture,
  button: ButtonFixture,
  input: InputFixture,
  textarea: TextareaFixture,
  select: SelectFixture,
  "select-open": SelectOpenFixture,
  checkbox: CheckboxFixture,
  radio: RadioFixture,
  switch: SwitchFixture,
  badge: BadgeFixture,
  tag: TagFixture,
  card: CardFixture,
  "stat-card": StatCardFixture,
  alert: AlertFixture,
  progress: ProgressFixture,
  avatar: AvatarFixture,
  tabs: TabsFixture,
  breadcrumb: BreadcrumbFixture,
  "dropdown-menu": DropdownMenuFixture,
  dialog: DialogFixture,
  "alert-dialog": AlertDialogFixture,
  "drawer-right": DrawerRightFixture,
  "drawer-left": DrawerLeftFixture,
  "drawer-bottom": DrawerBottomFixture,
  popover: PopoverFixture,
  tooltip: TooltipFixture,
  table: TableFixture,
  "empty-state": EmptyStateFixture,
  "app-header": AppHeaderFixture,
  sidebar: SidebarFixture,
  "sidebar-rail": SidebarRailFixture,
  "app-shell": AppShellFixture,
  "dot-matrix": DotMatrixFixture,
  label: LabelFixture,
  separator: SeparatorFixture,
  spinner: SpinnerFixture,
  skeleton: SkeletonFixture,
  accordion: AccordionFixture,
  toast: ToastFixture,
  pagination: PaginationFixture,
  command: CommandFixture,
  calendar: CalendarFixture,
  "data-table": DataTableFixture,
  "toggle": ToggleFixture,
  "segmented-control": SegmentedControlFixture,
  "collapsible": CollapsibleFixture,
  "scroll-area": ScrollAreaFixture,
  "count-badge": CountBadgeFixture,
  "filter-chip": FilterChipFixture,
  "kbd": KbdFixture,
  "page-header": PageHeaderFixture,
  "file-upload": FileUploadFixture,
  "stepper": StepperFixture,
  "combobox": ComboboxFixture,
  "combobox-open": ComboboxOpenFixture,
  "date-picker": DatePickerFixture,
  "date-picker-open": DatePickerOpenFixture,
  "number-input": NumberInputFixture,
};
