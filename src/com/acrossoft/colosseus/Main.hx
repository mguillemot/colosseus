package com.acrossoft.colosseus;

import com.acrossoft.colosseus.entities.Bullet;
import com.acrossoft.colosseus.entities.EnemyShip;
import com.acrossoft.colosseus.entities.GameEntity;
import com.acrossoft.colosseus.entities.PlayerShip;
import com.acrossoft.colosseus.entities.Polygon;
import com.acrossoft.colosseus.entities.Turret;
import com.acrossoft.colosseus.tweens.CyclicSinTween;
import com.acrossoft.colosseus.utils.LinkedList;
import com.acrossoft.colosseus.utils.LinkedListIterator;
import flash.display.AVM1Movie;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shader;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FullScreenEvent;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.SyncEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.Lib;
import flash.net.FileReference;
import flash.net.SharedObject;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.utils.Dictionary;
import flash.utils.Timer;

/**
 * ...
 * @author Matthieu Guillemot
 */

class Main extends Sprite
{
	
	static function main() 
	{
		var main : Main = new Main();
		Lib.current.addChild(main);
		main.init();
	}

	private function new()
	{
		super();
		m_myBullets = new Array<Bullet>();
		m_enemyBullets = new Array<Bullet>();
		m_polygons = new Array<Polygon>();
		m_editMode = EditMode.NONE;
		m_context = new GameContext();
		m_context.currentTime = Lib.getTimer();
		m_mousePosition = new Point();
		m_buttonCallbacks = new Hash < Void -> Void > ();
	}
	
	private function init() : Void
	{
		graphics.clear();
		graphics.beginFill(0xffff80);
		graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		graphics.endFill();
		
		m_nextButton = new Point(0, 0);
		addButton("Create", onCreateButtonClick);
		addButton("Move", onMoveButtonClick);
		addButton("Rotate", onRotateButtonClick);
		addButton("+Turret", onCreateTurretButtonClick);
		addButton("-Turret", onDeleteTurretButtonClick);
		addButton("ModTurret", onChangeTurretButtonClick);
		addButton("Delete", onDeleteButtonClick);
		addButton("Clear", onClearButtonClick);
		addButton("Save", onSaveButtonClick);
		addButton("Load", onLoadButtonClick);
		
		m_ship = new PlayerShip();
		m_ship.x = 300;
		m_ship.y = 300;
		stage.addChild(m_ship);

		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		stage.addEventListener(MouseEvent.CLICK, onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		
		//var t : CyclicSinTween = new CyclicSinTween(300, 200, 5000, m_enemy, "x");
		//t.start();
		
		m_mousePositionDisplay = new TextField();
		m_mousePositionDisplay.background = true;
		m_mousePositionDisplay.backgroundColor = 0xcccccc;
		m_mousePositionDisplay.border = true;
		m_mousePositionDisplay.width = 200;
		m_mousePositionDisplay.height = 18;
		m_mousePositionDisplay.x = stage.stageWidth - 205;
		m_mousePositionDisplay.y = 5;
		m_mousePositionDisplay.mouseEnabled = false;
		stage.addChild(m_mousePositionDisplay);
		m_myBulletsCountDisplay = new TextField();
		m_myBulletsCountDisplay.background = true;
		m_myBulletsCountDisplay.backgroundColor = 0xcccccc;
		m_myBulletsCountDisplay.border = true;
		m_myBulletsCountDisplay.width = 200;
		m_myBulletsCountDisplay.height = 18;
		m_myBulletsCountDisplay.x = stage.stageWidth - 205;
		m_myBulletsCountDisplay.y = 30;
		m_myBulletsCountDisplay.mouseEnabled = false;
		stage.addChild(m_myBulletsCountDisplay);
		m_enemyBulletsCountDisplay = new TextField();
		m_enemyBulletsCountDisplay.background = true;
		m_enemyBulletsCountDisplay.backgroundColor = 0xcccccc;
		m_enemyBulletsCountDisplay.border = true;
		m_enemyBulletsCountDisplay.width = 200;
		m_enemyBulletsCountDisplay.height = 18;
		m_enemyBulletsCountDisplay.x = stage.stageWidth - 205;
		m_enemyBulletsCountDisplay.y = 55;
		m_enemyBulletsCountDisplay.mouseEnabled = false;
		stage.addChild(m_enemyBulletsCountDisplay);
		m_modeDisplay = new TextField();
		m_modeDisplay.background = true;
		m_modeDisplay.backgroundColor = 0xcccccc;
		m_modeDisplay.border = true;
		m_modeDisplay.width = 200;
		m_modeDisplay.height = 18;
		m_modeDisplay.x = stage.stageWidth - 205;
		m_modeDisplay.y = 80;
		m_modeDisplay.mouseEnabled = false;
		stage.addChild(m_modeDisplay);
		refreshFields();
		
		stage.addEventListener(Event.ENTER_FRAME, frameUpdate);
	}
	
	private function addButton(label : String, onClick : Void -> Void) : Void
	{
		var button : Sprite = new Sprite();
		button.name = label;
		button.x = stage.width - 200 + 100 * m_nextButton.x;
		button.y = 120 + 40 * m_nextButton.y;
		button.graphics.clear();
		button.graphics.lineStyle(1, 0x0);
		button.graphics.beginFill(0xcccccc);
		button.graphics.drawRoundRect(0, 0, 80, 25, 10, 10);
		button.graphics.endFill();
		var text : TextField = new TextField();
		button.addChild(text);
		text.width = 80;
		text.htmlText = '<font size="16">' + label + '</font>';
		text.autoSize = TextFieldAutoSize.CENTER;
		text.mouseEnabled = false;
		var e : MouseEvent;
		button.addEventListener(MouseEvent.CLICK, onButtonClick);
		m_buttonCallbacks.set(button.name, onClick);
		stage.addChild(button);
		
		m_nextButton.x++;
		if (m_nextButton.x == 2)
		{
			m_nextButton.y++;
			m_nextButton.x = 0;
		}
	}
	
	private function onButtonClick(e : MouseEvent) : Void
	{
		m_buttonCallbacks.get(e.target.name)();
		e.stopPropagation(); 
	}
	
	private function onCreateButtonClick() : Void
	{
		if (m_editMode != EditMode.NONE && m_editMode != EditMode.SELECTED)
		{
			onEscape();
		}
		changeEditMode(EditMode.CREATE_PLACE_CENTER);
	}
	
	private function onMoveButtonClick() : Void
	{
		if (m_editMode != EditMode.NONE)
		{
			onEscape();
		}
		changeEditMode(EditMode.MOVE_CHOOSE);
	}
	
	private function onRotateButtonClick() : Void
	{
		if (m_editMode == EditMode.SELECTED)
		{
			changeEditMode(EditMode.ROTATE_WAIT_FOR_DROP);
			return;
		}
		if (m_editMode != EditMode.NONE)
		{
			onEscape();
		}
		changeEditMode(EditMode.ROTATE_CHOOSE);
	}
	
	private function onDeleteButtonClick() : Void
	{
		if (m_editMode != EditMode.NONE)
		{
			onEscape();
		}
		changeEditMode(EditMode.DELETE_CHOOSE);
	}
	
	private function onCreateTurretButtonClick() : Void
	{
		if (m_editMode != EditMode.NONE)
		{
			onEscape();
		}
		changeEditMode(EditMode.PLACE_TURRET_CHOOSE);
	}
	
	private function onDeleteTurretButtonClick() : Void
	{
		if (m_editMode != EditMode.NONE)
		{
			onEscape();
		}
		changeEditMode(EditMode.DELETE_TURRET);
	}
	
	private function onChangeTurretButtonClick() : Void
	{
		if (m_editMode != EditMode.NONE)
		{
			onEscape();
		}
		changeEditMode(EditMode.CHANGE_TURRET);
	}
	
	private function onClearButtonClick() : Void
	{
		if (m_editMode != EditMode.NONE)
		{
			onEscape();
		}
		for (poly in m_polygons)
		{
			stage.removeChild(poly);
		}
		m_polygons = new Array<Polygon>();
	}
	
	private function onSaveButtonClick() : Void
	{
		if (m_editMode != EditMode.NONE)
		{
			onEscape();
		}
		var save : SharedObject = SharedObject.getLocal("colosseus.stage");
		var saveData : Xml = Xml.createDocument();
		for (poly in m_polygons)
		{
			saveData.addChild(poly.toXml());
		}
		save.setProperty("polygons", saveData.toString());
		trace("Saved: \n" + saveData + "\n***(end)***");
	}

	private function onLoadButtonClick() : Void
	{
		if (m_editMode != EditMode.NONE)
		{
			onEscape();
		}
		var save : SharedObject = SharedObject.getLocal("colosseus.stage");
		var saveData : Xml = Xml.parse(save.data.polygons);
		var polyCount : Int = 0;
		for (polygonData in saveData.elementsNamed("polygon"))
		{
			var poly : Polygon = new Polygon();
			poly.fromXml(polygonData);
			stage.addChild(poly);
			m_polygons.push(poly);
			polyCount++;
		}
		trace("Loaded: " + polyCount + " polygon(s)");
	}

	private function refreshFields() : Void
	{
		m_mousePositionDisplay.text = "Mouse: " + m_mousePosition.x + " : " + m_mousePosition.y;
		m_myBulletsCountDisplay.text = "My bullets: " + m_myBullets.length;
		m_enemyBulletsCountDisplay.text = "Enemy bullets: " + m_enemyBullets.length;
		m_modeDisplay.text = "Edit mode: " + m_editMode;
	}
	
	private function fireAtEnemy() : Void
	{
		var bullet = new Bullet();
		bullet.x = m_ship.x;
		bullet.y = m_ship.y;		
		bullet.speed.y = -400;
		stage.addChild(bullet);		
		m_myBullets.push(bullet);
	}
	
	private function onEscape() : Void
	{
		switch (m_editMode)
		{
			case EditMode.SELECTED:
				selectPoly(null);
				changeEditMode(EditMode.NONE);
			case EditMode.CREATE_PLACE_CENTER:
				changeEditMode(EditMode.NONE);
			case EditMode.CREATE_ADD_POINT: 
				stage.removeChild(m_editingPolygon);
				m_editingPolygon = null;
				changeEditMode(EditMode.NONE);
			case EditMode.MOVE_CHOOSE:
				changeEditMode(EditMode.NONE);
			case EditMode.MOVE_WAIT_FOR_DROP:
				m_selectedPolygon.x = m_editInitialPosition.x;
				m_selectedPolygon.y = m_editInitialPosition.y;
				m_selectedPolygon.stopDrag();
				selectPoly(null);
				changeEditMode(EditMode.NONE);
			case EditMode.ROTATE_CHOOSE:
				changeEditMode(EditMode.NONE);
			case EditMode.ROTATE_WAIT_FOR_DROP:
				m_selectedPolygon.rotation = m_editInitialRotation;
				selectPoly(null);
				changeEditMode(EditMode.NONE);
			case EditMode.DELETE_CHOOSE:
				changeEditMode(EditMode.NONE);
			case EditMode.PLACE_TURRET_CHOOSE:
				changeEditMode(EditMode.NONE);
			case EditMode.PLACE_TURRET_WAIT_FOR_DROP:
				stage.removeChild(m_placingTurret);
				m_placingTurret = null;
				selectPoly(null);
				changeEditMode(EditMode.NONE);
			case EditMode.CHANGE_TURRET:
				changeEditMode(EditMode.NONE);
			case EditMode.DELETE_TURRET:
				changeEditMode(EditMode.NONE);
			default:
		}
	}
	
	private function onKeyDown(e : KeyboardEvent) : Void
	{
		//trace("Key down ! " + e.keyCode);
		switch (e.keyCode)
		{
			case 27: // Esc
				onEscape();
			case 37:
				m_leftPressed = true;
			case 39:
				m_rightPressed = true;
			case 38:
				m_upPressed = true;
			case 40:
				m_downPressed = true;
			case 84: // t
				m_context.hitboxVisible = !m_context.hitboxVisible;
			case 87: // w
				fireAtEnemy();
		}
	}
	
	private function onKeyUp(e : KeyboardEvent) : Void
	{
		//trace("Key up ! " + e.keyCode);
		switch (e.keyCode)
		{
			case 37:
				m_leftPressed = false;
			case 39:
				m_rightPressed = false;
			case 38:
				m_upPressed = false;
			case 40:
				m_downPressed = false;
		}
	}
	
	private function onMouseDown(e : MouseEvent) : Void
	{
		//trace("Click @ " + e.stageX + ":" + e.stageY);
		switch (m_editMode)
		{
			case EditMode.NONE:
				var p : Point = new Point(e.stageX, e.stageY);
				for (poly in m_polygons)
				{
					var selected : Polygon = poly.select(p);
					if (selected != null)
					{
						selectPoly(selected);
						changeEditMode(EditMode.SELECTED);
						break;
					}
				}
			case EditMode.SELECTED:
				var p : Point = new Point(e.stageX, e.stageY);
				for (poly in m_polygons)
				{
					var selected : Polygon = poly.select(p);
					if (selected != null)
					{
						selectPoly(selected);
						changeEditMode(EditMode.SELECTED);
						return;
					}
				}
				onEscape();
			case EditMode.CREATE_PLACE_CENTER:
				m_editingPolygon = new Polygon();
				m_editingPolygon.x = e.stageX;
				m_editingPolygon.y = e.stageY;
				m_editingPolygon.startEdit();
				stage.addChild(m_editingPolygon);
				changeEditMode(EditMode.CREATE_ADD_POINT);
			case EditMode.CREATE_ADD_POINT:
				var p : Point = new Point(e.stageX - m_editingPolygon.x, e.stageY - m_editingPolygon.y);
				m_editingPolygon.addPoint(p);
				if (!m_editingPolygon.isEditing())
				{
					if (m_selectedPolygon != null)
					{
						var localCenter : Point = m_selectedPolygon.globalToLocal(new Point(m_editingPolygon.x, m_editingPolygon.y));
						m_editingPolygon.x = localCenter.x;
						m_editingPolygon.y = localCenter.y;
						m_editingPolygon.rotation -= m_selectedPolygon.rotation;
						m_selectedPolygon.addPart(m_editingPolygon);
						changeEditMode(EditMode.SELECTED);
					}
					else
					{
						m_polygons.push(m_editingPolygon);
						changeEditMode(EditMode.NONE);
					}
					m_editingPolygon = null;
				}
			case EditMode.MOVE_CHOOSE:
				var p : Point = new Point(e.stageX, e.stageY);
				for (poly in m_polygons)
				{
					var selected : Polygon = poly.select(p);
					if (selected != null)
					{
						selectPoly(selected);
						poly.startDrag();
						changeEditMode(EditMode.MOVE_WAIT_FOR_DROP);
						return;
					}
				}
				onEscape();
			case EditMode.ROTATE_CHOOSE:
				var p : Point = new Point(e.stageX, e.stageY);
				for (poly in m_polygons)
				{
					var selected : Polygon = poly.select(p);
					if (selected != null)
					{
						selectPoly(selected);
						trace("selected rotation=" + selected.rotation);
						changeEditMode(EditMode.ROTATE_WAIT_FOR_DROP);
						return;
					}
				}
				onEscape();
			case EditMode.MOVE_WAIT_FOR_DROP:
				m_selectedPolygon.stopDrag();
				selectPoly(null);
				changeEditMode(EditMode.NONE);
			case EditMode.ROTATE_WAIT_FOR_DROP:
				selectPoly(null);
				changeEditMode(EditMode.NONE);
			case EditMode.DELETE_CHOOSE:
				var p : Point = new Point(e.stageX, e.stageY);
				for (poly in m_polygons)
				{
					if (poly.isInside(p))
					{
						m_polygons.remove(poly);
						stage.removeChild(poly);
						break;
					}
				}
			case EditMode.PLACE_TURRET_CHOOSE:
				var p : Point = new Point(e.stageX, e.stageY);
				for (poly in m_polygons)
				{
					if (poly.isInside(p))
					{
						selectPoly(poly);
						m_placingTurret = new Turret();
						m_placingTurret.x = e.stageX;
						m_placingTurret.y = e.stageY;
						stage.addChild(m_placingTurret);
						m_placingTurret.startDrag();
						changeEditMode(EditMode.PLACE_TURRET_WAIT_FOR_DROP);
						return;
					}
				}
				onEscape();
			case EditMode.PLACE_TURRET_WAIT_FOR_DROP:
				var p : Point = new Point(e.stageX, e.stageY);
				if (m_selectedPolygon.isInside(p))
				{
					var t : Turret = m_selectedPolygon.addTurret(m_selectedPolygon.globalToLocal(p));
					t.startFire();
					return;
				}
				onEscape();
			case EditMode.CHANGE_TURRET:
				for (poly in m_polygons)
				{
					for (turret in poly.turrets)
					{
						if (turret.hitTestPoint(e.stageX, e.stageY))
						{
							turret.changeType();
							break;
						}
					}
				}
			case EditMode.DELETE_TURRET:
				for (poly in m_polygons)
				{
					for (turret in poly.turrets)
					{
						if (turret.hitTestPoint(e.stageX, e.stageY))
						{
							poly.removeTurret(turret);
							break;
						}
					}
				}
			default:
		}
	}
	
	private function onMouseMove(e : MouseEvent) : Void
	{
		m_mousePosition.x = e.stageX;
		m_mousePosition.y = e.stageY;
		if (m_editMode == EditMode.ROTATE_WAIT_FOR_DROP)
		{
			var selectionOrigin : Point = m_selectedPolygon.localToGlobal(new Point(0, 0));
			var ac : Vector3D = new Vector3D(e.stageX - selectionOrigin.x, e.stageY - selectionOrigin.y, 0);
			var theta = Math.atan2(ac.y, ac.x);
			m_selectedPolygon.rotation = theta / Math.PI * 180;
			trace("theta=" + theta);
		}
	}
	
	private function changeEditMode(em : EditMode)
	{
		m_editMode = em;
		refreshFields();
	}
	
	private function selectPoly(poly : Polygon, stageClickPoint : Point)
	{
		if (m_selectedPolygon != null)
		{
			m_selectedPolygon.selected = false;
		}
		m_selectedPolygon = poly;
		if (m_selectedPolygon != null)
		{
			m_selectedPolygon.selected = true;
			m_editInitialPosition = new Point(m_selectedPolygon.x, m_selectedPolygon.y);
			m_editInitialRotation = m_selectedPolygon.rotation;
			m_editClickPoint = stageClickPoint;
		}
	}
	
	private function frameUpdate(e : Event) : Void
	{
		// Update tweens
		com.acrossoft.colosseus.tweens.Tweens.tick();
		
		// Create context
		m_context.stage = stage;
		m_context.playerShip = m_ship;
		m_context.elapsedTime = Lib.getTimer() - m_context.currentTime;
		m_context.currentTime = Lib.getTimer();
		
		// Update player ship position
		if (m_leftPressed)
		{
			m_ship.x -= 3;
		}
		if (m_rightPressed)
		{
			m_ship.x += 3;
		}
		if (m_upPressed)
		{
			m_ship.y -= 3;
		}
		if (m_downPressed)
		{
			m_ship.y += 3;
		}
		m_ship.update(m_context);
		
		// Update enemy bullets
		var deadBullets : Array<Bullet> = new Array<Bullet>();
		for (bullet in m_enemyBullets)
		{
			bullet.update(m_context);
			if (bullet.outOfStage(stage) || bullet.hits(m_ship))
			{
				deadBullets.push(bullet);
			}
		}
		for (bullet in deadBullets)
		{
			m_enemyBullets.remove(bullet);
			stage.removeChild(bullet);
		}
		
		// Update my bullets
		deadBullets = new Array<Bullet>();
		for (bullet in m_myBullets)
		{
			bullet.update(m_context);
			if (bullet.outOfStage(stage))
			{
				deadBullets.push(bullet);
			}
			else
			{
				var p = new Point(bullet.x, bullet.y);
				for (poly in m_polygons)
				{
					if (poly.isInside(p) || poly.getDistance(p) < bullet.hitRadius())
					{
						deadBullets.push(bullet);
						break;
					}
				}
			}
		}
		for (bullet in deadBullets)
		{
			m_myBullets.remove(bullet);
			stage.removeChild(bullet);
		}
		
		// Update entities
		for (poly in m_polygons)
		{
			poly.update(m_context);
		}
		
		// Add new bullets
		for (bullet in m_context.bulletsToAdd)
		{
			m_enemyBullets.push(bullet);
			stage.addChild(bullet);
		}
		
		// Reset context
		m_context.cleanup();
		
		// Update interface
		refreshFields();
	}
	
	private var m_buttonCallbacks : Hash < Void -> Void >;
	private var m_nextButton : Point;
	
	private var m_editMode : EditMode;
	private var m_editingPolygon : Polygon;
	private var m_selectedPolygon : Polygon;
	private var m_editInitialPosition : Point;
	private var m_editInitialRotation : Float;
	private var m_selectPoint : Point;
	private var m_placingTurret : Turret;
	
	private var m_context : GameContext;
	
	private var m_ship : PlayerShip;
	private var m_polygons : Array<Polygon>;
	private var m_enemyBullets : Array<Bullet>;
	private var m_myBullets : Array<Bullet>;
	
	private var m_mousePosition : Point;
	private var m_mousePositionDisplay : TextField;
	private var m_myBulletsCountDisplay : TextField;
	private var m_enemyBulletsCountDisplay : TextField;
	private var m_modeDisplay : TextField;
	
	private var m_leftPressed : Bool;
	private var m_rightPressed : Bool;
	private var m_upPressed : Bool;
	private var m_downPressed : Bool;
	
}