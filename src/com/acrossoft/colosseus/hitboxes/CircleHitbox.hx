/**
 * ...
 * @author 
 */

package com.acrossoft.colosseus.hitboxes;
import flash.display.DisplayObject;
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
		if (m_representation == null)
		{
			m_representation = new Shape();
			m_representation.graphics.clear();
			m_representation.graphics.lineStyle(1, 0xff0000);
			m_representation.graphics.drawCircle(m_center.x, m_center.y, m_radius);
		}
		return m_representation;
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
	private var m_representation : Shape;
	
}