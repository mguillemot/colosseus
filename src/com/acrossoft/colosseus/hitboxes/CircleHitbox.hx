/**
 * ...
 * @author 
 */

package com.acrossoft.colosseus.hitboxes;
import flash.display.Shape;
import flash.geom.Point;

class CircleHitbox 
{

	public function new(center : Point, radius : Float) 
	{
		m_center = center;
		m_radius = radius;
	}

	public function getRepresentation() : Shape
	{
		var s : Shape = new Shape();
		s.graphics.clear();
		s.graphics.lineStyle(1, 0xff0000);
		s.graphics.drawCircle(m_center.x, m_center.y, m_radius);
		return s;
	}
	
	public function getCenter() : Point
	{
		return m_center;
	}
	
	public function getRadius() : Float
	{
		return m_radius;
	}
	
	private var m_center : Point;
	private var m_radius : Float;	
	
}