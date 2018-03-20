#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Javierko"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <multicolors>

char g_szTag[64];

ConVar g_cvTag;
ConVar g_cvTimerFirst;
float g_fTimerFirst;

ConVar g_cvTimerSec;
float g_fTimerSec;

ConVar g_cvTimerThd;
float g_fTimerThd;

#pragma newdecls required

public Plugin myinfo =
{
	name = "[CS:GO] Round item giver",
	author = PLUGIN_AUTHOR,
	description = "You can set by own item giver.",
	version = PLUGIN_VERSION,
	url = "https://github.com/javierko"
};

public void OnPluginStart()
{
	HookEvent("round_start", Event_PlayerSpawn);
	RegConsoleCmd("sm_rigver", Command_RigVersion);
	RegConsoleCmd("sm_rigversion", Command_RigVersion);

	g_cvTag = CreateConVar("sm_ig_chattag", "[SM]", "Sets tag for messages.");
	g_cvTag.AddChangeHook(OnConVarChanged);
	g_cvTag.GetString(g_szTag, sizeof(g_szTag));

	g_cvTimerFirst = CreateConVar("sm_ig_giveknife", "60.0", "Sets a first time to drop knife", _, true, 1.0);
	g_fTimerFirst = g_cvTimerFirst.FloatValue;
	g_cvTimerSec = CreateConVar("sm_ig_givep250", "120.0", "Sets a time to drop P250", _, true, 1.0);
	g_fTimerSec = g_cvTimerSec.FloatValue;
	g_cvTimerThd = CreateConVar("sm_ig_giveump", "180.0", "Sets a time to drop UMP", _, true, 1.0);
	g_fTimerThd = g_cvTimerThd.FloatValue;

	g_cvTimerFirst.AddChangeHook(OnConVarChanged);
	g_cvTimerSec.AddChangeHook(OnConVarChanged);
	g_cvTimerThd.AddChangeHook(OnConVarChanged);

	AutoExecConfig(true, "RoundItemGiver");
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if(convar == g_cvTimerFirst)
	{
		g_fTimerFirst = StringToFloat(newValue);
	}
	else if(convar == g_cvTimerSec)
	{
		g_fTimerSec = StringToFloat(newValue);
	}
	else if(convar == g_cvTimerThd)
	{
		g_fTimerThd = StringToFloat(newValue); 
	}
	else if(convar == g_cvTag)
	{
		strcopy(g_szTag, sizeof(g_szTag), newValue);
	}
}

public Action Command_RigVersion(int client, int args)
{
	CPrintToChat(client, "%s Version of plugin is: %s", g_szTag, PLUGIN_VERSION);
	
	return Plugin_Handled;
}

public Action Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	for(int clients = 1; clients <= MaxClients; clients++) 
	{
		if(IsValidClient(clients) && IsPlayerAlive(clients))
		{
			CreateTimer(g_fTimerFirst, GiveKnife, clients);
			CreateTimer(g_fTimerSec, GiveP250, clients);
			CreateTimer(g_fTimerThd, GiveUMP, clients);
		}
	}
}

public Action GiveKnife(Handle timer, int client)
{
	if(IsValidClient(client) && IsPlayerAlive(client))
	{
		if(!HasClientKnife(client))
		{
			GivePlayerItem(client, "weapon_knife");
			CPrintToChat(client, "%s You got knife as present from server.", g_szTag);
		}
		CPrintToChat(client, "%s Everybody got knife as present from server.", g_szTag);
	}
	return Plugin_Stop;
}

public Action GiveUMP(Handle timer, int client)
{
	if(IsValidClient(client) && IsPlayerAlive(client))
	{
		if(!HasClientPrimaryGun(client))
		{
			GivePlayerItem(client, "weapon_ump45");
			CPrintToChat(client, "%s You got UMP as present from server.", g_szTag);
		}
		CPrintToChat(client, "%s Everybody got UMP as present from server.", g_szTag);
	}
	return Plugin_Stop;
}

public Action GiveP250(Handle timer, int client)
{
	if(IsValidClient(client) && IsPlayerAlive(client))
	{
		if(!HasClientSecundaryGun(client))
		{
			GivePlayerItem(client, "weapon_p250");
			CPrintToChat(client, "%s You got p250 as present from server.", g_szTag);
		}
		CPrintToChat(client, "%s Everybody got p250 as present from server.", g_szTag);
	}

	return Plugin_Stop;
}

public bool HasClientKnife(int client)
{
	for(int i = 0; i < 128; i += 4)
	{
		int ent = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);
		if(!IsValidEntity(ent))
		{
			continue;
		}
		int iDefIndex = GetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex");
		switch(iDefIndex)
		{
			case 41: return true; //Knife
			case 42: return true; //Knife
			case 59: return true; //Knife
			case 500: return true; //Knife
			case 505: return true; //Knife
			case 506: return true; //Knife
			case 507: return true; //Knife
			case 508: return true; //Knife
			case 509: return true; //Knife
			case 512: return true; //Knife
			case 514: return true; //Knife
			case 515: return true; //Knife
			case 516: return true; //Knife
		}
	}
	return false;
}

public bool HasClientSecundaryGun(int client)
{
	for(int i = 0; i < 128; i += 4)
	{
		int ent = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);
		if(!IsValidEntity(ent))
		{
			continue;
		}
		int iDefIndex = GetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex");
		switch(iDefIndex)
		{
			case 1: return true; //Deagle
			case 2: return true; //Dual berretas
			case 3: return true; //Five-seven
			case 4: return true; //Glock
			case 30: return true; //Tec-9
			case 32: return true; //P2000
			case 36: return true; //P250
			case 61: return true; //USP
			case 63: return true; //CZ75
			case 64: return true; //Revolver
		}
	}
	return false;
}

public bool HasClientPrimaryGun(int client)
{
	for(int i = 0; i < 128; i += 4)
	{
		int ent = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);
		if(!IsValidEntity(ent))
		{
			continue;
		}
		int iDefIndex = GetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex");
		switch(iDefIndex)
		{
			case 7: return true; //AK-47
			case 8: return true; //AUG
			case 9: return true; //AWP
			case 10: return true; //FAMAS
			case 11: return true; //G35G1
			case 13: return true; //Galil
			case 14: return true; //M249
			case 16: return true; //M4A4
			case 17: return true; //MAC-10
			case 19: return true; //P90
			case 24: return true; //UMP
			case 25: return true; //XM1014
			case 26: return true; //Bizon
			case 27: return true; //MAG
			case 28: return true; //negev
			case 29: return true; //Sawed Off
			case 33: return true; //MP7
			case 34: return true; //MP9
			case 35: return true; //nova
			case 38: return true; //scar
			case 39: return true; //SG 553
			case 40: return true; //SSG 08
			case 60: return true; //M4A1-S
		}
	}
	return false;
}

stock bool IsValidClient(int client)
{
	if (client <= 0 || client > MaxClients || !IsClientInGame(client))
  	{
		return false;
	}
	return true;
}