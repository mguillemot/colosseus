/**
 * ...
 * @author 
 */

package com.acrossoft.colosseus.tweens;
import flash.Lib;

class CyclicSinTween extends Tween
{
	
	public function new(center : Float, radius : Float, cycleDuration : Float, target : Dynamic, property : String) 
	{
		super(target, property);
		m_center = center;
		m_radius = radius;
		m_cycleDuration = cycleDuration;
	}
	
	override function getCurrentValue() : Float
	{
		var startedSince : Int = Lib.getTimer() - m_startTime;
		var progression : Float = startedSince / m_cycleDuration;
		var angle : Float = progression * 2 * Math.PI;
		return m_center + m_radius * Math.sin(angle);
	}

	private var m_center : Float;
	private var m_radius : Float;
	private var m_cycleDuration : Float;
	
}