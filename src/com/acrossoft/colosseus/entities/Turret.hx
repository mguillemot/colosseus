/**
 * ...
 * @author 
 */

package com.acrossoft.colosseus.entities;
import com.acrossoft.colosseus.GameContext;
import flash.display.AVM1Movie;
import flash.geom.Point;
import flash.Lib;

class Turret extends GameEntity
{

	public static inline var XML_ROOT_NAME : String = "turret";
	
	public function new() 
	{
		super();
		m_type = 0;
		recreateGraphics();
	}
	
	private function recreateGraphics() : Void
	{
		graphics.clear();
		graphics.lineStyle(1, 0x000000);
		graphics.beginFill(if (m_type == 0) 0xFFC60C else 0xFF147D);
		graphics.drawCircle(0, 0, 10);
		graphics.endFill();
		graphics.moveTo(0, 0);
		graphics.lineTo(10, 0);
	}
	
	public function changeType() : Void
	{
		m_type = (m_type + 1) % 2;
		if (m_type == 1)
		{
			m_autoRotation = 0;
		}
		recreateGraphics();
	}
	
	public override function update(context : GameContext) : Void
	{
		super.update(context);
		var myGlobalPos : Point = localToGlobal(new Point(0, 0));
		var angleTowardPlayer : Float = Math.atan2(context.playerShip.y - myGlobalPos.y, context.playerShip.x - myGlobalPos.x);
		if (m_type == 0)
		{
			rotation = angleTowardPlayer * 180 / Math.PI - parent.rotation;
			if (m_firing && context.currentTime - m_lastFire >= 1000)
			{
				var b : Bullet = new Bullet();
				b.x = myGlobalPos.x;
				b.y = myGlobalPos.y;
				b.rotation = 90 + angleTowardPlayer * 180 / Math.PI;
				b.speed.x = 200 * Math.cos(angleTowardPlayer);
				b.speed.y = 200 * Math.sin(angleTowardPlayer);
				context.addBullet(b);
				m_lastFire = context.currentTime;
			}
		}
		else
		{
			m_autoRotation += context.elapsedTime / 900 * Math.PI;
			rotation = m_autoRotation * 180 / Math.PI - parent.rotation;
			if (m_firing && context.currentTime - m_lastFire >= 300)
			{
				var b : Bullet = new Bullet();
				b.x = myGlobalPos.x;
				b.y = myGlobalPos.y;
				b.rotation = 90 + m_autoRotation * 180 / Math.PI;
				b.speed.x = 200 * Math.cos(m_autoRotation);
				b.speed.y = 200 * Math.sin(m_autoRotation);
				context.addBullet(b);
				m_lastFire = context.currentTime;
			}
		}
		
	}
	
	public function toXml() : Xml
	{
		var turretNode : Xml = Xml.createElement("turret");
		turretNode.set("x", Std.string(x));
		turretNode.set("y", Std.string(y));
		turretNode.set("type", Std.string(m_type));
		return turretNode;
	}
	
	public function fromXml(xml : Xml) : Void
	{
		x = Std.parseFloat(xml.get("x"));
		y = Std.parseFloat(xml.get("y"));
		m_type = Std.parseInt(xml.get("type"));
		m_autoRotation = 0;
		recreateGraphics();
	}
	
	public function startFire() : Void
	{
		m_firing = true;
	}
	
	private var m_type : Int;
	private var m_autoRotation : Float;
	private var m_firing : Bool;
	private var m_lastFire : Int;
	
}