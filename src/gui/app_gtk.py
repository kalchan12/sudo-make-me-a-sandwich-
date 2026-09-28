#!/usr/bin/env python3
"""Modern GTK 3 Desktop GUI for sudo-make-me-a-sandwich."""

import os
from pathlib import Path
import re
import sys

import gi
gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
from gi.repository import Gtk, Gdk, GLib, Pango

from src.gui.data import (
    CATEGORIES,
    ToolInfo,
    get_all_tools,
    get_tools_by_category,
    get_status_map,
    get_system_profile,
    check_tool_installed,
)
from src.gui.runner import CommandRunner

ANSI_REGEX = re.compile(r"\x1b\[([0-9;]*)m")

CSS_STYLES = """
window, .main-window {
    background-color: #181825;
    color: #cdd6f4;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Cantarell, Ubuntu, sans-serif;
}

headerbar {
    background-color: #1e1e2e;
    border-bottom: 1px solid #313244;
    color: #cdd6f4;
    padding: 6px;
}

headerbar .title {
    font-weight: bold;
    color: #cba6f7;
    font-size: 15px;
}

headerbar .subtitle {
    color: #a6adc8;
    font-size: 11px;
}

.sidebar {
    background-color: #11111b;
    border-right: 1px solid #313244;
}

.sidebar row {
    padding: 8px 12px;
    border-radius: 6px;
    margin: 2px 6px;
    color: #cdd6f4;
    transition: all 150ms ease;
}

.sidebar row:selected {
    background-color: #313244;
    color: #cba6f7;
    font-weight: bold;
}

.sidebar row:hover:not(:selected) {
    background-color: #181825;
}

.tool-treeview {
    background-color: #181825;
    color: #cdd6f4;
}

.tool-treeview:selected {
    background-color: #313244;
    color: #ffffff;
}

.details-panel {
    background-color: #1e1e2e;
    border-left: 1px solid #313244;
    padding: 16px;
}

.console-view {
    background-color: #11111b;
    color: #f5e0dc;
    font-family: "JetBrains Mono", "Fira Code", monospace, "DejaVu Sans Mono", monospace;
    font-size: 12px;
    padding: 8px;
}

.btn-primary {
    background-color: #9d4edd;
    color: #ffffff;
    font-weight: bold;
    border-radius: 6px;
    padding: 6px 14px;
    border: none;
}

.btn-primary:hover {
    background-color: #b565f3;
}

.btn-success {
    background-color: #2ec4b6;
    color: #0b0f19;
    font-weight: bold;
    border-radius: 6px;
    padding: 6px 14px;
    border: none;
}

.btn-success:hover {
    background-color: #38dec7;
}

.btn-danger {
    background-color: #e63946;
    color: #ffffff;
    font-weight: bold;
    border-radius: 6px;
    padding: 6px 14px;
    border: none;
}

.btn-danger:hover {
    background-color: #ff4d5e;
}

.badge-installed {
    color: #50fa7b;
    font-weight: bold;
}

.badge-missing {
    color: #6c7086;
}

.preset-box {
    border-top: 1px solid #313244;
    padding: 8px;
    background-color: #11111b;
}
"""


class SandwichApp(Gtk.Window):
    def __init__(self, initial_dry_run: bool = False, initial_verbose: bool = False):
        super().__init__(title="⚡ sudo-make-me-a-sandwich")
        self.set_default_size(1120, 740)
        self.set_position(Gtk.WindowPosition.CENTER)

        self.runner = CommandRunner()
        self.all_tools: list[ToolInfo] = get_all_tools()
        self.status_map: dict[str, bool] = get_status_map()
        self.selected_tools: set[str] = set()
        self.current_category_id: str = "all"
        self.status_filter: str = "all"  # all, installed, missing
        self.search_query: str = ""

        self._apply_css()
        self._build_header(initial_dry_run, initial_verbose)
        self._build_ui()
        self._select_initial_category()

    def _apply_css(self):
        provider = Gtk.CssProvider()
        provider.load_from_data(CSS_STYLES.encode())
        screen = Gdk.Screen.get_default()
        if screen:
            Gtk.StyleContext.add_provider_for_screen(
                screen, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            )

    def _build_header(self, initial_dry_run: bool, initial_verbose: bool):
        header = Gtk.HeaderBar()
        header.set_show_close_button(True)
        header.props.title = "⚡ sudo-make-me-a-sandwich"
        header.props.subtitle = "Modular Linux Bootstrapper"
        self.set_titlebar(header)

        # Profile button on left
        profile_btn = Gtk.Button(label="ℹ System Profile")
        profile_btn.set_tooltip_text("View detected Distro, Desktop Environment, CPU & Memory")
        profile_btn.connect("clicked", self._on_show_profile)
        header.pack_start(profile_btn)

        # Refresh status button
        refresh_btn = Gtk.Button(label="🔄 Refresh")
        refresh_btn.set_tooltip_text("Rescan installed tools status")
        refresh_btn.connect("clicked", lambda _: self._refresh_statuses())
        header.pack_start(refresh_btn)

        # Right side options: Dry-run and Verbose switches
        options_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)

        dry_label = Gtk.Label(label="Dry Run:")
        self.dry_run_switch = Gtk.Switch()
        self.dry_run_switch.set_active(initial_dry_run)
        self.dry_run_switch.set_tooltip_text("Preview installation commands without modifying system")

        verbose_label = Gtk.Label(label="Verbose:")
        self.verbose_switch = Gtk.Switch()
        self.verbose_switch.set_active(initial_verbose)
        self.verbose_switch.set_tooltip_text("Show all execution commands and outputs")

        options_box.pack_start(dry_label, False, False, 0)
        options_box.pack_start(self.dry_run_switch, False, False, 0)
        options_box.pack_start(verbose_label, False, False, 0)
        options_box.pack_start(self.verbose_switch, False, False, 0)

        header.pack_end(options_box)

    def _build_ui(self):
        # Top-level vertical split: Main content (top) / Terminal output console (bottom)
        self.v_paned = Gtk.Paned(orientation=Gtk.Orientation.VERTICAL)
        self.v_paned.set_position(460)
        self.add(self.v_paned)

        # Main content horizontal split: Sidebar (left) / Tools + Details (right)
        self.h_paned = Gtk.Paned(orientation=Gtk.Orientation.HORIZONTAL)
        self.h_paned.set_position(240)
        self.v_paned.pack1(self.h_paned, resize=True, shrink=False)

        # Build Sidebar
        sidebar_box = self._build_sidebar()
        self.h_paned.pack1(sidebar_box, resize=False, shrink=False)

        # Build Center & Right: Tool list & Details pane
        tools_and_details = self._build_tools_and_details()
        self.h_paned.pack2(tools_and_details, resize=True, shrink=False)

        # Build Bottom Console
        console_box = self._build_console()
        self.v_paned.pack2(console_box, resize=True, shrink=False)

    def _build_sidebar(self) -> Gtk.Box:
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        box.get_style_context().add_class("sidebar")

        # Search entry
        search_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        search_box.set_border_width(8)
        self.search_entry = Gtk.SearchEntry()
        self.search_entry.set_placeholder_text("🔍 Search all tools...")
        self.search_entry.connect("search-changed", self._on_search_changed)
        search_box.pack_start(self.search_entry, False, False, 0)
        box.pack_start(search_box, False, False, 0)

        # Category List
        scroll = Gtk.ScrolledWindow()
        scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        self.category_list = Gtk.ListBox()
        self.category_list.set_selection_mode(Gtk.SelectionMode.SINGLE)
        self.category_list.connect("row-selected", self._on_category_selected)

        # Add "All Tools" row
        all_row = self._create_category_row("all", "🌟 All Tools", len(self.all_tools))
        self.category_list.add(all_row)

        # Add each Category row
        for cat_id, cat_title, cat_icon in CATEGORIES:
            cat_count = len([t for t in self.all_tools if t.category_id == cat_id])
            row = self._create_category_row(cat_id, f"{cat_icon} {cat_title}", cat_count)
            self.category_list.add(row)

        scroll.add(self.category_list)
        box.pack_start(scroll, True, True, 0)

        # Presets at bottom of sidebar
        preset_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        preset_box.get_style_context().add_class("preset-box")

        preset_title = Gtk.Label()
        preset_title.set_markup("<b>⚡ Quick Actions</b>")
        preset_title.set_halign(Gtk.Align.START)
        preset_box.pack_start(preset_title, False, False, 2)

        btn_full = Gtk.Button(label="⚡ Full Install")
        btn_full.set_tooltip_text("Install all tools across all categories")
        btn_full.get_style_context().add_class("btn-primary")
        btn_full.connect("clicked", lambda _: self._run_full_install())
        preset_box.pack_start(btn_full, False, False, 0)

        btn_min = Gtk.Button(label="🚀 Minimal Install")
        btn_min.set_tooltip_text("Install essential Browsers and Terminals only")
        btn_min.connect("clicked", lambda _: self._run_minimal_install())
        preset_box.pack_start(btn_min, False, False, 0)

        btn_update = Gtk.Button(label="🔄 Update System")
        btn_update.set_tooltip_text("Update system package repositories and packages")
        btn_update.connect("clicked", lambda _: self._run_update_system())
        preset_box.pack_start(btn_update, False, False, 0)

        box.pack_end(preset_box, False, False, 0)
        return box

    def _create_category_row(self, cat_id: str, label_text: str, count: int) -> Gtk.ListBoxRow:
        row = Gtk.ListBoxRow()
        row.cat_id = cat_id

        hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        lbl = Gtk.Label(label=label_text)
        lbl.set_halign(Gtk.Align.START)

        badge = Gtk.Label(label=f"({count})")
        badge.set_halign(Gtk.Align.END)
        badge.get_style_context().add_class("badge-missing")

        hbox.pack_start(lbl, True, True, 0)
        hbox.pack_end(badge, False, False, 0)
        row.add(hbox)
        return row

    def _build_tools_and_details(self) -> Gtk.Paned:
        paned = Gtk.Paned(orientation=Gtk.Orientation.HORIZONTAL)
        paned.set_position(520)

        # Left Column: Tools List Box
        tools_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        tools_box.set_border_width(8)

        # Filter & Action Header
        header_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        self.category_header_label = Gtk.Label()
        self.category_header_label.set_markup("<b>🌟 All Tools</b>")
        self.category_header_label.set_halign(Gtk.Align.START)
        header_box.pack_start(self.category_header_label, True, True, 0)

        # Status filter combo
        self.filter_combo = Gtk.ComboBoxText()
        self.filter_combo.append("all", "All Statuses")
        self.filter_combo.append("missing", "Not Installed")
        self.filter_combo.append("installed", "Installed Only")
        self.filter_combo.set_active(0)
        self.filter_combo.connect("changed", self._on_filter_changed)
        header_box.pack_end(self.filter_combo, False, False, 0)

        tools_box.pack_start(header_box, False, False, 2)

        # Selection buttons bar
        sel_bar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        btn_sel_all = Gtk.Button(label="Select All")
        btn_sel_all.connect("clicked", lambda _: self._select_all_visible(True))
        btn_desel_all = Gtk.Button(label="Deselect All")
        btn_desel_all.connect("clicked", lambda _: self._select_all_visible(False))

        self.sel_count_label = Gtk.Label(label="0 selected")
        self.sel_count_label.get_style_context().add_class("badge-missing")

        sel_bar.pack_start(btn_sel_all, False, False, 0)
        sel_bar.pack_start(btn_desel_all, False, False, 0)
        sel_bar.pack_end(self.sel_count_label, False, False, 4)
        tools_box.pack_start(sel_bar, False, False, 0)

        # TreeView for tools
        # Columns: [0: bool selected, 1: str status_icon, 2: str tool_name, 3: str category_or_pkg, 4: ToolInfo obj]
        self.tools_store = Gtk.ListStore(bool, str, str, str, object)
        self.tools_tree = Gtk.TreeView(model=self.tools_store)
        self.tools_tree.get_style_context().add_class("tool-treeview")
        self.tools_tree.connect("cursor-changed", self._on_tool_cursor_changed)

        # Col 0: Checkbox
        renderer_toggle = Gtk.CellRendererToggle()
        renderer_toggle.connect("toggled", self._on_tool_toggled)
        col_toggle = Gtk.TreeViewColumn("", renderer_toggle, active=0)
        col_toggle.set_fixed_width(34)
        self.tools_tree.append_column(col_toggle)

        # Col 1: Status Icon
        renderer_status = Gtk.CellRendererText()
        col_status = Gtk.TreeViewColumn("Status", renderer_status, text=1)
        col_status.set_fixed_width(110)
        self.tools_tree.append_column(col_status)

        # Col 2: Name
        renderer_name = Gtk.CellRendererText()
        renderer_name.props.weight = Pango.Weight.BOLD
        col_name = Gtk.TreeViewColumn("Tool Name", renderer_name, text=2)
        col_name.set_min_width(160)
        col_name.set_resizable(True)
        self.tools_tree.append_column(col_name)

        # Col 3: Package / Binary
        renderer_pkg = Gtk.CellRendererText()
        col_pkg = Gtk.TreeViewColumn("Package / Details", renderer_pkg, text=3)
        col_pkg.set_resizable(True)
        self.tools_tree.append_column(col_pkg)

        scroll_tree = Gtk.ScrolledWindow()
        scroll_tree.add(self.tools_tree)
        tools_box.pack_start(scroll_tree, True, True, 0)

        # Bottom Actions Bar
        action_bar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        action_bar.set_border_width(4)

        self.btn_install_selected = Gtk.Button(label="Install Selected (0)")
        self.btn_install_selected.get_style_context().add_class("btn-success")
        self.btn_install_selected.set_sensitive(False)
        self.btn_install_selected.connect("clicked", lambda _: self._run_install_selected())

        self.btn_uninstall_selected = Gtk.Button(label="Uninstall Selected")
        self.btn_uninstall_selected.get_style_context().add_class("btn-danger")
        self.btn_uninstall_selected.set_sensitive(False)
        self.btn_uninstall_selected.connect("clicked", lambda _: self._run_uninstall_selected())

        action_bar.pack_start(self.btn_install_selected, True, True, 0)
        action_bar.pack_start(self.btn_uninstall_selected, False, False, 0)
        tools_box.pack_end(action_bar, False, False, 0)

        paned.pack1(tools_box, resize=True, shrink=False)

        # Right Column: Tool Inspector Pane
        self.details_box = self._build_details_panel()
        paned.pack2(self.details_box, resize=False, shrink=False)

        return paned

    def _build_details_panel(self) -> Gtk.Box:
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        box.get_style_context().add_class("details-panel")
        box.set_size_request(280, -1)

        self.detail_title = Gtk.Label()
        self.detail_title.set_markup("<b>Select a Tool</b>")
        self.detail_title.set_halign(Gtk.Align.START)
        box.pack_start(self.detail_title, False, False, 0)

        self.detail_status = Gtk.Label()
        self.detail_status.set_halign(Gtk.Align.START)
        box.pack_start(self.detail_status, False, False, 0)

        # Description scrolled view
        desc_label_header = Gtk.Label()
        desc_label_header.set_markup("<b>Description:</b>")
        desc_label_header.set_halign(Gtk.Align.START)
        box.pack_start(desc_label_header, False, False, 2)

        self.detail_desc = Gtk.Label()
        self.detail_desc.set_line_wrap(True)
        self.detail_desc.set_halign(Gtk.Align.START)
        self.detail_desc.set_selectable(True)
        box.pack_start(self.detail_desc, False, False, 0)

        # Tips list
        tips_label_header = Gtk.Label()
        tips_label_header.set_markup("<b>Tips &amp; Features:</b>")
        tips_label_header.set_halign(Gtk.Align.START)
        box.pack_start(tips_label_header, False, False, 2)

        scroll_tips = Gtk.ScrolledWindow()
        scroll_tips.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        self.detail_tips = Gtk.Label()
        self.detail_tips.set_line_wrap(True)
        self.detail_tips.set_halign(Gtk.Align.START)
        self.detail_tips.set_valign(Gtk.Align.START)
        self.detail_tips.set_selectable(True)
        scroll_tips.add(self.detail_tips)
        box.pack_start(scroll_tips, True, True, 0)

        # Technical info metadata
        self.detail_meta = Gtk.Label()
        self.detail_meta.set_halign(Gtk.Align.START)
        self.detail_meta.set_line_wrap(True)
        box.pack_start(self.detail_meta, False, False, 4)

        # Direct install tool button
        self.btn_install_single = Gtk.Button(label="Install This Tool")
        self.btn_install_single.get_style_context().add_class("btn-primary")
        self.btn_install_single.set_sensitive(False)
        self.btn_install_single.connect("clicked", self._on_install_single_clicked)
        box.pack_end(self.btn_install_single, False, False, 0)

        self.current_inspected_tool: ToolInfo | None = None
        return box

    def _build_console(self) -> Gtk.Box:
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        box.set_border_width(6)

        # Console Header Bar
        con_header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)

        self.con_status_label = Gtk.Label(label="Console: Idle")
        self.con_status_label.set_halign(Gtk.Align.START)
        con_header.pack_start(self.con_status_label, False, False, 4)

        self.progress_bar = Gtk.ProgressBar()
        self.progress_bar.set_pulse_step(0.05)
        con_header.pack_start(self.progress_bar, True, True, 4)

        self.btn_cancel = Gtk.Button(label="Cancel Process")
        self.btn_cancel.get_style_context().add_class("btn-danger")
        self.btn_cancel.set_sensitive(False)
        self.btn_cancel.connect("clicked", lambda _: self.runner.cancel())
        con_header.pack_end(self.btn_cancel, False, False, 0)

        btn_clear = Gtk.Button(label="Clear Log")
        btn_clear.connect("clicked", lambda _: self._clear_console())
        con_header.pack_end(btn_clear, False, False, 0)

        box.pack_start(con_header, False, False, 0)

        # Scrolled Text View
        scroll = Gtk.ScrolledWindow()
        scroll.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC)
        self.console_view = Gtk.TextView()
        self.console_view.set_editable(False)
        self.console_view.set_cursor_visible(False)
        self.console_view.get_style_context().add_class("console-view")

        self.text_buffer = self.console_view.get_buffer()
        self._setup_text_tags()

        scroll.add(self.console_view)
        box.pack_start(scroll, True, True, 0)

        self._console_scroll = scroll
        return box

    def _setup_text_tags(self):
        buf = self.text_buffer
        buf.create_tag("red", foreground="#f38ba8", weight=Pango.Weight.BOLD)
        buf.create_tag("green", foreground="#a6e3a1", weight=Pango.Weight.BOLD)
        buf.create_tag("yellow", foreground="#f9e2af", weight=Pango.Weight.BOLD)
        buf.create_tag("cyan", foreground="#89dceb", weight=Pango.Weight.BOLD)
        buf.create_tag("purple", foreground="#cba6f7", weight=Pango.Weight.BOLD)
        buf.create_tag("dim", foreground="#6c7086")
        buf.create_tag("default", foreground="#cdd6f4")

    def _select_initial_category(self):
        first_row = self.category_list.get_row_at_index(0)
        if first_row:
            self.category_list.select_row(first_row)

    # --- Filtering and List Population ---

    def _refresh_tools_list(self):
        self.tools_store.clear()

        # Determine tools to show
        if self.search_query:
            tools = [
                t for t in self.all_tools
                if self.search_query in t.name.lower() or self.search_query in t.description.lower()
            ]
        elif self.current_category_id == "all":
            tools = self.all_tools
        else:
            tools = [t for t in self.all_tools if t.category_id == self.current_category_id]

        # Apply status filter
        if self.status_filter == "installed":
            tools = [t for t in tools if self.status_map.get(t.name, False)]
        elif self.status_filter == "missing":
            tools = [t for t in tools if not self.status_map.get(t.name, False)]

        for tool in tools:
            is_inst = self.status_map.get(tool.name, False)
            status_text = "✔ Installed" if is_inst else "✘ Not Installed"
            is_sel = tool.name in self.selected_tools
            details = tool.pkg_name if tool.pkg_name else (", ".join(tool.bin_names) if tool.bin_names else tool.category_title)
            self.tools_store.append([is_sel, status_text, tool.name, details, tool])

        self._update_selection_counts()

    def _on_category_selected(self, _, row):
        if not row:
            return
        self.current_category_id = getattr(row, "cat_id", "all")
        if self.current_category_id == "all":
            self.category_header_label.set_markup("<b>🌟 All Tools</b>")
        else:
            cat_info = next((c for c in CATEGORIES if c[0] == self.current_category_id), None)
            if cat_info:
                self.category_header_label.set_markup(f"<b>{cat_info[2]} {cat_info[1]}</b>")
        self._refresh_tools_list()

    def _on_search_changed(self, entry):
        self.search_query = entry.get_text().strip().lower()
        if self.search_query:
            self.category_header_label.set_markup(f"<b>🔍 Search Results: '{self.search_query}'</b>")
        else:
            self._on_category_selected(None, self.category_list.get_selected_row())
        self._refresh_tools_list()

    def _on_filter_changed(self, combo):
        self.status_filter = combo.get_active_id() or "all"
        self._refresh_tools_list()

    def _on_tool_toggled(self, _, path):
        it = self.tools_store.get_iter(path)
        cur = self.tools_store.get_value(it, 0)
        tool = self.tools_store.get_value(it, 4)
        new_val = not cur
        self.tools_store.set_value(it, 0, new_val)

        if new_val:
            self.selected_tools.add(tool.name)
        else:
            self.selected_tools.discard(tool.name)

        self._update_selection_counts()

    def _select_all_visible(self, select: bool):
        it = self.tools_store.get_iter_first()
        while it is not None:
            tool = self.tools_store.get_value(it, 4)
            self.tools_store.set_value(it, 0, select)
            if select:
                self.selected_tools.add(tool.name)
            else:
                self.selected_tools.discard(tool.name)
            it = self.tools_store.iter_next(it)
        self._update_selection_counts()

    def _update_selection_counts(self):
        count = len(self.selected_tools)
        self.sel_count_label.set_text(f"{count} selected")
        self.btn_install_selected.set_label(f"Install Selected ({count})")
        has_sel = count > 0 and not self.runner.is_running
        self.btn_install_selected.set_sensitive(has_sel)
        self.btn_uninstall_selected.set_sensitive(has_sel)

    def _on_tool_cursor_changed(self, tree):
        sel = tree.get_selection()
        model, it = sel.get_selected()
        if not it:
            return
        tool: ToolInfo = model.get_value(it, 4)
        self._inspect_tool(tool)

    def _inspect_tool(self, tool: ToolInfo):
        self.current_inspected_tool = tool
        self.detail_title.set_markup(f"<big><b>{tool.category_icon} {tool.name}</b></big>")

        is_inst = self.status_map.get(tool.name, False)
        if is_inst:
            self.detail_status.set_markup("<span foreground='#50fa7b'><b>[✔] Currently Installed</b></span>")
            self.btn_install_single.set_label("Reinstall Tool")
        else:
            self.detail_status.set_markup("<span foreground='#f38ba8'><b>[✘] Not Installed</b></span>")
            self.btn_install_single.set_label("Install Tool")

        self.detail_desc.set_text(tool.description or "No description available.")

        tips_text = ""
        for tip in tool.tips:
            tips_text += f"• {tip}\n"
        self.detail_tips.set_text(tips_text.strip() or "No specific tips.")

        meta_text = (
            f"<b>Category:</b> {tool.category_title}\n"
            f"<b>Package:</b> {tool.pkg_name or 'N/A'}\n"
            f"<b>Binaries:</b> {', '.join(tool.bin_names) if tool.bin_names else 'N/A'}\n"
            f"<b>Function:</b> {tool.bash_func}"
        )
        self.detail_meta.set_markup(meta_text)
        self.btn_install_single.set_sensitive(not self.runner.is_running)

    def _on_install_single_clicked(self, _):
        if not self.current_inspected_tool:
            return
        self._start_execution(["--install", self.current_inspected_tool.name])

    # --- Execution & Console Helpers ---

    def _start_execution(self, args: list[str]):
        if self.runner.is_running:
            return

        dry_run = self.dry_run_switch.get_active()
        verbose = self.verbose_switch.get_active()

        self._set_ui_running(True)
        self.con_status_label.set_text(f"Console: Running {' '.join(args)}...")

        self.runner.run(
            args=args,
            dry_run=dry_run,
            verbose=verbose,
            auto_yes=True,
            on_output=lambda line: GLib.idle_add(self._append_console_line, line),
            on_finish=lambda code: GLib.idle_add(self._on_command_finished, code),
        )

        # Start progress pulse timer
        GLib.timeout_add(100, self._pulse_progress)

    def _pulse_progress(self) -> bool:
        if self.runner.is_running:
            self.progress_bar.pulse()
            return True
        self.progress_bar.set_fraction(0.0)
        return False

    def _set_ui_running(self, running: bool):
        self.btn_cancel.set_sensitive(running)
        self.btn_install_selected.set_sensitive(not running and len(self.selected_tools) > 0)
        self.btn_uninstall_selected.set_sensitive(not running and len(self.selected_tools) > 0)
        if self.current_inspected_tool:
            self.btn_install_single.set_sensitive(not running)

    def _on_command_finished(self, exit_code: int):
        self._set_ui_running(False)
        if exit_code == 0:
            self.con_status_label.set_text("Console: Finished successfully (Code 0)")
        elif exit_code == 130:
            self.con_status_label.set_text("Console: Cancelled by user")
        else:
            self.con_status_label.set_text(f"Console: Failed with code {exit_code}")

        # Rescan statuses and refresh UI
        self._refresh_statuses()

    def _refresh_statuses(self):
        self.status_map = get_status_map()
        self._refresh_tools_list()
        if self.current_inspected_tool:
            self._inspect_tool(self.current_inspected_tool)

    def _append_console_line(self, line: str):
        buf = self.text_buffer
        end_iter = buf.get_end_iter()

        # Parse ANSI escape colors into GtkTextTags
        parts = []
        last_end = 0
        current_style = "default"

        for match in ANSI_REGEX.finditer(line):
            chunk = line[last_end:match.start()]
            if chunk:
                parts.append((current_style, chunk))
            code = match.group(1)
            if code in ("0", "", "00"):
                current_style = "default"
            elif "31" in code:
                current_style = "red"
            elif "32" in code:
                current_style = "green"
            elif "33" in code:
                current_style = "yellow"
            elif "34" in code or "36" in code:
                current_style = "cyan"
            elif "35" in code:
                current_style = "purple"
            last_end = match.end()

        remaining = line[last_end:]
        if remaining:
            parts.append((current_style, remaining))

        for style, chunk in parts:
            end_iter = buf.get_end_iter()
            buf.insert_with_tags_by_name(end_iter, chunk, style)

        # Autoscroll to bottom
        adj = self._console_scroll.get_vadjustment()
        adj.set_value(adj.get_upper() - adj.get_page_size())

    def _clear_console(self):
        self.text_buffer.set_text("")
        self.con_status_label.set_text("Console: Idle")

    # --- Actions: Selected / Presets ---

    def _run_install_selected(self):
        if not self.selected_tools:
            return
        tools_str = ",".join(sorted(self.selected_tools))
        self._start_execution(["--install", tools_str])

    def _run_uninstall_selected(self):
        if not self.selected_tools:
            return
        tools_str = ",".join(sorted(self.selected_tools))
        self._start_execution(["--uninstall", "--install", tools_str])

    def _run_full_install(self):
        dialog = Gtk.MessageDialog(
            transient_for=self,
            flags=0,
            message_type=Gtk.MessageType.QUESTION,
            buttons=Gtk.ButtonsType.OK_CANCEL,
            text="Run Full Installation?",
        )
        dialog.format_secondary_text(
            "This will install all tools across Browsers, Productivity, IDEs, Terminals, "
            "Shells, Dev Tools, Languages, Pentesting, Frameworks, and Agentic IDEs."
        )
        response = dialog.run()
        dialog.destroy()
        if response == Gtk.ResponseType.OK:
            self._start_execution(["--full"])

    def _run_minimal_install(self):
        dialog = Gtk.MessageDialog(
            transient_for=self,
            flags=0,
            message_type=Gtk.MessageType.QUESTION,
            buttons=Gtk.ButtonsType.OK_CANCEL,
            text="Run Minimal Installation?",
        )
        dialog.format_secondary_text("This will install all Browsers and Terminals.")
        response = dialog.run()
        dialog.destroy()
        if response == Gtk.ResponseType.OK:
            self._start_execution(["--minimal"])

    def _run_update_system(self):
        self._start_execution(["-u"])

    def _on_show_profile(self, _):
        profile = get_system_profile()
        dialog = Gtk.Dialog(
            title="System Profile",
            transient_for=self,
            flags=Gtk.DialogFlags.MODAL | Gtk.DialogFlags.DESTROY_WITH_PARENT,
        )
        dialog.add_button("Close", Gtk.ResponseType.CLOSE)
        dialog.set_default_size(480, 360)

        content = dialog.get_content_area()
        content.set_border_width(16)
        content.set_spacing(10)

        title = Gtk.Label()
        title.set_markup("<big><b>⚡ Detected System Profile</b></big>")
        content.pack_start(title, False, False, 4)

        grid = Gtk.Grid()
        grid.set_column_spacing(16)
        grid.set_row_spacing(8)

        items = [
            ("Distro:", profile.get("distro", "Unknown")),
            ("Kernel:", profile.get("kernel", "Unknown")),
            ("Desktop / WM:", profile.get("de", "Unknown")),
            ("Processor:", profile.get("cpu", "Unknown")),
            ("Total Memory:", profile.get("ram", "Unknown")),
        ]

        for row_idx, (k, v) in enumerate(items):
            lbl_k = Gtk.Label()
            lbl_k.set_markup(f"<b>{k}</b>")
            lbl_k.set_halign(Gtk.Align.START)

            lbl_v = Gtk.Label(label=v)
            lbl_v.set_halign(Gtk.Align.START)
            lbl_v.set_line_wrap(True)

            grid.attach(lbl_k, 0, row_idx, 1, 1)
            grid.attach(lbl_v, 1, row_idx, 1, 1)

        content.pack_start(grid, False, False, 6)

        persona_lbl = Gtk.Label()
        persona_lbl.set_markup("<i>\"A modular Linux bootstrapper for Debian-based distros.\"</i>")
        persona_lbl.set_halign(Gtk.Align.CENTER)
        content.pack_end(persona_lbl, False, False, 8)

        dialog.show_all()
        dialog.run()
        dialog.destroy()


def run_gtk_app(initial_dry_run: bool = False, initial_verbose: bool = False) -> int:
    """Launch the GTK 3 application."""
    app = SandwichApp(initial_dry_run=initial_dry_run, initial_verbose=initial_verbose)
    app.connect("destroy", Gtk.main_quit)
    app.show_all()
    Gtk.main()
    return 0


if __name__ == "__main__":
    dry = "--dry-run" in sys.argv
    verb = "-v" in sys.argv or "--verbose" in sys.argv
    sys.exit(run_gtk_app(initial_dry_run=dry, initial_verbose=verb))
