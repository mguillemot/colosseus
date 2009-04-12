package com.acrossoft.colosseus.entities;

import com.acrossoft.colosseus.hitboxes.CircleHitbox;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.Lib;
/**
 * ...
 * @author Matthieu Guillemot
 */
 
class Bullet extends GameEntity
{

	public function new()
	{
		super();
		m_speed = new Vector3D();
		var g = Lib.attach("asset.Bullet");
		g.width = 10;
		g.height = 20;
		addChild(g);
		m_hitbox = new CircleHitbox(new Point(0, 0), hitRadius());
		addChild(m_hitbox.getRepresentation());
		m_lastUpdate = Lib.getTimer();
	}
	
	public function update() : Void
	{
		var elapsedTime : Float = (Lib.getTimer() - m_lastUpdate) / 1000.0;
		x += m_speed.x * elapsedTime;
		y += m_speed.y * elapsedTime;
		m_lastUpdate = Lib.getTimer();
	}
	
	public function hitRadius() : Float
	{
		return 10;
	}
	
	public var speed(getSpeed, null) : Vector3D;
	
	private function getSpeed() : Vector3D
	{
		return m_speed;
	}
	
	private var m_speed : Vector3D;
	private var m_lastUpdate : Int;
	
}