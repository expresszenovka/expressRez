//---------------------------------
// expressRez Prim Script
// version 1.0  (December 25, 2010)
// http://github.com/expresszenovka/expressRez
// ---------------------
// Copyright Express Zenovka, 2010-2011
// GNU GPL http://www.gnu.org/licenses/gpl.html
//---------------------------------

//------- Variables -------//

// static communication strings
string SET_MESSAGE = "SET_IT";
string DEL_MESSAGE = "DELETE";
string MOV_MESSAGE = "MOV";
string ASK_MESSAGE = "ASKING";

// static communication values
integer ASK_CHANNEL = -1234567;

// communication vars
integer kid_channel = 0;

//------- Functions -------//

objectMoveTo(vector position)
{
    vector last;
    do
    {
        last = llGetPos();
        llSetPos(position);
    } while ((llVecDist(llGetPos(),position) > 0.001) && (llGetPos() != last));
}

//------- States -------//
default
{
    on_rez(integer sparam)
    {
        if (sparam != 0)
        {
            kid_channel = sparam;
            state listening;
        }
    }
    state_entry()
    {
        llListen(ASK_CHANNEL, "", "", ASK_MESSAGE);
    }
    listen(integer channel, string name, key id, string message)
    {
        llShout(ASK_CHANNEL, (string) llGetRegionCorner() + "|" + (string) llGetPos());
    }
}

state listening
{
    state_entry()
    {
        llListen(kid_channel, "", "", "");
    }
    listen(integer channel, string name, key id, string message)
    {
        if (kid_channel == channel) 
        {
            if (message == DEL_MESSAGE)
            {
                llDie();
            }
            else if (message == SET_MESSAGE)
            {
                llRemoveInventory(llGetScriptName());
            }
            else if (llStringLength(message) > 3)
            {
                list l = llParseString2List(message, ["|"], []);
                if (llGetListLength(l) == 3)
                {
                    if (llList2String(l,0) == MOV_MESSAGE)
                    {
                        llSetRot((rotation) llList2String(l,2));
                        objectMoveTo((vector) llList2String(l,1));
                    }
                }
            }
        }
    }
}