package arm.ui;

import kha.System;
import zui.Zui;
import zui.Ext;
import zui.Id;
import iron.system.Input;

@:access(zui.Zui)
class UIBox {

	public static var show = false;
	public static var draggable = true;
	public static var hwnd = new Handle();
	public static var boxTitle = "";
	public static var boxText = "";
	public static var boxCommands: Zui->Void = null;
	public static var clickToHide = true;
	static var modalW = 400;
	static var modalH = 170;
	static var modalOnHide: Void->Void = null;
	static var draws = 0;
	static var copyable = false;
	#if (krom_android || krom_ios)
	static var tweenAlpha = 0.0;
	#end

	public static function render(g: kha.graphics2.Graphics) {
		if (!UIMenu.show) {
			var mouse = Input.getMouse();
			var kb = Input.getKeyboard();
			var ui = App.uiBox;
			var inUse = ui.comboSelectedHandle != null;
			var isEscape = kb.started("escape");
			if (draws > 2 && (ui.inputReleased || isEscape) && !inUse && !ui.isTyping) {
				var appw = System.windowWidth();
				var apph = System.windowHeight();
				var mw = Std.int(modalW * ui.SCALE());
				var mh = Std.int(modalH * ui.SCALE());
				var left = (appw / 2 - mw / 2) + hwnd.dragX;
				var right = (appw / 2 + mw / 2) + hwnd.dragX;
				var top = (apph / 2 - mh / 2) + hwnd.dragY;
				var bottom = (apph / 2 + mh / 2) + hwnd.dragY;
				var mx = mouse.x;
				var my = mouse.y;
				if ((clickToHide && (mx < left || mx > right || my < top || my > bottom)) || isEscape) {
					if (modalOnHide != null) modalOnHide();
					hide();
				}
			}
		}

		if (Config.raw.touch_ui) { // Darken bg
			#if (krom_android || krom_ios)
			g.color = kha.Color.fromFloats(0, 0, 0, tweenAlpha);
			#else
			g.color = kha.Color.fromFloats(0, 0, 0, 0.5);
			#end
			g.fillRect(0, 0, kha.System.windowWidth(), kha.System.windowHeight());
		}

		g.end();

		var ui = App.uiBox;
		var appw = System.windowWidth();
		var apph = System.windowHeight();
		var mw = Std.int(modalW * ui.SCALE());
		var mh = Std.int(modalH * ui.SCALE());
		var left = Std.int(appw / 2 - mw / 2);
		var top = Std.int(apph / 2 - mh / 2);

		if (boxCommands == null) {
			ui.begin(g);
			if (ui.window(hwnd, left, top, mw, mh, draggable)) {
				ui._y += 10;
				var tabVertical = Config.raw.touch_ui;
				if (ui.tab(Id.handle(), boxTitle, tabVertical)) {
					var htext = Id.handle();
					htext.text = boxText;
					copyable ?
						Ext.textArea(ui, htext, false) :
						ui.text(boxText);
					ui.endElement();
					#if (krom_windows || krom_linux || krom_darwin)
					if (copyable) ui.row([1 / 3, 1 / 3, 1 / 3]);
					else ui.row([2 / 3, 1 / 3]);
					#else
					ui.row([2 / 3, 1 / 3]);
					#end

					ui.endElement();

					#if (krom_windows || krom_linux || krom_darwin)
					if (copyable && ui.button(tr("Copy"))) {
						Krom.copyToClipboard(boxText);
					}
					#end
					if (ui.button(tr("OK"))) {
						hide();
					}
				}
				windowBorder(ui);
			}
			ui.end();
		}
		else {
			ui.begin(g);
			if (ui.window(hwnd, left, top, mw, mh, draggable)) {
				ui._y += 10;
				boxCommands(ui);
				windowBorder(ui);
			}
			ui.end();
		}

		g.begin(false);

		draws++;
	}

	public static function showMessage(title: String, text: String, copyable = false) {
		init();
		modalW = 400;
		modalH = 210;
		boxTitle = title;
		boxText = text;
		boxCommands = null;
		UIBox.copyable = copyable;
		draggable = true;
		#if (krom_android || krom_ios)
		tweenIn();
		#end
	}

	public static function showCustom(commands: Zui->Void = null, mw = 400, mh = 200, onHide: Void->Void = null, draggable = true) {
		init();
		modalW = mw;
		modalH = mh;
		modalOnHide = onHide;
		boxCommands = commands;
		UIBox.draggable = draggable;
		#if (krom_android || krom_ios)
		tweenIn();
		#end
	}

	public static function hide() {
		#if (krom_android || krom_ios)
		tweenOut();
		#else
		hideInternal();
		#end
	}

	static function hideInternal() {
		show = false;
		App.redrawUI();
	}

	#if (krom_android || krom_ios)
	static function tweenIn() {
		iron.system.Tween.to({target: UIBox, props: { tweenAlpha: 0.5 }, duration: 0.2, ease: iron.system.Tween.Ease.ExpoOut});
		UIBox.hwnd.dragY = Std.int(kha.System.windowHeight() / 2);
		iron.system.Tween.to({target: UIBox.hwnd, props: { dragY: 0 }, duration: 0.2, ease: iron.system.Tween.Ease.ExpoOut, tick: function() { App.redrawUI(); }});
	}

	static function tweenOut() {
		iron.system.Tween.to({target: UIBox, props: { tweenAlpha: 0.0 }, duration: 0.2, ease: iron.system.Tween.Ease.ExpoIn, done: hideInternal});
		iron.system.Tween.to({target: UIBox.hwnd, props: { dragY: kha.System.windowHeight() / 2 }, duration: 0.2, ease: iron.system.Tween.Ease.ExpoIn});
	}
	#end

	static function init() {
		hwnd.redraws = 2;
		hwnd.dragX = 0;
		hwnd.dragY = 0;
		show = true;
		draws = 0;
		clickToHide = true;
	}

	static function windowBorder(ui: Zui) {
		if (ui.scissor) {
			ui.scissor = false;
			ui.g.disableScissor();
		}
		// Border
		ui.g.color = ui.t.SEPARATOR_COL;
		ui.g.fillRect(0, 0, 1, ui._windowH);
		ui.g.fillRect(0 + ui._windowW - 1, 0, 1, ui._windowH);
		ui.g.fillRect(0, 0 + ui._windowH - 1, ui._windowW, 1);
	}
}
