#include <conio.h>
#include <windows.h>

char *map =
    "################################################################################"
    "#                                                                              #"
    "#                                                                              #"
    "#                                                                              #"
    "#                                                                              #"
    "#                                                                              #"
    "#                                                                              #"
    "#                                                                              #"
    "#                                                                              #"
    "#                                  #########                                   #"
    "#                    ##     ##     ##_____##    ##    #######################  #"
    "#             ##     ##     ##     ##     ##    ##    ##___________________##  #"
    "#      ##     ##                                      ##                       #"
    "#      ##                                                                      #"
    "#                                                     #################  #######"
    "###                                                   #################  #######"
    "###                                               ##  ## THX TO ##           ###"
    "#/                                                ##  ##  FLGR  ##           ###" 
    "#                                  #####      ##      #####################  ###"
    "########################           #####      ##      #####################  ###"
    "# ANOTHER QUALITY GAME #  ####  ###########                                    #"
    "#  BY  JULIAN RASCHKE  #  ####  ###########                                    #"
    "################################################################################";

class player
{
    private:
        int _x, _y;
        float _vy;
    public:
        player(int x, int y);
        inline int x()  { return _x;  };
        inline int y()  { return _x;  };
        inline float vy() { return _vy; };
        void update();
};

player::player(int x, int y)
{
    _x = x;
    _y = y;
    _vy = 0;
}

void player::update()
{
    puttext(_x + 1, _y + 1, _x + 1, _y + 1, " ");

    _vy += 0.2;

    for (int i = 0; i < _vy; i++)
    {
      if (map[80 + _y * 80 + _x] == ' ')
      {
        _y++;
        Beep(_vy * 100, 1);
      }
      else
      {
        _vy = 0;
      }
    };

    for (int i = 0; i > _vy / 5; i--)
    {
      if (map[-80 + _y * 80 + _x] == ' ')
      {
        _y--;
        Beep(-_vy * 100, 1);
      }
      else
      {
        _vy = 0.2;
      }
    };
    
    if ((GetAsyncKeyState(VK_UP) & 0x8000) && map[80 + _y * 80 + _x] != ' ')
    {
      _vy = -2;
      Beep(100, 50);
    }
    
    if ((GetAsyncKeyState(VK_LEFT) & 0x8000) && map[_y * 80 + _x - 1] == ' ')
    {
      _x -= 1;
      Beep(700, 10);
    }

    if ((GetAsyncKeyState(VK_RIGHT) & 0x8000) && map[_y * 80 + _x + 1] == ' ')
    {
      _x += 1;
      Beep(900, 10);
    }

    if (map[80 + _y * 80 + _x] == ' ')
    {
      puttext(_x + 1, _y + 1, _x + 1, _y + 1, "H");
    }
    else
    {
      puttext(_x + 1, _y + 1, _x + 1, _y + 1, "A");
    }
}

int main(int argc, char *argv[])
{
  puttext(1, 1, 80, 25, map);

  player plr(40, 3);

  while (true)
  {
    plr.update();
  
    Sleep(30);
  }
  
  return 0;
}
