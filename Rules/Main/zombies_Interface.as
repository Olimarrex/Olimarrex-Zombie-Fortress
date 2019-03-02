#include "CTF_Structs.as";
#include "ZombieCommon.as";

void onInit( CRules@ this )
{
}

void onRender( CRules@ this )
{
    CPlayer@ p = getLocalPlayer();

    if (p is null || !p.isMyPlayer()) { return; }

    string propname = "Zombies spawn time "+p.getUsername();	
	GUI::SetFont("menu");
	
    if (p.getBlob() is null && this.exists(propname) )
    {
        u8 spawn = this.get_u8(propname);

        if (spawn != 255)
        {
            GUI::DrawText( "Respawn at dawn in: "+spawn , Vec2f( getScreenWidth()/2 - 70, getScreenHeight()/3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f ), SColor(255, 255, 255, 55) );
        }
    }
	
	SColor goodColor = SColor(255, 0, 255, 0);
	SColor normalColor = SColor(255, 255, 255, 255);
	int days = getDaysSurvived();
	int mapRecord = this.get_u16("mapRecord");
	bool beatMapRecord = days > mapRecord;
	int globalRecord = this.get_u16("globalRecord");
	bool beatGlobalRecord = days > globalRecord;
	
	s16[] tickets = getTickets();
	
	int x = 300;
	int y = 12;
	GUI::DrawText("Tickets left: ", Vec2f(x, y), normalColor);
	for(int i = 0; i < tickets.length; i += 2) //+ 2 skips team 1 (undead)
	{
		GUI::DrawText(tickets[i] + "", Vec2f(x, y += 15), SColor(255, (i == 1 ? 255 : 0), (i == 2 ? 255 : 0), (i == 0 ? 255 : 0)));
	}
	y = -3;
	x = getDriver().getScreenWidth() - 450;
	GUI::DrawText("Days Survived: " + days, Vec2f(x, y += 15), normalColor);
	if(beatMapRecord)
	{
		GUI::DrawText("Map Record Beat!", Vec2f(x, y += 15), goodColor);
	}
	else
	{
		GUI::DrawText("Map Record: " + mapRecord, Vec2f(x, y += 15), normalColor);
	}
	if(beatGlobalRecord)
	{
		GUI::DrawText("Global Record Beat!", Vec2f(x, y += 15), goodColor);
	}
	else
	{
		GUI::DrawText("Global Record: " + globalRecord, Vec2f(x, y += 15), normalColor);
	}
}
