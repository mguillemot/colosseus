package com.acrossoft.colosseus.entities;

import com.acrossoft.colosseus.hitboxes.CircleHitbox;
import flash.display.MovieClip;
import flash.geom.Point;
import flash.Lib;
/**
 * ...
 * @author Matthieu Guillemot
 */
 
class EnemyShip extends GameEntity
{
	
	public function new()
	{
		super();
		var g = Lib.attach("asset.EnemyShip");
		g.width = 250;
		g.height = 150;
		addChild(g);
		m_hitbox = new CircleHitbox(new Point(0, 0), 50);
	}
	
}