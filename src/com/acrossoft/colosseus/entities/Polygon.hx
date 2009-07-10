/**
 * ...
 * @author 
 */

package com.acrossoft.colosseus.entities;
import com.acrossoft.colosseus.entities.GameEntity;
import com.acrossoft.colosseus.entities.Turret;
import com.acrossoft.colosseus.GameContext;
import com.acrossoft.colosseus.hitboxes.CircleHitbox;
import flash.Boot;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Vector3D;

class Polygon extends GameEntity 
{

	public static inline var XML_ROOT_NAME : String = "polygon";
	
	private static inline var SELECT_NONE : Int = 0;
	private static inline var SELECT_PRIMARY : Int = 1;
	private static inline var SELECT_SECONDARY : Int = 2;
	
	public function new() 
	{
		super();
		m_points = new Array<Point>();
		m_turrets = new Array<Turret>();
		m_parts = new Array<Polygon>();
	}
	
	public override function update(context : GameContext) : Void
	{
		super.update(context);
		for (turret in m_turrets)
		{
			turret.update(context);
		}
	}
	
	private function recreateGraphics() : Void
	{
		graphics.clear();
		if (m_points.length > 1)
		{
			if (!m_editing)
			{
				var color : UInt = 0;
				switch (m_selectLevel)
				{
					case SELECT_NONE:
						color = 0x42E43F;
					case SELECT_PRIMARY:
						color = 0x42ECA3;
					case SELECT_SECONDARY:
						color = 0xB0FF70;
				}
				graphics.beginFill(color, 0.8);
			}
			graphics.lineStyle(2, 0x007F0E);
			var p : Point = m_points[0];
			graphics.moveTo(p.x, p.y);
			var last : Int = m_points.length;
			if (!m_editing)
			{
				last++;
			}
			for (i in 1...last)
			{
				p = m_points[i % m_points.length];
				graphics.lineTo(p.x, p.y);
			}
			if (!m_editing)
			{
				graphics.endFill();
			}
		}
		if (m_editing && m_points.length > 0)
		{
			graphics.lineStyle(1, 0x0);
			var lastPoint : Point = m_points[m_points.length - 1];
			graphics.drawCircle(lastPoint.x, lastPoint.y, 2);
		}
		graphics.lineStyle(0);
		graphics.beginFill(0xff0000);
		graphics.drawCircle(0, 0, 5);
		graphics.endFill();
	}
	
	public function startEdit() : Void
	{
		m_editing = true;
		recreateGraphics();
	}
	
	public function stopEdit() : Void
	{
		m_editing = false;
	}
	
	public function isEditing() : Bool
	{
		return m_editing;
	}
	
	public function addPoint(p : Point) : Void
	{
		if (m_editing)
		{
			if (m_points.length >= 2) 
			{
				var firstPoint : Point = m_points[0];
				if (p.subtract(firstPoint).length < 10)
				{
					p = firstPoint;
					m_editing = false;
				}
			}
			if (m_editing)
			{
				m_points.push(p);
			}
			recreateGraphics();
		}
	}
	
	public function addTurret(pos : Point) : Turret
	{
		var t : Turret = new Turret();
		t.x = pos.x;
		t.y = pos.y;
		m_turrets.push(t);
		addChild(t);
		return t;
	}
	
	public function addPart(part : Polygon) : Void
	{
		part.parentEntity = this;
		m_parts.push(part);
		addChild(part);
	}
	
	public function removeTurret(t : Turret) : Void
	{
		m_turrets.remove(t);
		removeChild(t);
	}
	
	public function removePart(part : Polygon) : Void
	{
		m_parts.remove(part);
		removeChild(part);
	}
	
	public function select(p : Point) : Polygon
	{
		if (isInsideMainBody(p))
		{
			return this;
		}
		for (part in m_parts)
		{
			var subSelect : Polygon = part.select(p);
			if (subSelect != null)
			{
				return subSelect;
			}
		}
		return null;
	}
	
	public function isInside(p : Point) : Bool
	{
		return (select(p) != null);
	}
	
	private function isInsideMainBody(p : Point) : Bool
	{
		if (!hitTestPoint(p.x, p.y))
		{
			return false;
		}
		var count : Int = 0;
		var a : Point = getTransformedPoint(0);
		for (i in 0...m_points.length)
		{
			var b : Point = getTransformedPoint(i + 1);
			if (p.y > Math.min(a.y, b.y) && p.y <= Math.max(a.y, b.y) && p.x <= Math.max(a.x, b.x) && a.y != b.y)
			{
				var xInter : Float = (p.y - a.y) * (b.x - a.x) / (b.y - a.y) + a.x;
				if (a.x == b.x || p.x <= xInter)
				{
					count++;
				}
			}
			a = b;
		}
		return count % 2 != 0;
	}
	
	public function getDistance(p : Point) : Float
	{
		var min = Math.POSITIVE_INFINITY;
		for (i in 0...m_points.length)
		{
			var a : Point = getTransformedPoint(i);
			var b : Point = getTransformedPoint(i + 1);
			var d : Float = getPointToLineDistance(a, b, p);
			if (d < min)
			{
				min = d;
			}
		}
		return min;
	}
	
	private function getTransformedPoint(i : Int) : Point
	{		
		var p = m_points[i % m_points.length];
		return localToGlobal(p);
	}
	
	public function toXml() : Xml
	{
		var polygonNode : Xml = Xml.createElement(XML_ROOT_NAME);
		polygonNode.set("x", Std.string(x));
		polygonNode.set("y", Std.string(y));
		polygonNode.set("rotation", Std.string(rotation));
		for (point in m_points)
		{
			var pointNode : Xml = Xml.createElement("point");
			pointNode.set("x", Std.string(point.x));
			pointNode.set("y", Std.string(point.y));
			polygonNode.addChild(pointNode);
		}
		for (turret in m_turrets)
		{
			var turretNode : Xml = turret.toXml();
			polygonNode.addChild(turretNode);
		}
		var partsNode : Xml = Xml.createElement("parts");
		for (part in m_parts)
		{
			var partNode : Xml = part.toXml();
			partsNode.addChild(partNode);
		}
		polygonNode.addChild(partsNode);
		return polygonNode;
	}
	
	public function fromXml(xml : Xml) : Void
	{
		x = Std.parseFloat(xml.get("x"));
		y = Std.parseFloat(xml.get("y"));
		rotation = Std.parseFloat(xml.get("rotation"));
		m_points = new Array<Point>();
		for (pointData in xml.elementsNamed("point"))
		{
			var point : Point = new Point();
			point.x = Std.parseFloat(pointData.get("x"));
			point.y = Std.parseFloat(pointData.get("y"));
			m_points.push(point);
		}
		for (turretData in xml.elementsNamed(Turret.XML_ROOT_NAME))
		{
			var turret : Turret = new Turret();
			turret.fromXml(turretData);
			m_turrets.push(turret);
			addChild(turret);
			turret.startFire();
		}
		for (partsData in xml.elementsNamed("parts"))
		{
			for (partData in partsData.elementsNamed(XML_ROOT_NAME))
			{
				var part : Polygon = new Polygon();
				part.fromXml(partData);
				addPart(part);
			}
		}
		recreateGraphics();
	}
	
	/**
	 * Compute if the c point is on the "right" side of the (a,b) line.
	 * 
	 * @param	a one point of the line.
	 * @param	b another point of the line.
	 * @param	c test point.
	 * @return	true if c is on the right side of (a,b)
	 */
	private static function partitionTest(a : Point, b :Point, c : Point) : Bool
	{
		var ab : Vector3D = new Vector3D(b.x - a.x, b.y - a.y, 0);
		var ac : Vector3D = new Vector3D(c.x - a.x, c.y - a.y, 0);
		return ab.crossProduct(ac).z > 0;
	}
	
	/**
	 * Compute the signed distance between the (a,b) line and the c point.
	 * 
	 * @param	a one point of the line
	 * @param	b another point of the line
	 * @param	c test point
	 * @return	the distance between (a,b) and c
	 */
	private static function getPointToLineDistance(a : Point, b : Point, c : Point) : Float
	{
		var ab : Vector3D = new Vector3D(b.x - a.x, b.y - a.y, 0);
		var ac : Vector3D = new Vector3D(c.x - a.x, c.y - a.y, 0);
		var r : Float = ab.dotProduct(ac) / ab.lengthSquared;
		if (r > 1)
		{
			var bc : Vector3D = new Vector3D(c.x - b.x, c.y - b.y, 0);
			return bc.length;
		}
		else if (r < 0)
		{
			return ac.length;
		}
		else 
		{
			var d : Vector3D = new Vector3D( -ab.y, ab.x, 0);
			d.normalize();
			return Math.abs(ac.dotProduct(d));
		}
	}

	public var selected(getSelected, setSelected) : Bool;
	public var turrets(getTurrets, null) : Array<Turret>;
	public var parentEntity(getParentEntity, setParentEntity) : Polygon;
	
	private function getSelected() : Bool
	{
		return m_selectLevel != SELECT_NONE;
	}
	
	private function setSelected(value : Bool) : Bool
	{
		for (part in m_parts)
		{
			if (value)
			{
				part.secondarySelect();
			}
			else 
			{
				part.selected = false;
			}
		}
		m_selectLevel = if (value) SELECT_PRIMARY else SELECT_NONE;
		recreateGraphics();
		return value;
	}
	
	public function secondarySelect() : Void
	{
		m_selectLevel = SELECT_SECONDARY;
		recreateGraphics();
	}
	
	private function getTurrets() : Array<Turret>
	{
		return m_turrets;
	}
	
	private function getParentEntity() : Polygon
	{
		return m_parent;
	}
	
	private function setParentEntity(value : Polygon) : Polygon
	{
		return m_parent = value;
	}
	
	private var m_points : Array<Point>;
	private var m_turrets : Array<Turret>;
	private var m_parent : Polygon;
	private var m_parts : Array<Polygon>;
	private var m_editing : Bool;
	private var m_selectLevel : Int;
	
}