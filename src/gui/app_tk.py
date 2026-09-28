#!/usr/bin/env python3
"""Fallback Tkinter Desktop GUI for systems without PyGObject / GTK."""

import os
import re
import sys
import threading
from typing import Optional

try:
    import tkinter as tk
    from tkinter import ttk, messagebox, scrolledtext
except ImportError:
    tk = None  # type: ignore

from src.gui.data import (
    CATEGORIES,
    ToolInfo,
    get_all_tools,
    get_status_map,
    get_system_profile,
)
from src.gui.runner import CommandRunner

ANSI_REGEX = re.compile(r"\x1b\[([0-9;]*)m")


class TkSandwichApp:
    def __init__(self, initial_dry_run: bool = False, initial_verbose: bool = False):
        if tk is None:
            raise RuntimeError("Tkinter is not installed on this system.")

        self.root = tk.Tk()
        self.root.title("⚡ sudo-make-me-a-sandwich (Tkinter)")
        self.root.geometry("1060x700")
        self.root.minsize(800, 500)

        # Style dark theme
        self.root.configure(bg="#181825")

        self.runner = CommandRunner()
        self.all_tools: list[ToolInfo] = get_all_tools()
        self.status_map: dict[str, bool] = get_status_map()
        self.selected_tools: set[str] = set()
        self.current_category_id: str = "all"
        self.status_filter: str = "all"
        self.search_query: str = ""

        self.dry_run_var = tk.BooleanVar(value=initial_dry_run)
        self.verbose_var = tk.BooleanVar(value=initial_verbose)

        self._build_ui()
        self._refresh_tools_list()

    def _build_ui(self):
        # Header frame
        header = tk.Frame(self.root, bg="#1e1e2e", padx=12, pady=8)
        header.pack(fill=tk.X, side=tk.TOP)

        title_lbl = tk.Label(
            header,
            text="⚡ sudo-make-me-a-sandwich",
            font=("Helvetica", 14, "bold"),
            fg="#cba6f7",
            bg="#1e1e2e",
        )
        title_lbl.pack(side=tk.LEFT, padx=4)

        sub_lbl = tk.Label(
            header,
            text="Modular Linux Bootstrapper",
            font=("Helvetica", 10),
            fg="#a6adc8",
            bg="#1e1e2e",
        )
        sub_lbl.pack(side=tk.LEFT, padx=8)

        btn_prof = tk.Button(
            header,
            text="ℹ Profile",
            command=self._show_profile,
            bg="#313244",
            fg="#cdd6f4",
            relief=tk.FLAT,
        )
        btn_prof.pack(side=tk.LEFT, padx=6)

        btn_ref = tk.Button(
            header,
            text="🔄 Refresh",
            command=self._refresh_statuses,
            bg="#313244",
            fg="#cdd6f4",
            relief=tk.FLAT,
        )
        btn_ref.pack(side=tk.LEFT, padx=4)

        chk_dry = tk.Checkbutton(
            header,
            text="Dry Run",
            variable=self.dry_run_var,
            bg="#1e1e2e",
            fg="#f9e2af",
            selectcolor="#313244",
            activebackground="#1e1e2e",
        )
        chk_dry.pack(side=tk.RIGHT, padx=8)

        chk_verb = tk.Checkbutton(
            header,
            text="Verbose",
            variable=self.verbose_var,
            bg="#1e1e2e",
            fg="#89dceb",
            selectcolor="#313244",
            activebackground="#1e1e2e",
        )
        chk_verb.pack(side=tk.RIGHT, padx=4)

        # Paned Window (Split into Top Workspace & Bottom Terminal)
        self.v_paned = tk.PanedWindow(self.root, orient=tk.VERTICAL, bg="#313244", sashwidth=4)
        self.v_paned.pack(fill=tk.BOTH, expand=True)

        top_frame = tk.Frame(self.v_paned, bg="#181825")
        self.v_paned.add(top_frame, height=440)

        # Left Sidebar (Categories)
        sidebar_frame = tk.Frame(top_frame, bg="#11111b", width=220, padx=6, pady=6)
        sidebar_frame.pack(side=tk.LEFT, fill=tk.Y)
        sidebar_frame.pack_propagate(False)

        # Search bar
        self.search_var = tk.StringVar()
        self.search_var.trace_add("write", lambda *_: self._on_search())
        search_ent = tk.Entry(
            sidebar_frame,
            textvariable=self.search_var,
            bg="#1e1e2e",
            fg="#cdd6f4",
            insertbackground="#cdd6f4",
            relief=tk.FLAT,
        )
        search_ent.pack(fill=tk.X, pady=4)

        # Category buttons
        cat_scroll = tk.Frame(sidebar_frame, bg="#11111b")
        cat_scroll.pack(fill=tk.BOTH, expand=True)

        self.cat_btns: dict[str, tk.Button] = {}

        btn_all = tk.Button(
            cat_scroll,
            text=f"🌟 All Tools ({len(self.all_tools)})",
            anchor="w",
            bg="#313244",
            fg="#cba6f7",
            relief=tk.FLAT,
            command=lambda: self._select_category("all"),
        )
        btn_all.pack(fill=tk.X, pady=1)
        self.cat_btns["all"] = btn_all

        for cat_id, cat_title, cat_icon in CATEGORIES:
            cnt = len([t for t in self.all_tools if t.category_id == cat_id])
            b = tk.Button(
                cat_scroll,
                text=f"{cat_icon} {cat_title} ({cnt})",
                anchor="w",
                bg="#181825",
                fg="#cdd6f4",
                relief=tk.FLAT,
                command=lambda c=cat_id: self._select_category(c),
            )
            b.pack(fill=tk.X, pady=1)
            self.cat_btns[cat_id] = b

        # Quick Actions
        qa_frame = tk.Frame(sidebar_frame, bg="#11111b", pady=6)
        qa_frame.pack(fill=tk.X, side=tk.BOTTOM)

        btn_f = tk.Button(
            qa_frame,
            text="⚡ Full Install",
            command=self._run_full,
            bg="#9d4edd",
            fg="#ffffff",
            relief=tk.FLAT,
        )
        btn_f.pack(fill=tk.X, pady=2)

        btn_m = tk.Button(
            qa_frame,
            text="🚀 Minimal Install",
            command=self._run_min,
            bg="#2ec4b6",
            fg="#0b0f19",
            relief=tk.FLAT,
        )
        btn_m.pack(fill=tk.X, pady=2)

        btn_u = tk.Button(
            qa_frame,
            text="🔄 Update System",
            command=self._run_upd,
            bg="#313244",
            fg="#cdd6f4",
            relief=tk.FLAT,
        )
        btn_u.pack(fill=tk.X, pady=2)

        # Center Tools Frame
        center_frame = tk.Frame(top_frame, bg="#181825", padx=8, pady=6)
        center_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        ctrl_bar = tk.Frame(center_frame, bg="#181825")
        ctrl_bar.pack(fill=tk.X, pady=4)

        self.cat_header_lbl = tk.Label(
            ctrl_bar,
            text="🌟 All Tools",
            font=("Helvetica", 12, "bold"),
            fg="#cdd6f4",
            bg="#181825",
        )
        self.cat_header_lbl.pack(side=tk.LEFT)

        btn_sa = tk.Button(
            ctrl_bar,
            text="Select All",
            command=lambda: self._select_all_visible(True),
            bg="#313244",
            fg="#cdd6f4",
            relief=tk.FLAT,
        )
        btn_sa.pack(side=tk.LEFT, padx=6)

        btn_da = tk.Button(
            ctrl_bar,
            text="Deselect All",
            command=lambda: self._select_all_visible(False),
            bg="#313244",
            fg="#cdd6f4",
            relief=tk.FLAT,
        )
        btn_da.pack(side=tk.LEFT)

        self.sel_count_lbl = tk.Label(
            ctrl_bar,
            text="0 selected",
            fg="#a6adc8",
            bg="#181825",
        )
        self.sel_count_lbl.pack(side=tk.RIGHT, padx=6)

        # Tools Treeview
        tree_frame = tk.Frame(center_frame, bg="#181825")
        tree_frame.pack(fill=tk.BOTH, expand=True)

        cols = ("check", "status", "name", "package")
        self.tree = ttk.Treeview(tree_frame, columns=cols, show="headings", selectmode="browse")
        self.tree.heading("check", text="[X]")
        self.tree.heading("status", text="Status")
        self.tree.heading("name", text="Tool Name")
        self.tree.heading("package", text="Package")

        self.tree.column("check", width=40, anchor="center")
        self.tree.column("status", width=110)
        self.tree.column("name", width=180)
        self.tree.column("package", width=220)

        self.tree.bind("<Button-1>", self._on_tree_click)
        self.tree.bind("<<TreeviewSelect>>", self._on_tree_select)

        scroll_tree = ttk.Scrollbar(tree_frame, orient=tk.VERTICAL, command=self.tree.yview)
        self.tree.configure(yscroll=scroll_tree.set)

        self.tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scroll_tree.pack(side=tk.RIGHT, fill=tk.Y)

        # Action Buttons
        bot_bar = tk.Frame(center_frame, bg="#181825", pady=6)
        bot_bar.pack(fill=tk.X)

        self.btn_install_sel = tk.Button(
            bot_bar,
            text="Install Selected (0)",
            command=self._run_install_sel,
            bg="#2ec4b6",
            fg="#0b0f19",
            font=("Helvetica", 10, "bold"),
            relief=tk.FLAT,
            state=tk.DISABLED,
        )
        self.btn_install_sel.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=4)

        self.btn_uninstall_sel = tk.Button(
            bot_bar,
            text="Uninstall Selected",
            command=self._run_uninstall_sel,
            bg="#e63946",
            fg="#ffffff",
            font=("Helvetica", 10, "bold"),
            relief=tk.FLAT,
            state=tk.DISABLED,
        )
        self.btn_uninstall_sel.pack(side=tk.RIGHT, padx=4)

        # Right Inspector Frame
        insp_frame = tk.Frame(top_frame, bg="#1e1e2e", width=260, padx=10, pady=10)
        insp_frame.pack(side=tk.RIGHT, fill=tk.Y)
        insp_frame.pack_propagate(False)

        self.insp_title = tk.Label(
            insp_frame,
            text="Select a Tool",
            font=("Helvetica", 12, "bold"),
            fg="#cba6f7",
            bg="#1e1e2e",
            anchor="w",
        )
        self.insp_title.pack(fill=tk.X, pady=2)

        self.insp_status = tk.Label(
            insp_frame,
            text="",
            font=("Helvetica", 10),
            fg="#a6adc8",
            bg="#1e1e2e",
            anchor="w",
        )
        self.insp_status.pack(fill=tk.X, pady=2)

        tk.Label(
            insp_frame,
            text="Description:",
            font=("Helvetica", 10, "bold"),
            fg="#cdd6f4",
            bg="#1e1e2e",
            anchor="w",
        ).pack(fill=tk.X, pady=(6, 2))

        self.insp_desc = tk.Message(
            insp_frame,
            text="Select any tool from the list to view its description, tips, and commands.",
            bg="#1e1e2e",
            fg="#cdd6f4",
            width=240,
        )
        self.insp_desc.pack(fill=tk.X)

        tk.Label(
            insp_frame,
            text="Tips & Features:",
            font=("Helvetica", 10, "bold"),
            fg="#cdd6f4",
            bg="#1e1e2e",
            anchor="w",
        ).pack(fill=tk.X, pady=(6, 2))

        self.insp_tips = tk.Message(
            insp_frame,
            text="",
            bg="#1e1e2e",
            fg="#a6adc8",
            width=240,
        )
        self.insp_tips.pack(fill=tk.BOTH, expand=True)

        self.btn_install_one = tk.Button(
            insp_frame,
            text="Install Tool",
            command=self._run_install_one,
            bg="#9d4edd",
            fg="#ffffff",
            relief=tk.FLAT,
            state=tk.DISABLED,
        )
        self.btn_install_one.pack(fill=tk.X, side=tk.BOTTOM, pady=4)

        # Bottom Console Log Frame
        console_frame = tk.Frame(self.v_paned, bg="#11111b", padx=6, pady=4)
        self.v_paned.add(console_frame, height=220)

        con_header = tk.Frame(console_frame, bg="#11111b")
        con_header.pack(fill=tk.X, pady=2)

        self.con_status_lbl = tk.Label(
            con_header,
            text="Console: Idle",
            fg="#cdd6f4",
            bg="#11111b",
        )
        self.con_status_lbl.pack(side=tk.LEFT)

        self.btn_cancel = tk.Button(
            con_header,
            text="Cancel Process",
            command=lambda: self.runner.cancel(),
            bg="#e63946",
            fg="#ffffff",
            relief=tk.FLAT,
            state=tk.DISABLED,
        )
        self.btn_cancel.pack(side=tk.RIGHT, padx=4)

        btn_clr = tk.Button(
            con_header,
            text="Clear Log",
            command=self._clear_console,
            bg="#313244",
            fg="#cdd6f4",
            relief=tk.FLAT,
        )
        btn_clr.pack(side=tk.RIGHT, padx=4)

        self.console_text = scrolledtext.ScrolledText(
            console_frame,
            bg="#11111b",
            fg="#f5e0dc",
            font=("Monospace", 9),
            relief=tk.FLAT,
            wrap=tk.WORD,
        )
        self.console_text.pack(fill=tk.BOTH, expand=True)

        # Setup tags
        self.console_text.tag_configure("red", foreground="#f38ba8")
        self.console_text.tag_configure("green", foreground="#a6e3a1")
        self.console_text.tag_configure("yellow", foreground="#f9e2af")
        self.console_text.tag_configure("cyan", foreground="#89dceb")
        self.console_text.tag_configure("purple", foreground="#cba6f7")
        self.console_text.tag_configure("default", foreground="#cdd6f4")

        self.active_tool: Optional[ToolInfo] = None

    def _select_category(self, cat_id: str):
        self.current_category_id = cat_id
        for cid, btn in self.cat_btns.items():
            btn.configure(bg="#313244" if cid == cat_id else "#181825")
        if cat_id == "all":
            self.cat_header_lbl.config(text="🌟 All Tools")
        else:
            cat_info = next((c for c in CATEGORIES if c[0] == cat_id), None)
            if cat_info:
                self.cat_header_lbl.config(text=f"{cat_info[2]} {cat_info[1]}")
        self._refresh_tools_list()

    def _on_search(self):
        self.search_query = self.search_var.get().strip().lower()
        self._refresh_tools_list()

    def _refresh_tools_list(self):
        for item in self.tree.get_children():
            self.tree.delete(item)

        if self.search_query:
            tools = [
                t for t in self.all_tools
                if self.search_query in t.name.lower() or self.search_query in t.description.lower()
            ]
        elif self.current_category_id == "all":
            tools = self.all_tools
        else:
            tools = [t for t in self.all_tools if t.category_id == self.current_category_id]

        for tool in tools:
            is_inst = self.status_map.get(tool.name, False)
            status_text = "✔ Installed" if is_inst else "✘ Missing"
            chk = "[✔]" if tool.name in self.selected_tools else "[  ]"
            pkg = tool.pkg_name or (", ".join(tool.bin_names) if tool.bin_names else tool.category_title)
            self.tree.insert("", tk.END, iid=tool.name, values=(chk, status_text, tool.name, pkg))

        self._update_counts()

    def _on_tree_click(self, event):
        region = self.tree.identify_region(event.x, event.y)
        if region == "cell":
            col = self.tree.identify_column(event.x)
            item = self.tree.identify_row(event.y)
            if col == "#1" and item:
                tool_name = item
                if tool_name in self.selected_tools:
                    self.selected_tools.discard(tool_name)
                    self.tree.set(item, "check", "[  ]")
                else:
                    self.selected_tools.add(tool_name)
                    self.tree.set(item, "check", "[✔]")
                self._update_counts()

    def _on_tree_select(self, _):
        sel = self.tree.selection()
        if not sel:
            return
        tool_name = sel[0]
        tool = next((t for t in self.all_tools if t.name == tool_name), None)
        if tool:
            self._inspect(tool)

    def _inspect(self, tool: ToolInfo):
        self.active_tool = tool
        self.insp_title.config(text=f"{tool.category_icon} {tool.name}")
        is_inst = self.status_map.get(tool.name, False)
        if is_inst:
            self.insp_status.config(text="[✔] Installed", fg="#50fa7b")
            self.btn_install_one.config(text="Reinstall Tool")
        else:
            self.insp_status.config(text="[✘] Not Installed", fg="#f38ba8")
            self.btn_install_one.config(text="Install Tool")

        self.insp_desc.config(text=tool.description or "No description.")
        tips_lines = "\n".join(f"• {tip}" for tip in tool.tips)
        self.insp_tips.config(text=tips_lines or "No tips available.")
        self.btn_install_one.config(state=tk.NORMAL if not self.runner.is_running else tk.DISABLED)

    def _select_all_visible(self, select: bool):
        for item in self.tree.get_children():
            if select:
                self.selected_tools.add(item)
                self.tree.set(item, "check", "[✔]")
            else:
                self.selected_tools.discard(item)
                self.tree.set(item, "check", "[  ]")
        self._update_counts()

    def _update_counts(self):
        cnt = len(self.selected_tools)
        self.sel_count_lbl.config(text=f"{cnt} selected")
        self.btn_install_sel.config(
            text=f"Install Selected ({cnt})",
            state=tk.NORMAL if cnt > 0 and not self.runner.is_running else tk.DISABLED,
        )
        self.btn_uninstall_sel.config(
            state=tk.NORMAL if cnt > 0 and not self.runner.is_running else tk.DISABLED
        )

    def _start_exec(self, args: list[str]):
        if self.runner.is_running:
            return

        dry = self.dry_run_var.get()
        verb = self.verbose_var.get()

        self.con_status_lbl.config(text=f"Console: Running {' '.join(args)}...")
        self.btn_cancel.config(state=tk.NORMAL)
        self.btn_install_sel.config(state=tk.DISABLED)
        self.btn_uninstall_sel.config(state=tk.DISABLED)
        self.btn_install_one.config(state=tk.DISABLED)

        self.runner.run(
            args=args,
            dry_run=dry,
            verbose=verb,
            auto_yes=True,
            on_output=lambda l: self.root.after(0, self._append_line, l),
            on_finish=lambda c: self.root.after(0, self._on_finish, c),
        )

    def _append_line(self, line: str):
        # Strip ANSI codes for Tkinter and insert
        clean_line = ANSI_REGEX.sub("", line)
        self.console_text.insert(tk.END, clean_line)
        self.console_text.see(tk.END)

    def _on_finish(self, exit_code: int):
        self.btn_cancel.config(state=tk.DISABLED)
        if exit_code == 0:
            self.con_status_lbl.config(text="Console: Finished successfully (Code 0)")
        elif exit_code == 130:
            self.con_status_lbl.config(text="Console: Cancelled by user")
        else:
            self.con_status_lbl.config(text=f"Console: Exited with code {exit_code}")
        self._refresh_statuses()

    def _refresh_statuses(self):
        self.status_map = get_status_map()
        self._refresh_tools_list()
        if self.active_tool:
            self._inspect(self.active_tool)

    def _clear_console(self):
        self.console_text.delete("1.0", tk.END)
        self.con_status_lbl.config(text="Console: Idle")

    def _run_install_sel(self):
        if not self.selected_tools:
            return
        tools_str = ",".join(sorted(self.selected_tools))
        self._start_exec(["--install", tools_str])

    def _run_uninstall_sel(self):
        if not self.selected_tools:
            return
        tools_str = ",".join(sorted(self.selected_tools))
        self._start_exec(["--uninstall", "--install", tools_str])

    def _run_install_one(self):
        if not self.active_tool:
            return
        self._start_exec(["--install", self.active_tool.name])

    def _run_full(self):
        if messagebox.askokcancel("Full Installation", "Install all tools across all categories?"):
            self._start_exec(["--full"])

    def _run_min(self):
        if messagebox.askokcancel("Minimal Installation", "Install all Browsers and Terminals?"):
            self._start_exec(["--minimal"])

    def _run_upd(self):
        self._start_exec(["-u"])

    def _show_profile(self):
        prof = get_system_profile()
        msg = (
            f"Distro: {prof.get('distro')}\n"
            f"Kernel: {prof.get('kernel')}\n"
            f"Desktop: {prof.get('de')}\n"
            f"CPU: {prof.get('cpu')}\n"
            f"RAM: {prof.get('ram')}"
        )
        messagebox.showinfo("System Profile", msg)

    def run(self):
        self.root.mainloop()


def run_tk_app(initial_dry_run: bool = False, initial_verbose: bool = False) -> int:
    app = TkSandwichApp(initial_dry_run=initial_dry_run, initial_verbose=initial_verbose)
    app.run()
    return 0


if __name__ == "__main__":
    run_tk_app()
