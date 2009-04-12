/**
 * ...
 * @author 
 */

package com.acrossoft.colosseus.tweens;
import flash.Lib;

class Tween 
{

	public function new(target : Dynamic, property : String) 
	{
		m_started = false;
		m_startTime = 0;
		m_target = target;
		m_property = property;
	}
	
	public function start() : Void 
	{
		m_started = true;
		m_startTime = Lib.getTimer();
		Tweens.register(this);
	}
	
	public function stop() : Void 
	{
		m_started = false;
		m_startTime = 0;
		Tweens.unregister(this);
	}
	
	public function update() : Void
	{
		Reflect.setField(m_target, m_property, getCurrentValue());
	}

	public function getCurrentValue() : Float
	{
		return 0;
	}
	
	private var m_started : Bool;
	private var m_startTime : Int;
	private var m_target : Dynamic;
	private var m_property : String;
	
}