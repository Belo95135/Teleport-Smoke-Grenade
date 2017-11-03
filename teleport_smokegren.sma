#include < amxmodx >
#include < fakemeta >
#include < fun >

#define SMOKE_GROUND_OFFSET	6
//new g_spriteid_steam1, g_eventid_createsmoke;
new const Float:size[ ][ 3 ] =
{ // do not edit
	{0.0, 0.0, 1.0}, {0.0, 0.0, -1.0}, {0.0, 1.0, 0.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}, {-1.0, 0.0, 0.0}, {-1.0, 1.0, 1.0}, {1.0, 1.0, 1.0}, {1.0, -1.0, 1.0}, {1.0, 1.0, -1.0}, {-1.0, -1.0, 1.0}, {1.0, -1.0, -1.0}, {-1.0, 1.0, -1.0}, {-1.0, -1.0, -1.0},
	{0.0, 0.0, 2.0}, {0.0, 0.0, -2.0}, {0.0, 2.0, 0.0}, {0.0, -2.0, 0.0}, {2.0, 0.0, 0.0}, {-2.0, 0.0, 0.0}, {-2.0, 2.0, 2.0}, {2.0, 2.0, 2.0}, {2.0, -2.0, 2.0}, {2.0, 2.0, -2.0}, {-2.0, -2.0, 2.0}, {2.0, -2.0, -2.0}, {-2.0, 2.0, -2.0}, {-2.0, -2.0, -2.0},
	{0.0, 0.0, 3.0}, {0.0, 0.0, -3.0}, {0.0, 3.0, 0.0}, {0.0, -3.0, 0.0}, {3.0, 0.0, 0.0}, {-3.0, 0.0, 0.0}, {-3.0, 3.0, 3.0}, {3.0, 3.0, 3.0}, {3.0, -3.0, 3.0}, {3.0, 3.0, -3.0}, {-3.0, -3.0, 3.0}, {3.0, -3.0, -3.0}, {-3.0, 3.0, -3.0}, {-3.0, -3.0, -3.0},
	{0.0, 0.0, 4.0}, {0.0, 0.0, -4.0}, {0.0, 4.0, 0.0}, {0.0, -4.0, 0.0}, {4.0, 0.0, 0.0}, {-4.0, 0.0, 0.0}, {-4.0, 4.0, 4.0}, {4.0, 4.0, 4.0}, {4.0, -4.0, 4.0}, {4.0, 4.0, -4.0}, {-4.0, -4.0, 4.0}, {4.0, -4.0, -4.0}, {-4.0, 4.0, -4.0}, {-4.0, -4.0, -4.0},
	{0.0, 0.0, 5.0}, {0.0, 0.0, -5.0}, {0.0, 5.0, 0.0}, {0.0, -5.0, 0.0}, {5.0, 0.0, 0.0}, {-5.0, 0.0, 0.0}, {-5.0, 5.0, 5.0}, {5.0, 5.0, 5.0}, {5.0, -5.0, 5.0}, {5.0, 5.0, -5.0}, {-5.0, -5.0, 5.0}, {5.0, -5.0, -5.0}, {-5.0, 5.0, -5.0}, {-5.0, -5.0, -5.0}
};

public plugin_init( )
{
	register_plugin( "Teleport Smoke Grenade", "1.0", "VEN" ); // Edited by: K@T4pULT

	register_concmd( "test", "test" );
	register_forward( FM_EmitSound, "forward_emitsound" );
//	register_forward( FM_PlaybackEvent, "forward_playbackevent" );
//	g_spriteid_steam1 = engfunc( EngFunc_PrecacheModel, "sprites/steam1.spr" );
//	g_eventid_createsmoke = engfunc( EngFunc_PrecacheEvent, 1, "events/createsmoke.sc" );
}
public test( playerid )
{
	if( is_user_alive( playerid ) )
	{
		give_item( playerid, "weapon_smokegrenade" );
	}
	return PLUGIN_CONTINUE;
}
public forward_emitsound( entity, channel, const sample[ ], Float:volume, Float:attn, flags, pitch )
{
	if( !equal( sample, "weapons/sg_explode.wav" ) || !is_grenade( entity ) )
	{
		return FMRES_IGNORED;
	}
	new playerid = pev( entity, pev_owner );
	if( !is_user_alive( playerid ) )
	{ // naco zistovat origin?! ked nie je platny index, tak to skoncime hned..
		return FMRES_IGNORED;
	}
	new Float:origin[ 3 ];
	pev( entity, pev_origin, origin );
	engfunc( EngFunc_EmitSound, entity, channel, sample, volume, attn, SND_STOP, pitch ); // lepsie bude zastavit zvuk, ktory je spusteny ako ho nahradzat inym..
	origin[ 2 ] += SMOKE_GROUND_OFFSET;
	set_pev( playerid, pev_origin, origin );
	check_Stuck( playerid );
	return FMRES_IGNORED;
}
public check_Stuck( playerid )
{
	if( !is_user_alive( playerid ) || get_user_noclip( playerid ) || ( pev( playerid, pev_solid ) & SOLID_NOT ) )
	{
		return PLUGIN_HANDLED; // Predcasne ukoncenie..
	}
	new Float:fOrigin[ 3 ];
	new Float:fMins[ 3 ];
	new Float:fVec[ 3 ];
	pev( playerid, pev_origin, fOrigin );
	new hull = ( pev( playerid, pev_flags ) & FL_DUCKING ) ? HULL_HEAD : HULL_HUMAN;
	if( !is_hull_vacant( fOrigin, hull, playerid ) )
	{
		pev( playerid, pev_mins, fMins );
		fVec[ 2 ] = fOrigin[ 2 ];
		new max = sizeof( size );
		for( new i=0; i < max; i++ )
		{
			fVec[ 0 ] = fOrigin[ 0 ] - fMins[ 0 ] * size[ i ][ 0 ];
			fVec[ 1 ] = fOrigin[ 1 ] - fMins[ 1 ] * size[ i ][ 1 ];
			fVec[ 2 ] = fOrigin[ 2 ] - fMins[ 2 ] * size[ i ][ 2 ];
			if( is_hull_vacant( fVec, hull, playerid ) )
			{
				engfunc( EngFunc_SetOrigin, playerid, fVec );
				set_pev( playerid, pev_velocity, Float:{ 0.0, 0.0, 0.0 } );
				break;
			}
		}
	}
	return PLUGIN_CONTINUE;
}

stock bool:is_grenade( ent )
{
	if( !pev_valid( ent ) )
	{
		return false;
	}
	static classname[ 8 ];
	pev( ent, pev_classname, classname, 7 );
	if( equal( classname, "grenade" ) )
	{
		return true;
	}
	return false
}
stock is_hull_vacant( const Float:origin[ 3 ], hull, playerid )
{ // Code fron: 'Automatic Unstuck 1.5' by: NL)Ramon(NL
	static tr;
	engfunc( EngFunc_TraceHull, origin, origin, 0, hull, playerid, tr );
	return ( !get_tr2( tr, TR_StartSolid ) || !get_tr2( tr, TR_AllSolid ) );
}

/*
* #define SMOKE_SCALE			30
* #define SMOKE_FRAMERATE		12
create_smoke( const Float:origin[ 3 ] ) {
	// engfunc because origin are float
	engfunc( EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0 )
	write_byte( TE_SMOKE )
	engfunc( EngFunc_WriteCoord, origin[ 0 ] )
	engfunc( EngFunc_WriteCoord, origin[ 1 ] )
	engfunc( EngFunc_WriteCoord, origin[ 2 ] )
	write_short( g_spriteid_steam1 )
	write_byte( SMOKE_SCALE )
	write_byte( SMOKE_FRAMERATE )
	message_end( )
}
* 
public forward_playbackevent( flags, invoker, eventindex ) {
	// we do not need a large amount of smoke
	if ( eventindex == g_eventid_createsmoke )
		return FMRES_SUPERCEDE

	return FMRES_IGNORED
}*/