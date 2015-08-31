//
// Skyway, a vertical space shooter prototype.
// Copyright 2005 Alex Margarit, licensed under GNU GPL3.
//

program skyway;

const

    frames = 30;

    enemyshipspeed = 2;

    bulletspeed = 4;
    bulletdelay = 3;

    bonusspeed = 2;

    maxships = 5;
    maxbullets = 3;
    maxenemybullets = 6;

    enemybulletdamage = 1;
    explosiondamage = 10;

    startlife = 100;

global

    ships = 0;
    bullets = 0;
    enemybullets = 0;
    lastbullet = 0;

    life = startlife;
    score = 600;
    hiscore;
    shipspeed = 6;

    playership;

    int enemies[1];

begin

    set_title("SkyWay by Alex!");
    set_fps(frames,0);
    full_screen = false;
    set_mode(320,240,8);
    load_fpg("skyway.fpg");

    write(0,6,20,0,"This game is in its very early stages, so any");
    write(0,6,34,0,"bug reports or suggestions are welcome!");
    write(0,6,48,0,"Send them to artraid@gmail.com - Thank you!");

    set_text_color(rgb(5,140,255));
    write(0,6,6,0,"SkyWay by Alex!");
    write(0,6,62,0,"Press START to continue.");

    loop
        if (key(_enter)) break; end
        frame;
    end

    delete_text(0);

    enemies[0] = 14;
    enemies[1] = 15;

    load("skyway.sco",hiscore);

    set_text_color(rgb(215,215,215));
    write(0,6,6,0,"FPS:");
    write(0,282,6,0,"Life:");
    write(0,6,228,0,"Score:");
    write(0,230,228,0,"Hiscore:");
    set_text_color(rgb(255,239,202));
    write_int(0,6,16,0,&fps);
    write_int(0,282,16,0,&life);
    write_int(0,48,228,0,&score);
    write_int(0,284,228,0,&hiscore);

    frame;

    playership = ship(160,200);

    start_scroll(0,"skyway.fpg",12,0,0,2);
    scroll[0].camera = land_camera();

    start_scroll(1,"skyway.fpg",4,0,0,2);
    scroll[1].camera = bar_camera();

    while(life > 0)
        if(rand(1,10) < 5 and ships < maxships)
            ships++;
            enemyship(rand(10,310),0);
        end

        frame;
    end

    let_me_alone();

    savescore();

end

//
// Cameras Process
//

process land_camera();
begin
    x = 0;
    loop
        y -= shipspeed - 5;
        frame;
    end;
end;

process bar_camera();
    begin
        x = 0;
    loop
        y -= shipspeed - 2;
        frame;
    end;
end;

//
// Ship Process
//

process ship(x,y)
begin

    graph = 2;
    z = 1;

    loop

        if(key(_left) and x > 75) x -= shipspeed; end
        if(key(_right) and x < 245) x += shipspeed; end
        if(key(_up) and y > 15) y -= shipspeed; end
        if(key(_down) and y < 225) y += shipspeed; end
        if(key(_control) and lastbullet == 0 and bullets < maxbullets)
            lastbullet += bulletdelay;
            bullet(x,y);
        end

        if(lastbullet > 0) lastbullet--; end

    if(key(_tab) and key(_backspace)) life = 0; end

        frame;

    end

end

//
// Bullet Process
//

process bullet(x,y)

private

die;

begin

    graph = 3;
    z = 3;
    bullets++;

    while(y > 0)
        y -= bulletspeed;
        frame;
    end

    bullets--;
    return;

end

//
// Enemy Ship Process
//

process enemyship(x,y)

private

random;
picture;
xspeed;

begin

    graph = enemies[rand(0,1)];
    z = 2;

    while(y < 240)
        y += enemyshipspeed;
        if((x + xspeed) < 310 and (x + xspeed) > 10) x += xspeed; end
        random = rand(1,50);

        if(random == 1 and enemybullets < maxenemybullets) enemybullet(x,y);
        //elseif(random > 5 and random < 11 and x < playership.x) xspeed++;
        //elseif(random > 10 and random < 16 and x > playership.x) xspeed--; end
        elseif(x < playership.x) xspeed = enemyshipspeed;
        elseif(x > playership.x) xspeed = -enemyshipspeed;
        elseif(x == playership.x) xspeed = 0; end

        if (collision(type bullet))
            if (random == 16) medicinebonus(x,y);
            elseif (random == 17) scorebonus(x,y);
            elseif (random == 18 and shipspeed < 17) speedbonus(x,y); end
            ships--;
            score++;
            return;
        elseif (collision(type ship))
            life -= explosiondamage;
            ships--;
            return;
        end

        frame;
    end

    ships--;
    return;

end

//
// Enemy Bullet Process
//

process enemybullet(x,y)
begin

    graph = 5;
    z = 3;
    enemybullets++;

    while(y < 240)
        y += bulletspeed;
        if(collision(type ship))
            life -= enemybulletdamage;
            y = 240;
        end
        frame;
    end

    enemybullets--;
    return;

end

//
// Medicine Bonus Process
//

process medicinebonus(x,y)
begin

    graph = 6;
    z = 3;

    while(y < 240)
        y += bonusspeed;
        if(collision(type ship))
            life += 20;
            return;
        end
        frame;
    end

    return;

end

//
// Score Bonus Process
//

process scorebonus(x,y)
begin

    graph = 9;
    z = 3;

    while(y < 240)
        y += bonusspeed;
        if(collision(type ship))
            score += 20;
            return;
        end
        frame;
    end

    return;

end

//
// Speed Bonus Process
//

process speedbonus(x,y)
begin

    graph = 10;
    z = 3;

    while(y < 240)
        y += bonusspeed;
        if(collision(type ship))
            shipspeed += 1;
            return;
        end
        frame;
    end

    return;

end

//
// Hiscore Process
//

process savescore()
begin

    delete_text(0);
    set_text_color(rgb(0,0,0));

    if (score > hiscore)
        hiscore = score;
        write(0,60,6,0,"You've got a hiscore!");
        write(0,60,20,0,"Saving highscore on SMC card...");
        frame;
        save("skyway.sco",hiscore);
        write(0,60,34,0,"DONE.");
        write(0,60,48,0,"Press A to soft-reboot your unit.");
    elseif (score == hiscore)
        write(0,60,6,0,"Your score was equal to the hiscore! WOW!");
        write(0,60,20,0,"Press A to soft-reboot your unit.");
    elseif (score < hiscore)
        write(0,60,6,0,"You did not get a hiscore.");
        write(0,60,20,0,"Press A to soft-reboot your unit.");
    end

    loop
        if (key(_control)) break; end
        frame;
    end

end
