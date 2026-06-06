#!/usr/bin/env python3
"""Frameless captioned iPad App Store screenshot composer (2064x2752)."""
import argparse, os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

CANVAS_W, CANVAS_H = 2064, 2752

def load_font(size):
    for p in ["/System/Library/Fonts/SFNSDisplay-Black.otf","/System/Library/Fonts/SFNS.ttf",
              "/System/Library/Fonts/Supplemental/Arial Black.ttf","/System/Library/Fonts/HelveticaNeue.ttc"]:
        if os.path.exists(p):
            try: return ImageFont.truetype(p, size)
            except Exception: continue
    return ImageFont.load_default()

def draw_centered(draw, text, font, y, fill="white"):
    bb = draw.textbbox((0,0), text, font=font)
    draw.text(((CANVAS_W-(bb[2]-bb[0]))//2, y), text, font=font, fill=fill)
    return bb[3]-bb[1]

def rounded(im, r):
    m = Image.new("L", im.size, 0)
    ImageDraw.Draw(m).rounded_rectangle([0,0,im.size[0],im.size[1]], radius=r, fill=255)
    im.putalpha(m); return im

def main():
    ap=argparse.ArgumentParser()
    for a in ("bg","verb","desc","screenshot","output"): ap.add_argument("--"+a, required=True)
    a=ap.parse_args()
    bg=a.bg.lstrip("#"); bgc=tuple(int(bg[i:i+2],16) for i in (0,2,4))+(255,)
    canvas=Image.new("RGBA",(CANVAS_W,CANVAS_H),bgc); draw=ImageDraw.Draw(canvas)
    verb_font=load_font(200); desc_font=load_font(110)
    top=150; h1=draw_centered(draw,a.verb.upper(),verb_font,top)
    desc=a.desc.upper(); bb=draw.textbbox((0,0),desc,font=desc_font)
    if bb[2]-bb[0] > CANVAS_W*0.86:
        w=desc.split(); mid=len(w)//2; lines=[" ".join(w[:mid])," ".join(w[mid:])]
    else: lines=[desc]
    y=top+h1+60
    for ln in lines: y += draw_centered(draw,ln,desc_font,y)+30
    shot=Image.open(a.screenshot).convert("RGBA")
    tw=int(CANVAS_W*0.80); scale=tw/shot.width; sw,sh=tw,int(shot.height*scale)
    shot=rounded(shot.resize((sw,sh),Image.LANCZOS),48)
    sx=(CANVAS_W-sw)//2; sy=y+110
    shadow=Image.new("RGBA",canvas.size,(0,0,0,0))
    sl=rounded(Image.new("RGBA",(sw,sh),(0,0,0,150)),48); shadow.paste(sl,(sx,sy+24),sl)
    canvas=Image.alpha_composite(canvas,shadow.filter(ImageFilter.GaussianBlur(40)))
    canvas.paste(shot,(sx,sy),shot)
    canvas.convert("RGB").save(a.output); print(f"✓ {a.output} ({CANVAS_W}x{CANVAS_H})")

if __name__=="__main__": main()
