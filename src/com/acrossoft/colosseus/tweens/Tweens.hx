/**
 * ...
 * @author 
 */

package com.acrossoft.colosseus.tweens;

class Tweens 
{

	public static function register(t : Tween) : Void
	{
		s_tweens.add(t);
	}
	
	public static function unregister(t : Tween) : Void
	{
		s_tweens.remove(t);
	}
	
	public static function tick() : Void
	{
		for (t in s_tweens)
		{
			t.update();
		}
	}

	private static var s_tweens : haxe.FastList<Tween> = new haxe.FastList<Tween>();
	
}