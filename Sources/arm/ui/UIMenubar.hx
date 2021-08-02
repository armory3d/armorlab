package arm.ui;

import kha.System;
import zui.Zui;
import zui.Id;
import zui.Ext;
import iron.RenderPath;
import arm.node.MakeMaterial;
import arm.render.RenderPathPaint;
import arm.Enums;

@:access(zui.Zui)
class UIMenubar {

	public static var inst: UIMenubar;
	public static inline var defaultMenubarW = 330;
	public var workspaceHandle = new Handle({layout: Horizontal});
	public var menuHandle = new Handle({layout: Horizontal});
	public var menubarw = defaultMenubarW;

	public function new() {
		inst = this;
	}

	public function renderUI(g: kha.graphics2.Graphics) {
		var ui = UISidebar.inst.ui;

		var panelx = iron.App.x();
		if (ui.window(menuHandle, panelx, 0, menubarw, Std.int(UIHeader.defaultHeaderH * ui.SCALE()))) {
			ui._x += 1; // Prevent "File" button highlight on startup

			Ext.beginMenu(ui);

			#if arm_touchui
			var defaultToolbarW = 36;
			ui._w = Std.int(defaultToolbarW * ui.SCALE());
			if (iconButton(ui, 0)) BoxPreferences.show();
			if (iconButton(ui, 1)) Project.projectNewBox();
			if (iconButton(ui, 2)) Project.projectOpen();
			if (iconButton(ui, 3)) Project.projectSave();
			if (iconButton(ui, 4)) Project.importAsset();
			if (iconButton(ui, 5)) BoxExport.showTextures();
			if (UIMenu.show && UIMenu.menuCategory == MenuViewport) ui.fill(0, 2, 32 + 4, 32, ui.t.HIGHLIGHT_COL);
			if (iconButton(ui, 8)) showMenu(ui, MenuViewport);
			if (UIMenu.show && UIMenu.menuCategory == MenuMode) ui.fill(0, 2, 32 + 4, 32, ui.t.HIGHLIGHT_COL);
			if (iconButton(ui, 9)) showMenu(ui, MenuMode);
			if (UIMenu.show && UIMenu.menuCategory == MenuCamera) ui.fill(0, 2, 32 + 4, 32, ui.t.HIGHLIGHT_COL);
			if (iconButton(ui, 10)) showMenu(ui, MenuCamera);
			if (UIMenu.show && UIMenu.menuCategory == MenuHelp) ui.fill(0, 2, 32 + 4, 32, ui.t.HIGHLIGHT_COL);
			if (iconButton(ui, 11)) showMenu(ui, MenuHelp);
			ui.enabled = History.undos > 0;
			if (iconButton(ui, 6)) History.undo();
			ui.enabled = History.redos > 0;
			if (iconButton(ui, 7)) History.redo();
			ui.enabled = true;
			#else
			var categories = [tr("File"), tr("Edit"), tr("Viewport"), tr("Mode"), tr("Camera"), tr("Help")];
			for (i in 0...categories.length) {
				if (Ext.menuButton(ui, categories[i]) || (UIMenu.show && UIMenu.menuCommands == null && ui.isHovered)) {
					showMenu(ui, i);
				}
			}
			#end

			if (menubarw < ui._x + 10) {
				menubarw = Std.int(ui._x + 10);
			}

			Ext.endMenu(ui);
		}

		var panelx = (iron.App.x()) + menubarw;
		if (ui.window(workspaceHandle, panelx, 0, System.windowWidth() - menubarw, Std.int(UIHeader.defaultHeaderH * ui.SCALE()))) {
			ui.tab(UIHeader.inst.worktab, tr("3D"));
			ui.tab(UIHeader.inst.worktab, tr("2D"));
			if (UIHeader.inst.worktab.changed) {
				Context.ddirty = 2;
				Context.brushBlendDirty = true;
				UIHeader.inst.headerHandle.redraws = 2;

				Context.mainObject().skip_context = null;
			}
		}
	}

	function showMenu(ui: Zui, category: Int) {
		UIMenu.show = true;
		UIMenu.menuCategory = category;
		UIMenu.menuX = Std.int(ui._x - ui._w);
		UIMenu.menuY = Std.int(Ext.MENUBAR_H(ui));
		#if arm_touchui
		var menuW = Std.int(App.defaultElementW * App.uiMenu.SCALE() * 2.0);
		UIMenu.menuX -= Std.int((menuW - ui._w) / 2) + Std.int(UIHeader.inst.headerh / 2);
		UIMenu.menuY += 4;
		#end
	}

	#if arm_touchui
	function iconButton(ui: Zui, i: Int): Bool {
		var col = ui.t.WINDOW_BG_COL;
		if (col < 0) col += untyped 4294967296;
		var light = col > 0xff666666 + 4294967296;
		var iconAccent = light ? 0xff666666 : 0xff999999;
		var img = Res.get("icons.k");
		var rect = Res.tile50(img, i, 2);
		return ui.image(img, iconAccent, null, rect.x, rect.y, rect.w, rect.h) == State.Released;
	}
	#end
}
