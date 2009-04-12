package com.acrossoft.colosseus;

import com.acrossoft.colosseus.entities.Bullet;
import com.acrossoft.colosseus.entities.EnemyShip;
import com.acrossoft.colosseus.entities.GameEntity;
import com.acrossoft.colosseus.entities.PlayerShip;
import com.acrossoft.colosseus.entities.Turret;
import com.acrossoft.colosseus.tweens.CyclicSinTween;
import com.acrossoft.colosseus.utils.LinkedList;
import com.acrossoft.colosseus.utils.LinkedListIterator;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.Lib;
import flash.text.TextField;
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
	}
	
	private function init() : Void
	{
		m_enemy = new EnemyShip();
		m_enemy.x = 300;
		m_enemy.y = 100;
		Lib.current.addChild(m_enemy);

		m_ship = new PlayerShip();
		m_ship.x = 300;
		m_ship.y = 300;
		Lib.current.addChild(m_ship);

		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		
		var timer : Timer = new Timer(1000.0 / 60);
		timer.addEventListener(TimerEvent.TIMER, frameUpdate);
		timer.start();

		var timer2 : Timer = new Timer(600.0);
		timer2.addEventListener(TimerEvent.TIMER, fireAtPlayer);
		timer2.start();
		
		//var t : CyclicSinTween = new CyclicSinTween(300, 200, 5000, m_enemy, "x");
		//t.start();
		
		m_myBulletsCountDisplay = new TextField();
		m_myBulletsCountDisplay.background = true;
		m_myBulletsCountDisplay.backgroundColor = 0xcccccc;
		m_myBulletsCountDisplay.border = true;
		m_myBulletsCountDisplay.width = 200;
		m_myBulletsCountDisplay.height = 18;
		m_myBulletsCountDisplay.x = stage.stageWidth - 205;
		m_myBulletsCountDisplay.y = 5;
		m_myBulletsCountDisplay.mouseEnabled = false;
		addChild(m_myBulletsCountDisplay);
		m_enemyBulletsCountDisplay = new TextField();
		m_enemyBulletsCountDisplay.background = true;
		m_enemyBulletsCountDisplay.backgroundColor = 0xcccccc;
		m_enemyBulletsCountDisplay.border = true;
		m_enemyBulletsCountDisplay.width = 200;
		m_enemyBulletsCountDisplay.height = 18;
		m_enemyBulletsCountDisplay.x = stage.stageWidth - 205;
		m_enemyBulletsCountDisplay.y = 30;
		m_enemyBulletsCountDisplay.mouseEnabled = false;
		addChild(m_enemyBulletsCountDisplay);
		m_modeDisplay = new TextField();
		m_modeDisplay.background = true;
		m_modeDisplay.backgroundColor = 0xcccccc;
		m_modeDisplay.border = true;
		m_modeDisplay.width = 200;
		m_modeDisplay.height = 18;
		m_modeDisplay.x = stage.stageWidth - 205;
		m_modeDisplay.y = 60;
		m_modeDisplay.mouseEnabled = false;
		addChild(m_modeDisplay);
		refreshFields();
	}
	
	private function refreshFields() : Void
	{
		m_myBulletsCountDisplay.text = "My bullets: " + m_myBullets.length;
		m_enemyBulletsCountDisplay.text = "Enemy bullets: " + m_enemyBullets.length;
		m_modeDisplay.text = "Edit mode: " + m_editMode;
	}
	
	private function fireAtPlayer(e : TimerEvent) : Void
	{
		var angle : Float = Math.atan2(m_ship.y - m_enemy.y, m_ship.x - m_enemy.x);
		var bullet = new Bullet();
		bullet.x = m_enemy.x;
		bullet.y = m_enemy.y;
		bullet.rotation = 90 + angle * 180 / Math.PI;
		bullet.speed.x = 200 * Math.cos(angle);
		bullet.speed.y = 200 * Math.sin(angle);
		stage.addChild(bullet);		
		m_enemyBullets.push(bullet);
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
	
	private function onKeyDown(e : KeyboardEvent) : Void
	{
		//trace("Key down ! " + e.keyCode);
		switch (e.keyCode)
		{
			case 27: // Esc
				switch (m_editMode)
				{
					case EditMode.CREATE_PLACE_CENTER:
						changeEditMode(EditMode.NONE);
					case EditMode.CREATE_ADD_POINT: 
						removeChild(m_editingPolygon);
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
					default:
				}
			case 37:
				m_leftPressed = true;
			case 39:
				m_rightPressed = true;
			case 38:
				m_upPressed = true;
			case 40:
				m_downPressed = true;
			case 68: // d
				if (m_editMode == EditMode.NONE)
				{
					changeEditMode(EditMode.CREATE_PLACE_CENTER);
				}
			case 70: // f
				if (m_editMode == EditMode.NONE)
				{
					changeEditMode(EditMode.MOVE_CHOOSE);
				}
			case 71: // g
				if (m_editMode == EditMode.NONE)
				{
					changeEditMode(EditMode.ROTATE_CHOOSE);
				}
			case 72: // h
				if (m_editMode == EditMode.NONE)
				{
					changeEditMode(EditMode.DELETE_CHOOSE);
				}
			case 74: //j
				if (m_editMode == EditMode.NONE)
				{
					changeEditMode(EditMode.PLACE_TURRET_CHOOSE);
				}
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
		switch (m_editMode)
		{
			case EditMode.CREATE_PLACE_CENTER:
				m_editingPolygon = new Polygon();
				m_editingPolygon.x = e.stageX;
				m_editingPolygon.y = e.stageY;
				m_editingPolygon.startEdit();
				addChild(m_editingPolygon);
				changeEditMode(EditMode.CREATE_ADD_POINT);
			case EditMode.CREATE_ADD_POINT:
				var p : Point = new Point(e.stageX - m_editingPolygon.x, e.stageY - m_editingPolygon.y);
				m_editingPolygon.addPoint(p);
				if (!m_editingPolygon.isEditing())
				{
					m_polygons.push(m_editingPolygon);
					m_editingPolygon = null;
					changeEditMode(EditMode.NONE);
				}
			case EditMode.MOVE_CHOOSE:
				var p : Point = new Point(e.stageX, e.stageY);
				for (poly in m_polygons)
				{
					if (poly.isInside(p))
					{
						selectPoly(poly);
						poly.startDrag();
						changeEditMode(EditMode.MOVE_WAIT_FOR_DROP);
						break;
					}
				}
			case EditMode.ROTATE_CHOOSE:
				var p : Point = new Point(e.stageX, e.stageY);
				for (poly in m_polygons)
				{
					if (poly.isInside(p))
					{
						selectPoly(poly);
						changeEditMode(EditMode.ROTATE_WAIT_FOR_DROP);
						break;
					}
				}
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
						removeChild(poly);
						changeEditMode(EditMode.NONE);
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
						addChild(m_placingTurret);
						m_placingTurret.startDrag();
						changeEditMode(EditMode.PLACE_TURRET_WAIT_FOR_DROP);
						break;
					}
				}
			case EditMode.PLACE_TURRET_WAIT_FOR_DROP:
				var p : Point = new Point(e.stageX, e.stageY);
				if (m_selectedPolygon.isInside(p))
				{
					var t : Turret = m_selectedPolygon.addTurret(m_selectedPolygon.globalToLocal(p));
					t.startFire();
				}
				m_placingTurret.stopDrag();
				removeChild(m_placingTurret);
				m_placingTurret = null;
				selectPoly(null);
				changeEditMode(EditMode.NONE);
			default:
		}
	}
	
	private function onMouseMove(e : MouseEvent) : Void
	{
		if (m_editMode == EditMode.ROTATE_WAIT_FOR_DROP)
		{
			var ac : Vector3D = new Vector3D(e.stageX - m_selectedPolygon.x, e.stageY - m_selectedPolygon.y, 0);
			var theta = Math.atan2(ac.y, ac.x);
			m_selectedPolygon.rotation = theta / Math.PI * 180;
		}
	}
	
	private function changeEditMode(em : EditMode)
	{
		m_editMode = em;
		refreshFields();
	}
	
	private function selectPoly(poly : Polygon)
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
		}
	}
	
	private function frameUpdate(e : TimerEvent) : Void
	{
		// Update tweens
		com.acrossoft.colosseus.tweens.Tweens.tick();
		
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
		
		// Update enemy bullets
		var deadBullets : Array<Bullet> = new Array<Bullet>();
		for (bullet in m_enemyBullets)
		{
			bullet.update();
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
			bullet.update();
			if (bullet.outOfStage(stage) || m_enemy.hits(bullet))
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
		
		// Update interface
		refreshFields();
	}
	
	private var m_editMode : EditMode;
	private var m_editingPolygon : Polygon;
	private var m_selectedPolygon : Polygon;
	private var m_editInitialPosition : Point;
	private var m_editInitialRotation : Float;
	private var m_placingTurret : Turret;
	
	private var m_ship : GameEntity;
	private var m_enemy : GameEntity;
	private var m_polygons : Array<Polygon>;
	private var m_enemyBullets : Array<Bullet>;
	private var m_myBullets : Array<Bullet>;
	
	private var m_myBulletsCountDisplay : TextField;
	private var m_enemyBulletsCountDisplay : TextField;
	private var m_modeDisplay : TextField;
	
	private var m_leftPressed : Bool;
	private var m_rightPressed : Bool;
	private var m_upPressed : Bool;
	private var m_downPressed : Bool;
	
}