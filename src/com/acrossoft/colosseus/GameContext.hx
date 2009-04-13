/**
 * ...
 * @author 
 */

package com.acrossoft.colosseus;
import com.acrossoft.colosseus.entities.Bullet;
import com.acrossoft.colosseus.entities.PlayerShip;
import flash.Boot;
import flash.display.Stage;

class GameContext 
{

	public function new() 
	{
		m_bulletsToAdd = new Array<Bullet>();
	}
	
	public var stage(getStage, setStage) : Stage;
	public var playerShip(getPlayerShip, setPlayerShip) : PlayerShip;
	public var elapsedTime(getElapsedTime, setElapsedTime) : Int;
	public var currentTime(getCurrentTime, setCurrentTime) : Int;
	public var bulletsToAdd(getBulletsToAdd, null) : Array<Bullet>;
	public var hitboxVisible(getHitboxVisible, setHitboxVisible) : Bool;
	
	public function addBullet(b : Bullet) : Void
	{
		m_bulletsToAdd.push(b);
	}
	
	public function cleanup() : Void
	{
		m_bulletsToAdd = new Array<Bullet>();
	}
	
	private function getPlayerShip() : PlayerShip
	{
		return m_playerShip;
	}
	
	private function setPlayerShip(value : PlayerShip) : PlayerShip
	{
		return m_playerShip = value;
	}
	
	private function getStage() : Stage
	{
		return m_stage;
	}
	
	private function setStage(value : Stage) : Stage
	{
		return m_stage = value;
	}
	
	private function getElapsedTime() : Int
	{
		return m_elapsedTime;
	}
	
	private function setElapsedTime(value : Int) : Int
	{
		return m_elapsedTime = value;
	}
	
	private function getCurrentTime() : Int
	{
		return m_currentTime;
	}
	
	private function setCurrentTime(value : Int) : Int
	{
		return m_currentTime = value;
	}
	
	private function getBulletsToAdd() : Array<Bullet>
	{
		return m_bulletsToAdd;
	}
	
	private function getHitboxVisible() : Bool 
	{
		return m_hitboxVisible;
	}
	
	private function setHitboxVisible(value : Bool) : Bool
	{
		return m_hitboxVisible = value;
	}
	
	private var m_stage : Stage;
	private var m_playerShip : PlayerShip;
	private var m_currentTime : Int;
	private var m_elapsedTime : Int;
	private var m_bulletsToAdd : Array<Bullet>;
	private var m_hitboxVisible : Bool;
	
}