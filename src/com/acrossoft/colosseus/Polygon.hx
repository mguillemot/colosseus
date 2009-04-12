/**
 * ...
 * @author 
 */

package com.acrossoft.colosseus;
import com.acrossoft.colosseus.entities.Turret;
import flash.Boot;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Vector3D;

class Polygon extends Sprite 
{

	public function new() 
	{
		super();
	}
	
	private function recreateGraphics() : Void
	{
		graphics.clear();
		if (m_points.length > 1)
		{
			graphics.lineStyle(2, if (m_selected) 0x007F0E else 0x00ff00);
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
		}
		if (m_editing && m_points.length > 0)
		{
			graphics.lineStyle(2, 0x007F0E);
			var lastPoint : Point = m_points[m_points.length - 1];
			graphics.drawCircle(lastPoint.x, lastPoint.y, 2);
		}
		graphics.lineStyle(0);
		graphics.beginFill(0xff0000);
		graphics.drawCircle(0, 0, 5);
	}
	
	public function startEdit() : Void
	{
		m_editing = true;
		m_points = new Array();
		m_turrets = new Array();
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
				if (p.subtract(firstPoint).length < 3)
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
	
	public function isInside(p : Point) : Bool
	{
		for (i in 0...m_points.length)
		{
			var a : Point = getTransformedPoint(i);
			var b : Point = getTransformedPoint(i + 1);
			var right : Bool = partitionTest(a, b, p);
			if (!right)
			{
				return false;
			}
		}
		return true;
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
	
	private function getSelected() : Bool
	{
		return m_selected;
	}
	
	private function setSelected(value : Bool) : Bool
	{
		m_selected = value;
		recreateGraphics();
		return m_selected;
	}
	
	private var m_points : Array<Point>;
	private var m_turrets : Array<Turret>;
	private var m_editing : Bool;
	private var m_selected : Bool;
	
}